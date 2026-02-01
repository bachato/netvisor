#!/usr/bin/env python3
"""
HubSpot Backfill Script

One-time migration to sync existing organizations and users to HubSpot.
Run after deploying HubSpot integration.

Usage:
    export HUBSPOT_API_KEY="your-key"
    export DATABASE_URL="postgres://user:pass@host:5432/scanopy"

    python hubspot-backfill.py --dry-run  # Preview changes
    python hubspot-backfill.py            # Run for real
"""

import argparse
import os
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
import json

try:
    import psycopg2
    import psycopg2.extras
    import requests
except ImportError:
    print("Required packages: pip install psycopg2-binary requests")
    sys.exit(1)


HUBSPOT_API_BASE = "https://api.hubapi.com"
RATE_LIMIT_DELAY = 0.15  # ~7 req/sec to stay under 10/sec limit


@dataclass
class Organization:
    id: str
    name: str
    plan_type: Optional[str]
    plan_status: Optional[str]
    network_limit: Optional[int]
    seat_limit: Optional[int]
    created_at: datetime
    network_count: int
    host_count: int
    user_count: int


@dataclass
class User:
    id: str
    email: str
    name: str
    permissions: str
    organization_id: str
    created_at: datetime


class HubSpotClient:
    def __init__(self, api_key: str, dry_run: bool = False):
        self.api_key = api_key
        self.dry_run = dry_run
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        })

    def _request(self, method: str, path: str, data: dict = None) -> dict:
        if self.dry_run:
            print(f"  [DRY RUN] {method} {path}")
            if data:
                print(f"    Body: {json.dumps(data, indent=2, default=str)[:200]}...")
            return {"id": "dry-run-id"}

        time.sleep(RATE_LIMIT_DELAY)

        url = f"{HUBSPOT_API_BASE}{path}"
        response = self.session.request(method, url, json=data)

        if response.status_code == 429:
            # Rate limited - wait and retry
            retry_after = int(response.headers.get("Retry-After", 10))
            print(f"  Rate limited, waiting {retry_after}s...")
            time.sleep(retry_after)
            return self._request(method, path, data)

        if not response.ok:
            print(f"  ERROR: {response.status_code} - {response.text[:200]}")
            return None

        return response.json() if response.text else {}

    def search_contact(self, email: str) -> Optional[str]:
        """Search for contact by email, return HubSpot ID if found."""
        data = {
            "filterGroups": [{
                "filters": [{
                    "propertyName": "email",
                    "operator": "EQ",
                    "value": email
                }]
            }],
            "properties": ["email"],
            "limit": 1
        }
        result = self._request("POST", "/crm/v3/objects/contacts/search", data)
        if result and result.get("results"):
            return result["results"][0]["id"]
        return None

    def search_company(self, org_id: str) -> Optional[str]:
        """Search for company by scanopy_org_id, return HubSpot ID if found."""
        data = {
            "filterGroups": [{
                "filters": [{
                    "propertyName": "scanopy_org_id",
                    "operator": "EQ",
                    "value": org_id
                }]
            }],
            "properties": ["scanopy_org_id"],
            "limit": 1
        }
        result = self._request("POST", "/crm/v3/objects/companies/search", data)
        if result and result.get("results"):
            return result["results"][0]["id"]
        return None

    def upsert_contact(self, user: User) -> Optional[str]:
        """Create or update contact, return HubSpot ID."""
        # Split name into first/last
        name_parts = user.name.split() if user.name else []
        firstname = name_parts[0] if name_parts else None
        lastname = " ".join(name_parts[1:]) if len(name_parts) > 1 else None

        properties = {
            "email": user.email,
            "scanopy_user_id": user.id,
            "scanopy_org_id": user.organization_id,
            "scanopy_role": user.permissions.lower(),
            "scanopy_signup_source": "organic",
            "scanopy_signup_date": user.created_at.strftime("%Y-%m-%d"),
        }
        if firstname:
            properties["firstname"] = firstname
        if lastname:
            properties["lastname"] = lastname

        existing_id = self.search_contact(user.email)
        if existing_id:
            result = self._request("PATCH", f"/crm/v3/objects/contacts/{existing_id}",
                                   {"properties": properties})
            return existing_id if result else None
        else:
            result = self._request("POST", "/crm/v3/objects/contacts",
                                   {"properties": properties})
            return result.get("id") if result else None

    def upsert_company(self, org: Organization) -> Optional[str]:
        """Create or update company, return HubSpot ID."""
        properties = {
            "name": org.name,
            "scanopy_org_id": org.id,
            "scanopy_network_count": org.network_count,
            "scanopy_host_count": org.host_count,
            "scanopy_user_count": org.user_count,
            "scanopy_created_date": org.created_at.strftime("%Y-%m-%d"),
        }

        if org.plan_type:
            properties["scanopy_plan_type"] = org.plan_type
        if org.plan_status:
            properties["scanopy_plan_status"] = org.plan_status
        if org.network_limit:
            properties["scanopy_network_limit"] = org.network_limit
        if org.seat_limit:
            properties["scanopy_seat_limit"] = org.seat_limit

        existing_id = self.search_company(org.id)
        if existing_id:
            result = self._request("PATCH", f"/crm/v3/objects/companies/{existing_id}",
                                   {"properties": properties})
            return existing_id if result else None
        else:
            result = self._request("POST", "/crm/v3/objects/companies",
                                   {"properties": properties})
            return result.get("id") if result else None

    def associate_contact_to_company(self, contact_id: str, company_id: str):
        """Associate a contact with a company."""
        data = {
            "inputs": [{
                "from": {"id": contact_id},
                "to": {"id": company_id},
                "types": [{
                    "associationCategory": "HUBSPOT_DEFINED",
                    "associationTypeId": 1
                }]
            }]
        }
        self._request("POST", "/crm/v4/associations/contacts/companies/batch/create", data)


def fetch_organizations(cursor) -> list[Organization]:
    """Fetch all organizations with aggregate counts."""
    cursor.execute("""
        SELECT
            o.id::text,
            o.name,
            o.plan->>'type' as plan_type,
            o.plan_status,
            (o.plan->>'included_networks')::int as network_limit,
            (o.plan->>'included_seats')::int as seat_limit,
            o.created_at,
            (SELECT COUNT(*) FROM networks WHERE organization_id = o.id) as network_count,
            (SELECT COUNT(*) FROM hosts h
             JOIN networks n ON h.network_id = n.id
             WHERE n.organization_id = o.id) as host_count,
            (SELECT COUNT(*) FROM users WHERE organization_id = o.id) as user_count
        FROM organizations o
        ORDER BY o.created_at
    """)

    return [
        Organization(
            id=row[0],
            name=row[1],
            plan_type=row[2],
            plan_status=row[3],
            network_limit=row[4],
            seat_limit=row[5],
            created_at=row[6],
            network_count=row[7],
            host_count=row[8],
            user_count=row[9],
        )
        for row in cursor.fetchall()
    ]


def fetch_users_for_org(cursor, org_id: str) -> list[User]:
    """Fetch all users for an organization."""
    cursor.execute("""
        SELECT
            id::text,
            email,
            name,
            permissions,
            organization_id::text,
            created_at
        FROM users
        WHERE organization_id = %s::uuid
        ORDER BY created_at
    """, (org_id,))

    return [
        User(
            id=row[0],
            email=row[1],
            name=row[2],
            permissions=row[3],
            organization_id=row[4],
            created_at=row[5],
        )
        for row in cursor.fetchall()
    ]


def main():
    parser = argparse.ArgumentParser(description="Backfill HubSpot with existing data")
    parser.add_argument("--dry-run", action="store_true", help="Preview without making changes")
    args = parser.parse_args()

    # Get config from environment
    hubspot_key = os.environ.get("HUBSPOT_API_KEY")
    database_url = os.environ.get("DATABASE_URL")

    if not hubspot_key:
        print("ERROR: HUBSPOT_API_KEY environment variable required")
        sys.exit(1)
    if not database_url:
        print("ERROR: DATABASE_URL environment variable required")
        sys.exit(1)

    if args.dry_run:
        print("=== DRY RUN MODE - No changes will be made ===\n")

    # Connect to database
    print("Connecting to database...")
    conn = psycopg2.connect(database_url)
    cursor = conn.cursor()

    # Initialize HubSpot client
    hubspot = HubSpotClient(hubspot_key, dry_run=args.dry_run)

    # Fetch all organizations
    print("Fetching organizations...")
    organizations = fetch_organizations(cursor)
    print(f"Found {len(organizations)} organizations\n")

    # Stats
    stats = {
        "orgs_synced": 0,
        "orgs_failed": 0,
        "contacts_synced": 0,
        "contacts_failed": 0,
    }
    failed_orgs = []

    # Process each organization
    for i, org in enumerate(organizations, 1):
        print(f"[{i}/{len(organizations)}] Processing: {org.name} ({org.id[:8]}...)")
        print(f"  Networks: {org.network_count}, Hosts: {org.host_count}, Users: {org.user_count}")

        # Upsert company
        company_id = hubspot.upsert_company(org)
        if not company_id:
            print(f"  FAILED to sync company")
            stats["orgs_failed"] += 1
            failed_orgs.append(org.id)
            continue

        stats["orgs_synced"] += 1
        print(f"  Company synced: {company_id}")

        # Fetch and sync users
        users = fetch_users_for_org(cursor, org.id)
        for user in users:
            contact_id = hubspot.upsert_contact(user)
            if contact_id:
                hubspot.associate_contact_to_company(contact_id, company_id)
                stats["contacts_synced"] += 1
                print(f"  Contact synced: {user.email} ({user.permissions})")
            else:
                stats["contacts_failed"] += 1
                print(f"  FAILED to sync contact: {user.email}")

        print()

    # Summary
    print("=" * 50)
    print("SUMMARY")
    print("=" * 50)
    print(f"Organizations synced: {stats['orgs_synced']}")
    print(f"Organizations failed: {stats['orgs_failed']}")
    print(f"Contacts synced: {stats['contacts_synced']}")
    print(f"Contacts failed: {stats['contacts_failed']}")

    if failed_orgs:
        print(f"\nFailed organization IDs:")
        for org_id in failed_orgs:
            print(f"  {org_id}")

    cursor.close()
    conn.close()

    if args.dry_run:
        print("\n=== DRY RUN COMPLETE - No changes were made ===")


if __name__ == "__main__":
    main()
