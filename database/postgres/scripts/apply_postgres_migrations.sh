#!/usr/bin/env bash
set -euo pipefail

database_url="${DATABASE_URL:-${1:-}}"
if [[ -z "$database_url" ]]; then
  echo "Set DATABASE_URL or pass it as the first argument." >&2
  exit 1
fi
command -v psql >/dev/null || { echo "psql is required." >&2; exit 1; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
migrations_dir="$script_dir/../migrations"
psql "$database_url" --set ON_ERROR_STOP=1 --command 'CREATE SCHEMA IF NOT EXISTS gymapp; CREATE TABLE IF NOT EXISTS gymapp.schema_migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());'

for migration in "$migrations_dir"/*.sql; do
  name="$(basename "$migration")"
  if [[ "$(psql "$database_url" --tuples-only --no-align --command "SELECT 1 FROM gymapp.schema_migrations WHERE name = '$name';")" == "1" ]]; then
    echo "[skip] $name"
    continue
  fi
  echo "[apply] $name"
  psql "$database_url" --set ON_ERROR_STOP=1 --single-transaction --file "$migration"
  psql "$database_url" --set ON_ERROR_STOP=1 --command "INSERT INTO gymapp.schema_migrations (name) VALUES ('$name');"
done

echo 'PostgreSQL GymApp updated.'
