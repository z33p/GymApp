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
  IF (SELECT raw_value FROM activity_claims WHERE source_reference = 'capped') <> 12 THEN
    RAISE EXCEPTION 'raw value was not preserved';
  END IF;
  IF (SELECT credited_value FROM activity_claims WHERE source_reference = 'capped') <> 10 THEN
    RAISE EXCEPTION 'maximum rule was not enforced';
  END IF;
  IF (SELECT credited_value FROM activity_claims WHERE source_reference IN ('too-small', 'daily-cap', 'not-accepted') AND credited_value <> 0) THEN
    RAISE EXCEPTION 'non-credited claim received points';
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

INSERT INTO group_posts (id, group_id, author_id, post_type, activity_claim_id) VALUES
  ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000002', 'activity',
   (SELECT id FROM activity_claims WHERE source_reference = 'capped'));
INSERT INTO post_comments (id, post_id, author_id, body) VALUES
  ('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001', 'Nice work');
INSERT INTO post_reactions (post_id, user_id, reaction) VALUES
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'fire');
SELECT gymapp.moderate_post(
  '40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'remove', 'Moderation smoke test'
);
SELECT gymapp.moderate_comment(
  '50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'remove', 'Comment moderation smoke test'
);
INSERT INTO group_posts (id, group_id, author_id, post_type, body) VALUES
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000002', 'conversation', 'Visible accountability post');

DO $$
BEGIN
  IF (SELECT count(*) FROM post_comments WHERE post_id = '40000000-0000-0000-0000-000000000001') <> 1 THEN
    RAISE EXCEPTION 'comment relation was not created';
  END IF;
  IF (SELECT count(*) FROM post_reactions WHERE post_id = '40000000-0000-0000-0000-000000000001') <> 1 THEN
    RAISE EXCEPTION 'reaction uniqueness relation was not created';
  END IF;
  IF (SELECT removed_at IS NULL FROM group_posts WHERE id = '40000000-0000-0000-0000-000000000001') THEN
    RAISE EXCEPTION 'post removal was not applied';
  END IF;
  IF (SELECT count(*) FROM group_moderation_actions WHERE target_post_id = '40000000-0000-0000-0000-000000000001' AND action = 'remove') <> 1 THEN
    RAISE EXCEPTION 'post removal did not create moderation audit trail';
  END IF;
  IF (SELECT count(*) FROM group_moderation_actions WHERE target_comment_id = '50000000-0000-0000-0000-000000000001' AND action = 'remove') <> 1 THEN
    RAISE EXCEPTION 'comment removal did not create moderation audit trail';
  END IF;
  IF (SELECT count(*) FROM pg_policies WHERE schemaname = 'gymapp') < 22 THEN
    RAISE EXCEPTION 'expected row-level security policies are missing';
  END IF;
  IF (SELECT count(*) FROM pg_class tables JOIN pg_namespace namespaces ON namespaces.oid = tables.relnamespace
      WHERE namespaces.nspname = 'gymapp' AND tables.relkind = 'r' AND tables.relrowsecurity) < 13 THEN
    RAISE EXCEPTION 'expected row-level security is not enabled on all remote tables';
  END IF;
END;
$$;

CREATE ROLE gymapp_smoke_client NOLOGIN;
GRANT gymapp_smoke_client TO CURRENT_USER;
GRANT USAGE ON SCHEMA gymapp TO gymapp_smoke_client;
GRANT SELECT ON gymapp.groups, gymapp.group_memberships, gymapp.group_posts TO gymapp_smoke_client;

SET LOCAL ROLE gymapp_smoke_client;
SELECT set_config('app.user_id', '10000000-0000-0000-0000-000000000001', true);
DO $$
BEGIN
  IF (SELECT count(*) FROM gymapp.group_posts) <> 1 THEN
    RAISE EXCEPTION 'group member could not see exactly the visible post';
  END IF;
  IF (SELECT count(*) FROM gymapp.groups) <> 1 THEN
    RAISE EXCEPTION 'active member could not read own group';
  END IF;
END;
$$;

SELECT set_config('app.user_id', '10000000-0000-0000-0000-000000000099', true);
DO $$
BEGIN
  IF (SELECT count(*) FROM gymapp.groups) <> 0 OR (SELECT count(*) FROM gymapp.group_posts) <> 0 THEN
    RAISE EXCEPTION 'non-member can read private group content';
  END IF;
END;
$$;
RESET ROLE;

ROLLBACK;
