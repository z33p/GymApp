# PostgreSQL Social Schema Tasks

## Test coverage matrix

| Layer | Required verification | Location | Gate |
| --- | --- | --- | --- |
| DDL base | Apply on empty PostgreSQL | `database/postgres/migrations` | `apply_postgres_migrations` |
| Scoring trigger | Minimum, cap, daily limit, source and duplicate cases | `database/postgres/tests/schema_smoke.sql` | `verify_postgres_schema` |
| RLS | Session can see only own private group | `database/postgres/tests/schema_smoke.sql` | `verify_postgres_schema` |
| Scripts | Windows and POSIX syntax/help | `database/postgres/scripts` | PowerShell parser / `bash -n` |

## Tasks

### T1 — Specification and database layout
**Requirements:** PG-01  
**Done when:** spec, design and task traceability exist; migration directory is documented.  
**Gate:** Markdown links and paths reviewed.  
**Commit:** `docs(database): specify postgres social schema`

### T2 — Identity, groups and seasons
**Requirements:** PG-01, PG-02  
**Done when:** base migration creates portable UUID/types, profiles, identities, groups, memberships, invitations and immutable-rule season fields.  
**Gate:** PostgreSQL apply or SQL parser.  
**Commit:** `feat(database): add postgres identity and groups schema`

### T3 — Claims, ranking and fauna
**Requirements:** PG-03, PG-04  
**Done when:** score trigger enforces source/min/max/daily rules and duplicate keys; ranking view and fauna state exist.  
**Gate:** smoke test exercises each score outcome.  
**Commit:** `feat(database): add scoring and leaderboard schema`

### T4 — Mural, moderation and row-level security
**Requirements:** PG-05, PG-06  
**Done when:** posts/comments/reactions/moderation and session-bound RLS policies exist.  
**Gate:** smoke test proves private-group isolation.  
**Commit:** `feat(database): add social security schema`

### T5 — Developer scripts and verification
**Requirements:** PG-01, PG-06  
**Done when:** documented PowerShell/POSIX migration runners and rollback-based smoke test exist.  
**Gate:** parser checks plus full database smoke test when PostgreSQL is available.  
**Commit:** `docs(database): add postgres setup scripts`
