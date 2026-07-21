# PostgreSQL Social Schema Validation

**Date:** 2026-07-21
**Spec:** `.specs/features/postgres-social-schema/spec.md`
**Diff range:** `f8d6c1a..7dfc78d`
**Verifier:** independent verifier
**Status:** PASS (static); runtime gate pending environment

## Requirement results

| Requirement | Result | Evidence |
| --- | --- | --- |
| PG-01 | PASS static | Migrations `001`–`004` are ordered; the PowerShell runner targets `database/postgres/migrations`. |
| PG-02 | PASS static | Unique `(provider, subject)`, foreign keys, memberships, invites and seasons are defined in `002_identity_groups.sql`. |
| PG-03 | PASS static | The claim trigger enforces source/minimum/cap/daily rules; smoke asserts raw `12`, cap `10` and zero credit in non-credited statuses. |
| PG-04 | PASS static | `fauna_progress` and `season_leaderboard` exist; smoke asserts a total of `13`. |
| PG-05 | PASS static | Membership validation, removal-hiding policies and audited `moderate_post`/`moderate_comment` functions are covered by smoke assertions. |
| PG-06 | PASS static | RLS smoke switches to a no-login client role and verifies member, non-member and empty-session access to groups, posts, comments and claims. |

## Discrimination sensor

- Mutation: reintroduce `user_id = current_user_id() OR EXISTS (...)` in `claims_read_member`.
- Expected: a former/inactive member cannot read claims.
- Result: killed — the real policy accepts only active-membership `EXISTS`; the mutant reintroduces the forbidden self-read path.

## Gate evidence and limitation

- PowerShell scripts parsed successfully; static migration-layout checks passed.
- `psql`, Docker and Bash are absent on this Windows machine.
- PostgreSQL application and the runtime smoke test were not executed. Run `database/postgres/scripts/verify_postgres_schema.ps1` against PostgreSQL 15+ with a development credential that has `CREATEROLE` before Flutter integration.
