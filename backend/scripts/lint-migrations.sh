#!/usr/bin/env bash
# Lint migrations dated 20260501 onward with squawk. Earlier migrations predate
# the Scanopy safety guidelines and are intentionally excluded — do not expand
# this cutoff without updating CLAUDE.md.
set -euo pipefail

CUTOFF="20260501"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"
CONFIG_PATH="$SCRIPT_DIR/../../.squawk.toml"

if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "lint-migrations: migrations directory not found: $MIGRATIONS_DIR" >&2
    exit 1
fi

files=()
for f in "$MIGRATIONS_DIR"/*.sql; do
    [ -e "$f" ] || continue
    name="$(basename "$f")"
    prefix="${name:0:8}"
    case "$prefix" in
        [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
        *) continue ;;
    esac
    if [[ "$prefix" > "$CUTOFF" ]] || [[ "$prefix" == "$CUTOFF" ]]; then
        files+=("$f")
    fi
done

if [ ${#files[@]} -eq 0 ]; then
    echo "No post-$CUTOFF migrations to lint."
    exit 0
fi

if ! command -v squawk >/dev/null 2>&1; then
    echo "lint-migrations: squawk not found on PATH. Install with: npm install -g squawk-cli" >&2
    exit 1
fi

exec squawk --config "$CONFIG_PATH" "${files[@]}"
