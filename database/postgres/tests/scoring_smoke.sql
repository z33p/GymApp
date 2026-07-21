\set ON_ERROR_STOP on
BEGIN;
SET search_path TO gymapp, public;

INSERT INTO user_profiles (id, display_name) VALUES
  ('10000000-0000-0000-0000-000000000001', 'Owner'),
  ('10000000-0000-0000-0000-000000000002', 'Member');
INSERT INTO groups (id, owner_id, slug, name) VALUES
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'smoke-group', 'Smoke group');
INSERT INTO group_memberships (group_id, user_id, role) VALUES
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'owner'),
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'member');
INSERT INTO group_seasons (
  id, group_id, created_by, name, status, metric, minimum_value, maximum_value,
  daily_event_limit, accepted_sources, timezone, starts_at, ends_at
) VALUES (
  '30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', 'Smoke season', 'active', 'minutes', 2, 10,
  2, ARRAY['synced']::activity_source[], 'UTC', now() - interval '1 day', now() + interval '1 day'
);

INSERT INTO activity_claims (season_id, user_id, source, source_reference, occurred_at, raw_value) VALUES
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'synced', 'too-small', now(), 1),
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'synced', 'capped', now(), 12),
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'synced', 'credited', now(), 3),
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'synced', 'daily-cap', now(), 3),
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'check_in', 'not-accepted', now(), 3);

DO $$
BEGIN
  IF (SELECT status FROM activity_claims WHERE source_reference = 'too-small') <> 'below_minimum' THEN
    RAISE EXCEPTION 'minimum rule was not enforced';
  END IF;
  IF (SELECT credited_value FROM activity_claims WHERE source_reference = 'capped') <> 10 THEN
    RAISE EXCEPTION 'maximum rule was not enforced';
  END IF;
  IF (SELECT status FROM activity_claims WHERE source_reference = 'daily-cap') <> 'daily_limit' THEN
    RAISE EXCEPTION 'daily limit was not enforced';
  END IF;
  IF (SELECT status FROM activity_claims WHERE source_reference = 'not-accepted') <> 'source_not_allowed' THEN
    RAISE EXCEPTION 'source rule was not enforced';
  END IF;
  IF (SELECT total_credited FROM season_leaderboard WHERE user_id = '10000000-0000-0000-0000-000000000002') <> 13 THEN
    RAISE EXCEPTION 'leaderboard total is wrong';
  END IF;
  BEGIN
    INSERT INTO activity_claims (season_id, user_id, source, source_reference, occurred_at, raw_value)
    VALUES ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'synced', 'capped', now(), 3);
    RAISE EXCEPTION 'idempotency rule was not enforced';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    UPDATE group_seasons SET maximum_value = 99 WHERE id = '30000000-0000-0000-0000-000000000001';
    RAISE EXCEPTION 'season immutability was not enforced';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END;
$$;

ROLLBACK;
