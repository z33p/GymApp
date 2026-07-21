SET search_path TO gymapp, public;

CREATE TABLE gymapp.group_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES gymapp.groups(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  post_type gymapp.post_type NOT NULL,
  activity_claim_id uuid UNIQUE REFERENCES gymapp.activity_claims(id) ON DELETE RESTRICT,
  body text CHECK (char_length(body) <= 4000),
  pinned_at timestamptz,
  pinned_by uuid REFERENCES gymapp.user_profiles(id) ON DELETE SET NULL,
  removed_at timestamptz,
  removed_by uuid REFERENCES gymapp.user_profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((post_type = 'activity') = (activity_claim_id IS NOT NULL)),
  CHECK (post_type = 'activity' OR char_length(btrim(coalesce(body, ''))) > 0),
  CHECK ((removed_at IS NULL) = (removed_by IS NULL))
);

CREATE INDEX group_posts_visible_feed_idx
ON gymapp.group_posts(group_id, pinned_at DESC NULLS LAST, created_at DESC)
WHERE removed_at IS NULL;

CREATE TRIGGER group_posts_set_updated_at
BEFORE UPDATE ON gymapp.group_posts
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

CREATE OR REPLACE FUNCTION gymapp.ensure_post_author_is_member()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  claim_group_id uuid;
BEGIN
  PERFORM 1 FROM gymapp.group_memberships
  WHERE group_id = NEW.group_id AND user_id = NEW.author_id AND status = 'active';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'post author must be an active group member' USING ERRCODE = 'foreign_key_violation';
  END IF;

  IF NEW.activity_claim_id IS NOT NULL THEN
    SELECT seasons.group_id INTO claim_group_id
    FROM gymapp.activity_claims claims
    JOIN gymapp.group_seasons seasons ON seasons.id = claims.season_id
    WHERE claims.id = NEW.activity_claim_id AND claims.user_id = NEW.author_id;
    IF claim_group_id IS DISTINCT FROM NEW.group_id THEN
      RAISE EXCEPTION 'activity post must reference the author claim from the same group' USING ERRCODE = 'foreign_key_violation';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER group_posts_validate_before_insert
BEFORE INSERT ON gymapp.group_posts
FOR EACH ROW EXECUTE FUNCTION gymapp.ensure_post_author_is_member();

CREATE TABLE gymapp.post_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES gymapp.group_posts(id) ON DELETE CASCADE,
  storage_key text NOT NULL CHECK (char_length(btrim(storage_key)) BETWEEN 1 AND 1024),
  content_type text NOT NULL CHECK (char_length(btrim(content_type)) BETWEEN 3 AND 100),
  sort_order smallint NOT NULL DEFAULT 0 CHECK (sort_order BETWEEN 0 AND 20),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (post_id, sort_order)
);

CREATE TABLE gymapp.post_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES gymapp.group_posts(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 2000),
  removed_at timestamptz,
  removed_by uuid REFERENCES gymapp.user_profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((removed_at IS NULL) = (removed_by IS NULL))
);

CREATE INDEX post_comments_visible_idx ON gymapp.post_comments(post_id, created_at) WHERE removed_at IS NULL;

CREATE TRIGGER post_comments_set_updated_at
BEFORE UPDATE ON gymapp.post_comments
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

CREATE OR REPLACE FUNCTION gymapp.ensure_comment_author_is_member()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM 1
  FROM gymapp.group_posts posts
  JOIN gymapp.group_memberships memberships ON memberships.group_id = posts.group_id
  WHERE posts.id = NEW.post_id
    AND memberships.user_id = NEW.author_id
    AND memberships.status = 'active';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'comment author must be an active group member' USING ERRCODE = 'foreign_key_violation';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER post_comments_validate_before_insert
BEFORE INSERT ON gymapp.post_comments
FOR EACH ROW EXECUTE FUNCTION gymapp.ensure_comment_author_is_member();

CREATE TABLE gymapp.post_reactions (
  post_id uuid NOT NULL REFERENCES gymapp.group_posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE CASCADE,
  reaction gymapp.reaction_type NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id, reaction)
);

CREATE TABLE gymapp.group_moderation_actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES gymapp.groups(id) ON DELETE CASCADE,
  moderator_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  target_post_id uuid REFERENCES gymapp.group_posts(id) ON DELETE SET NULL,
  target_comment_id uuid REFERENCES gymapp.post_comments(id) ON DELETE SET NULL,
  action text NOT NULL CHECK (action IN ('remove', 'restore', 'pin', 'unpin', 'ban', 'unban')),
  reason text CHECK (char_length(reason) <= 1000),
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (target_post_id IS NOT NULL OR target_comment_id IS NOT NULL OR action IN ('ban', 'unban'))
);

CREATE INDEX group_moderation_actions_group_idx ON gymapp.group_moderation_actions(group_id, created_at DESC);

-- API middleware must execute SET LOCAL app.user_id = '<authenticated GymApp UUID>' in each transaction.
CREATE OR REPLACE FUNCTION gymapp.current_user_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(current_setting('app.user_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION gymapp.is_active_member(target_group_id uuid, target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = gymapp, public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM gymapp.group_memberships
    WHERE group_id = target_group_id AND user_id = target_user_id AND status = 'active'
  );
$$;

CREATE OR REPLACE FUNCTION gymapp.is_group_moderator(target_group_id uuid, target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = gymapp, public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM gymapp.group_memberships
    WHERE group_id = target_group_id AND user_id = target_user_id
      AND status = 'active' AND role IN ('owner', 'moderator')
  );
$$;

CREATE OR REPLACE FUNCTION gymapp.post_group_id(target_post_id uuid)
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = gymapp, public
AS $$
  SELECT group_id FROM gymapp.group_posts WHERE id = target_post_id;
$$;

CREATE OR REPLACE FUNCTION gymapp.ensure_moderation_actor()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT gymapp.is_group_moderator(NEW.group_id, NEW.moderator_id) THEN
    RAISE EXCEPTION 'moderation actor must be an active owner or moderator' USING ERRCODE = 'foreign_key_violation';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER group_moderation_actions_validate_before_insert
BEFORE INSERT ON gymapp.group_moderation_actions
FOR EACH ROW EXECUTE FUNCTION gymapp.ensure_moderation_actor();

CREATE OR REPLACE FUNCTION gymapp.shares_active_group(target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = gymapp, public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM gymapp.group_memberships mine
    JOIN gymapp.group_memberships theirs ON theirs.group_id = mine.group_id
    WHERE mine.user_id = gymapp.current_user_id() AND mine.status = 'active'
      AND theirs.user_id = target_user_id AND theirs.status = 'active'
  );
$$;

ALTER TABLE gymapp.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.auth_identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.group_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.group_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.group_seasons ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.activity_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.fauna_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.group_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.post_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.post_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymapp.group_moderation_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_read_shared ON gymapp.user_profiles FOR SELECT
USING (id = gymapp.current_user_id() OR gymapp.shares_active_group(id));
CREATE POLICY profiles_insert_self ON gymapp.user_profiles FOR INSERT
WITH CHECK (id = gymapp.current_user_id());
CREATE POLICY profiles_update_self ON gymapp.user_profiles FOR UPDATE
USING (id = gymapp.current_user_id()) WITH CHECK (id = gymapp.current_user_id());

CREATE POLICY identities_read_self ON gymapp.auth_identities FOR SELECT
USING (user_id = gymapp.current_user_id());

CREATE POLICY groups_read_member ON gymapp.groups FOR SELECT
USING (gymapp.is_active_member(id, gymapp.current_user_id()));
CREATE POLICY memberships_read_member ON gymapp.group_memberships FOR SELECT
USING (gymapp.is_active_member(group_id, gymapp.current_user_id()));
CREATE POLICY invites_read_moderator ON gymapp.group_invites FOR SELECT
USING (gymapp.is_group_moderator(group_id, gymapp.current_user_id()));
CREATE POLICY seasons_read_member ON gymapp.group_seasons FOR SELECT
USING (gymapp.is_active_member(group_id, gymapp.current_user_id()));

CREATE POLICY claims_read_member ON gymapp.activity_claims FOR SELECT
USING (
  user_id = gymapp.current_user_id()
  OR EXISTS (
    SELECT 1 FROM gymapp.group_seasons seasons
    WHERE seasons.id = gymapp.activity_claims.season_id
      AND gymapp.is_active_member(seasons.group_id, gymapp.current_user_id())
  )
);
CREATE POLICY claims_insert_self ON gymapp.activity_claims FOR INSERT
WITH CHECK (user_id = gymapp.current_user_id());

CREATE POLICY fauna_read_self ON gymapp.fauna_progress FOR SELECT
USING (user_id = gymapp.current_user_id());
CREATE POLICY fauna_insert_self ON gymapp.fauna_progress FOR INSERT
WITH CHECK (user_id = gymapp.current_user_id());
CREATE POLICY fauna_update_self ON gymapp.fauna_progress FOR UPDATE
USING (user_id = gymapp.current_user_id()) WITH CHECK (user_id = gymapp.current_user_id());

CREATE POLICY posts_read_visible_member ON gymapp.group_posts FOR SELECT
USING (removed_at IS NULL AND gymapp.is_active_member(group_id, gymapp.current_user_id()));
CREATE POLICY posts_insert_self ON gymapp.group_posts FOR INSERT
WITH CHECK (author_id = gymapp.current_user_id() AND gymapp.is_active_member(group_id, gymapp.current_user_id()));
CREATE POLICY media_read_member ON gymapp.post_media FOR SELECT
USING (gymapp.is_active_member(gymapp.post_group_id(post_id), gymapp.current_user_id()));
CREATE POLICY comments_read_visible_member ON gymapp.post_comments FOR SELECT
USING (removed_at IS NULL AND gymapp.is_active_member(gymapp.post_group_id(post_id), gymapp.current_user_id()));
CREATE POLICY comments_insert_self ON gymapp.post_comments FOR INSERT
WITH CHECK (author_id = gymapp.current_user_id() AND gymapp.is_active_member(gymapp.post_group_id(post_id), gymapp.current_user_id()));
CREATE POLICY reactions_read_member ON gymapp.post_reactions FOR SELECT
USING (gymapp.is_active_member(gymapp.post_group_id(post_id), gymapp.current_user_id()));
CREATE POLICY reactions_insert_self ON gymapp.post_reactions FOR INSERT
WITH CHECK (user_id = gymapp.current_user_id() AND gymapp.is_active_member(gymapp.post_group_id(post_id), gymapp.current_user_id()));
CREATE POLICY reactions_delete_self ON gymapp.post_reactions FOR DELETE
USING (user_id = gymapp.current_user_id());
CREATE POLICY moderation_read_moderator ON gymapp.group_moderation_actions FOR SELECT
USING (gymapp.is_group_moderator(group_id, gymapp.current_user_id()));

COMMENT ON FUNCTION gymapp.current_user_id() IS 'Set app.user_id with SET LOCAL for every API transaction; no value means no rows through RLS.';
