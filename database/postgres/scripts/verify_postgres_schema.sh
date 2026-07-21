#!/usr/bin/env bash
set -euo pipefail

database_url="${DATABASE_URL:-${1:-}}"
if [[ -z "$database_url" ]]; then
  echo "Set DATABASE_URL or pass it as the first argument." >&2
  exit 1
fi
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$script_dir/apply_postgres_migrations.sh" "$database_url"
psql "$database_url" --set ON_ERROR_STOP=1 --file "$script_dir/../tests/scoring_smoke.sql"
echo 'PostgreSQL schema verified; smoke test transaction rolled back.'
