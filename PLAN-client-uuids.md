# Implementation Plan: Client-Provided UUIDs

## Overview

Refactor the host/service creation and update APIs to support client-provided UUIDs, enabling:
1. Single-step host creation with services and bindings
2. Binding ID preservation across updates
3. Cleaner, more consistent API types

## Design Decisions

| Decision | Choice |
|----------|--------|
| Entity IDs | Required `Uuid` (client must provide) |
| Input types | Consolidated (Create + Update use same types) |
| Empty collections | `Vec<T>` not `Option<Vec<T>>` |
| Backwards compatibility | Breaking change - cleaner API |

---

## Phase 1: Backend Type Consolidation

### 1.1 Create consolidated input types

**File:** `backend/src/server/hosts/impl/api.rs`

Replace `CreateInterfaceInput`, `UpdateInterfaceInput`, etc. with consolidated types:

```rust
/// Input for creating or updating an interface.
/// Used in both CreateHostRequest and UpdateHostRequest.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct InterfaceInput {
    /// Client-provided UUID for this interface
    pub id: Uuid,
    pub subnet_id: Uuid,
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[schema(value_type = Option<String>)]
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
    /// Position in the host's interface list (for ordering)
    pub position: i32,
}

/// Input for creating or updating a port.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct PortInput {
    /// Client-provided UUID for this port
    pub id: Uuid,
    pub number: u16,
    pub protocol: TransportProtocol,
}

/// Input for creating or updating a service.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct ServiceInput {
    /// Client-provided UUID for this service
    pub id: Uuid,
    #[schema(value_type = String)]
    pub service_definition: Box<dyn ServiceDefinition>,
    pub name: String,
    pub bindings: Vec<BindingInput>,
    pub virtualization: Option<ServiceVirtualization>,
    #[serde(default)]
    pub tags: Vec<Uuid>,
    /// Position in the host's service list (for ordering)
    pub position: i32,
}

/// Input for creating or updating a binding.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(tag = "type")]
pub enum BindingInput {
    Interface {
        /// Client-provided UUID for this binding
        id: Uuid,
        interface_id: Uuid,
    },
    Port {
        /// Client-provided UUID for this binding
        id: Uuid,
        port_id: Uuid,
        #[serde(skip_serializing_if = "Option::is_none")]
        interface_id: Option<Uuid>,
    },
}

impl BindingInput {
    pub fn id(&self) -> Uuid {
        match self {
            BindingInput::Interface { id, .. } => *id,
            BindingInput::Port { id, .. } => *id,
        }
    }
}
```

### 1.2 Update CreateHostRequest

```rust
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Validate)]
pub struct CreateHostRequest {
    #[validate(length(min = 1, max = 255))]
    pub name: String,
    pub network_id: Uuid,
    #[validate(length(max = 255))]
    pub hostname: Option<String>,
    pub description: Option<String>,
    pub virtualization: Option<HostVirtualization>,
    #[serde(default)]
    pub hidden: bool,
    #[serde(default)]
    pub tags: Vec<Uuid>,
    /// Interfaces to create with this host
    #[serde(default)]
    pub interfaces: Vec<InterfaceInput>,
    /// Ports to create with this host
    #[serde(default)]
    pub ports: Vec<PortInput>,
    /// Services to create with this host (can reference interfaces/ports by ID)
    #[serde(default)]
    pub services: Vec<ServiceInput>,
}
```

### 1.3 Update UpdateHostRequest

```rust
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema, Validate)]
pub struct UpdateHostRequest {
    pub id: Uuid,
    #[validate(length(min = 1, max = 255))]
    pub name: String,
    #[validate(length(max = 255))]
    pub hostname: Option<String>,
    pub description: Option<String>,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    #[serde(default)]
    pub tags: Vec<Uuid>,
    /// For optimistic locking
    pub expected_updated_at: Option<DateTime<Utc>>,
    /// Interfaces to sync (create/update/delete)
    #[serde(default)]
    pub interfaces: Vec<InterfaceInput>,
    /// Ports to sync (create/update/delete)
    #[serde(default)]
    pub ports: Vec<PortInput>,
    /// Services to sync (create/update/delete)
    #[serde(default)]
    pub services: Vec<ServiceInput>,
}
```

### 1.4 Add conversion methods

```rust
impl InterfaceInput {
    pub fn into_interface(self, host_id: Uuid, network_id: Uuid) -> Interface {
        Interface {
            id: self.id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: InterfaceBase {
                host_id,
                network_id,
                subnet_id: self.subnet_id,
                ip_address: self.ip_address,
                mac_address: self.mac_address,
                name: self.name,
                position: self.position,
            },
        }
    }
}

impl PortInput {
    pub fn into_port(self, host_id: Uuid, network_id: Uuid) -> Port {
        Port {
            id: self.id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: PortBase {
                host_id,
                network_id,
                port_type: PortType::Custom(PortConfig {
                    number: self.number,
                    protocol: self.protocol,
                }),
            },
        }
    }
}

impl ServiceInput {
    pub fn into_service(self, host_id: Uuid, network_id: Uuid, source: EntitySource) -> Service {
        let bindings = self.bindings
            .into_iter()
            .map(|b| b.into_binding(self.id, network_id))
            .collect();

        Service {
            id: self.id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                network_id,
                service_definition: self.service_definition,
                name: self.name,
                bindings,
                virtualization: self.virtualization,
                source,
                tags: self.tags,
                position: self.position,
            },
        }
    }
}

impl BindingInput {
    pub fn into_binding(self, service_id: Uuid, network_id: Uuid) -> Binding {
        let (id, binding_type) = match self {
            BindingInput::Interface { id, interface_id } => {
                (id, BindingType::Interface { interface_id })
            }
            BindingInput::Port { id, port_id, interface_id } => {
                (id, BindingType::Port { port_id, interface_id })
            }
        };

        Binding {
            id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: BindingBase {
                service_id,
                network_id,
                binding_type,
            },
        }
    }
}
```

### 1.5 Remove old types

Delete from `hosts/impl/api.rs`:
- `CreateInterfaceInput`
- `CreatePortInput`
- `UpdateInterfaceInput`
- `UpdatePortInput`
- `UpdateServiceInput`
- `UpdateBindingInput`

---

## Phase 2: ID Collision Validation

### 2.1 Add existence check methods to services

**File:** `backend/src/server/shared/services/traits.rs`

```rust
/// Check if any of the given IDs exist
async fn any_exist(&self, ids: &[Uuid]) -> Result<bool, Error> {
    if ids.is_empty() {
        return Ok(false);
    }
    for id in ids {
        if self.get_by_id(id).await?.is_some() {
            return Ok(true);
        }
    }
    Ok(false)
}

/// Get IDs that exist from the given list
async fn filter_existing(&self, ids: &[Uuid]) -> Result<HashSet<Uuid>, Error> {
    let mut existing = HashSet::new();
    for id in ids {
        if self.get_by_id(id).await?.is_some() {
            existing.insert(*id);
        }
    }
    Ok(existing)
}
```

### 2.2 Add validation to CreateHostRequest handler

**File:** `backend/src/server/hosts/service.rs`

```rust
impl HostService {
    /// Validate that no client-provided IDs already exist in the database
    async fn validate_create_ids_unique(&self, request: &CreateHostRequest) -> Result<()> {
        // Collect all IDs
        let interface_ids: Vec<Uuid> = request.interfaces.iter().map(|i| i.id).collect();
        let port_ids: Vec<Uuid> = request.ports.iter().map(|p| p.id).collect();
        let service_ids: Vec<Uuid> = request.services.iter().map(|s| s.id).collect();
        let binding_ids: Vec<Uuid> = request.services
            .iter()
            .flat_map(|s| s.bindings.iter().map(|b| b.id()))
            .collect();

        // Check for duplicates within request
        let mut seen = HashSet::new();
        for id in interface_ids.iter()
            .chain(port_ids.iter())
            .chain(service_ids.iter())
            .chain(binding_ids.iter())
        {
            if !seen.insert(id) {
                return Err(ValidationError::new(
                    format!("Duplicate ID in request: {}", id)
                ).into());
            }
        }

        // Check against database
        if self.interface_service.any_exist(&interface_ids).await? {
            return Err(ValidationError::new(
                "One or more interface IDs already exist"
            ).into());
        }
        if self.port_service.any_exist(&port_ids).await? {
            return Err(ValidationError::new(
                "One or more port IDs already exist"
            ).into());
        }
        if self.service_service.any_exist(&service_ids).await? {
            return Err(ValidationError::new(
                "One or more service IDs already exist"
            ).into());
        }
        if self.binding_service.any_exist(&binding_ids).await? {
            return Err(ValidationError::new(
                "One or more binding IDs already exist"
            ).into());
        }

        Ok(())
    }
}
```

### 2.3 Add validation to UpdateHostRequest handler

```rust
impl HostService {
    /// Validate IDs in update request:
    /// - Existing IDs must belong to this host
    /// - New IDs must not exist anywhere
    async fn validate_update_ids(&self, host_id: &Uuid, request: &UpdateHostRequest) -> Result<()> {
        // Get existing entities for this host
        let existing_interfaces = self.interface_service.get_for_host(host_id).await?;
        let existing_ports = self.port_service.get_for_host(host_id).await?;
        let existing_services = self.service_service.get_for_parent(host_id).await?;

        let host_interface_ids: HashSet<Uuid> = existing_interfaces.iter().map(|i| i.id).collect();
        let host_port_ids: HashSet<Uuid> = existing_ports.iter().map(|p| p.id).collect();
        let host_service_ids: HashSet<Uuid> = existing_services.iter().map(|s| s.id).collect();
        let host_binding_ids: HashSet<Uuid> = existing_services
            .iter()
            .flat_map(|s| s.base.bindings.iter().map(|b| b.id()))
            .collect();

        // Check each input ID
        for input in &request.interfaces {
            if !host_interface_ids.contains(&input.id) {
                // Not on this host - check if exists elsewhere
                if self.interface_service.get_by_id(&input.id).await?.is_some() {
                    return Err(ValidationError::new(
                        format!("Interface {} belongs to another host", input.id)
                    ).into());
                }
            }
        }

        for input in &request.ports {
            if !host_port_ids.contains(&input.id) {
                if self.port_service.get_by_id(&input.id).await?.is_some() {
                    return Err(ValidationError::new(
                        format!("Port {} belongs to another host", input.id)
                    ).into());
                }
            }
        }

        for input in &request.services {
            if !host_service_ids.contains(&input.id) {
                if self.service_service.get_by_id(&input.id).await?.is_some() {
                    return Err(ValidationError::new(
                        format!("Service {} belongs to another host", input.id)
                    ).into());
                }
            }

            for binding in &input.bindings {
                let binding_id = binding.id();
                if !host_binding_ids.contains(&binding_id) {
                    if self.binding_service.get_by_id(&binding_id).await?.is_some() {
                        return Err(ValidationError::new(
                            format!("Binding {} belongs to another service", binding_id)
                        ).into());
                    }
                }
            }
        }

        Ok(())
    }
}
```

---

## Phase 3: Update Host Service Methods

### 3.1 Update create_from_request

**File:** `backend/src/server/hosts/service.rs`

```rust
pub async fn create_from_request(
    &self,
    request: CreateHostRequest,
    authentication: AuthenticatedEntity,
) -> Result<HostResponse> {
    // Validate all IDs are unique
    self.validate_create_ids_unique(&request).await?;

    // Validate positions
    validate_input_positions(&request.interfaces, "interface")?;
    validate_input_positions(&request.services, "service")?;

    let network_id = request.network_id;

    // Create host
    let host = Host::new(HostBase {
        name: request.name,
        network_id,
        hostname: request.hostname,
        description: request.description,
        source: EntitySource::Manual,
        virtualization: request.virtualization,
        hidden: request.hidden,
        tags: request.tags,
    });
    let created_host = self.create(host, authentication.clone()).await?;

    // Create interfaces (with client-provided IDs)
    let mut created_interfaces = Vec::new();
    for input in request.interfaces {
        let interface = input.into_interface(created_host.id, network_id);
        let created = self.interface_service.create(interface, authentication.clone()).await?;
        created_interfaces.push(created);
    }

    // Create ports (with client-provided IDs)
    let mut created_ports = Vec::new();
    for input in request.ports {
        let port = input.into_port(created_host.id, network_id);
        let created = self.port_service.create(port, authentication.clone()).await?;
        created_ports.push(created);
    }

    // Create services (with client-provided IDs, bindings reference interfaces/ports)
    let mut created_services = Vec::new();
    for input in request.services {
        let service = input.into_service(created_host.id, network_id, EntitySource::Manual);
        let created = self.service_service.create(service, authentication.clone()).await?;
        created_services.push(created);
    }

    Ok(HostResponse::from_host_with_children(
        created_host,
        created_interfaces,
        created_ports,
        created_services,
    ))
}
```

### 3.2 Update sync methods to preserve IDs

Update `sync_interfaces`, `sync_ports`, `sync_services` to:
1. Use client-provided IDs
2. Preserve `created_at` for existing entities
3. Check ID ownership before update

---

## Phase 4: Frontend Changes

### 4.1 Update UUID generation

**File:** `ui/src/lib/shared/utils/formatting.ts`

```typescript
// Remove sentinel
// export const uuidv4Sentinel: string = '00000000-0000-0000-0000-000000000000';

// Add real UUID generator (use crypto.randomUUID or uuid library)
export function generateId(): string {
    return crypto.randomUUID();
}
```

### 4.2 Update entity creation

**File:** `ui/src/lib/features/hosts/queries.ts`

```typescript
export function createEmptyHostFormData(defaultNetworkId?: string): HostFormData {
    return {
        id: generateId(),  // Real UUID instead of sentinel
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        name: '',
        // ...
    };
}
```

### 4.3 Update mutation to send binding IDs

```typescript
const toBindingInput = (binding: Service['bindings'][0]): BindingInput => {
    if (binding.type === 'Interface') {
        return {
            type: 'Interface',
            id: binding.id,  // Include binding ID
            interface_id: binding.interface_id
        };
    } else {
        return {
            type: 'Port',
            id: binding.id,  // Include binding ID
            port_id: binding.port_id,
            interface_id: binding.interface_id ?? undefined
        };
    }
};
```

### 4.4 Update type exports

**File:** `ui/src/lib/features/hosts/types/base.ts`

```typescript
// Consolidated input types
export type InterfaceInput = components['schemas']['InterfaceInput'];
export type PortInput = components['schemas']['PortInput'];
export type ServiceInput = components['schemas']['ServiceInput'];
export type BindingInput = components['schemas']['BindingInput'];
```

### 4.5 Remove "unsaved entity" restrictions

**File:** `ui/src/lib/features/hosts/components/HostEditModal/Services/ServiceConfigPanel.svelte`

Remove the `isInterfaceUnsaved` / `isPortUnsaved` checks since all entities now have valid IDs:

```typescript
// Before: filtered out unsaved
let availablePortCombinations = $derived(
    host.interfaces
        .filter((iface) => !isInterfaceUnsaved(iface.id))  // REMOVE
        // ...
);

// After: all interfaces available
let availablePortCombinations = $derived(
    host.interfaces.flatMap((iface) => {
        // ... no unsaved filtering needed
    })
);
```

---

## Phase 5: Testing

### 5.1 Backend integration tests

Add tests for:
- Create host with services and bindings in single request
- ID collision detection (duplicate in request)
- ID collision detection (exists in DB)
- ID ownership validation (belongs to different host)
- Binding ID preservation across updates

### 5.2 Frontend tests

- Verify real UUIDs generated
- Verify binding to new interface/port in same save works
- Verify binding IDs preserved on update

---

## Migration Notes

### Breaking Changes

1. **API Types Changed:**
   - `CreateInterfaceInput` → `InterfaceInput`
   - `CreatePortInput` → `PortInput`
   - `UpdateInterfaceInput` → `InterfaceInput`
   - `UpdatePortInput` → `PortInput`
   - `UpdateServiceInput` → `ServiceInput`
   - `UpdateBindingInput` → `BindingInput`

2. **ID Now Required:**
   - All input types require `id: Uuid`
   - Clients must generate UUIDs

3. **Services in CreateHostRequest:**
   - New field: `services: Vec<ServiceInput>`

### For API Consumers

```bash
# Old way (no longer works)
curl -X POST /api/v1/hosts -d '{"name": "...", "interfaces": [{"subnet_id": "..."}]}'

# New way (ID required)
curl -X POST /api/v1/hosts -d '{"name": "...", "interfaces": [{"id": "'$(uuidgen)'", "subnet_id": "..."}]}'
```

---

## File Change Summary

| File | Changes |
|------|---------|
| `backend/src/server/hosts/impl/api.rs` | Replace 6 types with 4 consolidated types |
| `backend/src/server/hosts/service.rs` | Add validation, update create/sync methods |
| `backend/src/server/shared/services/traits.rs` | Add `any_exist`, `filter_existing` |
| `ui/src/lib/shared/utils/formatting.ts` | Add `generateId()`, remove sentinel |
| `ui/src/lib/features/hosts/queries.ts` | Update mutations, send binding IDs |
| `ui/src/lib/features/hosts/types/base.ts` | Update type exports |
| `ui/src/lib/features/hosts/components/.../ServiceConfigPanel.svelte` | Remove unsaved entity restrictions |
