SET search_path TO gymapp, public;

CREATE TABLE gymapp.user_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name text NOT NULL CHECK (char_length(btrim(display_name)) BETWEEN 1 AND 80),
  avatar_url text,
  faction gymapp.faction,
  timezone text NOT NULL DEFAULT 'UTC',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER user_profiles_set_updated_at
BEFORE UPDATE ON gymapp.user_profiles
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

CREATE TABLE gymapp.auth_identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE CASCADE,
  provider gymapp.identity_provider NOT NULL,
  subject text NOT NULL CHECK (char_length(btrim(subject)) BETWEEN 1 AND 255),
  email text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, subject),
  UNIQUE (user_id, provider)
);

CREATE INDEX auth_identities_user_id_idx ON gymapp.auth_identities(user_id);

CREATE TABLE gymapp.groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  slug text NOT NULL CHECK (slug ~ '^[a-z0-9][a-z0-9-]{2,62}$'),
  name text NOT NULL CHECK (char_length(btrim(name)) BETWEEN 3 AND 80),
  description text CHECK (char_length(description) <= 1000),
  image_url text,
  timezone text NOT NULL DEFAULT 'UTC',
  is_private boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (slug)
);

CREATE TRIGGER groups_set_updated_at
BEFORE UPDATE ON gymapp.groups
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

CREATE TABLE gymapp.group_memberships (
  group_id uuid NOT NULL REFERENCES gymapp.groups(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE CASCADE,
  role gymapp.membership_role NOT NULL DEFAULT 'member',
  status gymapp.membership_status NOT NULL DEFAULT 'active',
  joined_at timestamptz NOT NULL DEFAULT now(),
  left_at timestamptz,
  PRIMARY KEY (group_id, user_id),
  CHECK ((status = 'left' AND left_at IS NOT NULL) OR (status <> 'left' AND left_at IS NULL))
);

CREATE INDEX group_memberships_active_user_idx
ON gymapp.group_memberships(user_id, group_id) WHERE status = 'active';

CREATE TABLE gymapp.group_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES gymapp.groups(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  invited_email text,
  invite_code text NOT NULL UNIQUE CHECK (char_length(invite_code) BETWEEN 16 AND 128),
  expires_at timestamptz,
  accepted_by uuid REFERENCES gymapp.user_profiles(id) ON DELETE SET NULL,
  accepted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((accepted_by IS NULL AND accepted_at IS NULL) OR (accepted_by IS NOT NULL AND accepted_at IS NOT NULL))
);

CREATE INDEX group_invites_group_id_idx ON gymapp.group_invites(group_id);

CREATE TABLE gymapp.group_seasons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES gymapp.groups(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  name text NOT NULL CHECK (char_length(btrim(name)) BETWEEN 3 AND 100),
  status gymapp.season_status NOT NULL DEFAULT 'draft',
  metric gymapp.score_metric NOT NULL,
  minimum_value numeric(12, 3) NOT NULL DEFAULT 1 CHECK (minimum_value >= 0),
  maximum_value numeric(12, 3) NOT NULL DEFAULT 1 CHECK (maximum_value >= minimum_value),
  daily_event_limit integer NOT NULL DEFAULT 1 CHECK (daily_event_limit BETWEEN 1 AND 100),
  accepted_sources gymapp.activity_source[] NOT NULL DEFAULT ARRAY['synced']::gymapp.activity_source[],
  timezone text NOT NULL,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (cardinality(accepted_sources) > 0),
  CHECK (starts_at < ends_at)
);

CREATE UNIQUE INDEX group_seasons_one_active_idx
ON gymapp.group_seasons(group_id) WHERE status = 'active';
CREATE INDEX group_seasons_group_status_idx ON gymapp.group_seasons(group_id, status, starts_at DESC);

CREATE TRIGGER group_seasons_set_updated_at
BEFORE UPDATE ON gymapp.group_seasons
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

COMMENT ON TABLE gymapp.group_seasons IS 'Immutable scoring-rule snapshot after first activity claim.';
