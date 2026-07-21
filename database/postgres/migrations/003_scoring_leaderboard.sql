SET search_path TO gymapp, public;

CREATE TABLE gymapp.activity_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  season_id uuid NOT NULL REFERENCES gymapp.group_seasons(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES gymapp.user_profiles(id) ON DELETE RESTRICT,
  source gymapp.activity_source NOT NULL,
  source_reference text,
  occurred_at timestamptz NOT NULL,
  raw_value numeric(12, 3) NOT NULL CHECK (raw_value >= 0),
  credited_value numeric(12, 3) NOT NULL DEFAULT 0 CHECK (credited_value >= 0),
  status gymapp.claim_status NOT NULL DEFAULT 'credited',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (jsonb_typeof(metadata) = 'object')
);

CREATE UNIQUE INDEX activity_claims_idempotency_idx
ON gymapp.activity_claims(season_id, user_id, source, source_reference)
WHERE source_reference IS NOT NULL;
CREATE INDEX activity_claims_leaderboard_idx
ON gymapp.activity_claims(season_id, user_id, occurred_at)
WHERE status = 'credited';

CREATE OR REPLACE FUNCTION gymapp.score_activity_claim()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  season_row gymapp.group_seasons%ROWTYPE;
  credited_today integer;
BEGIN
  -- Serializes claims per season so concurrent requests cannot evade its daily cap.
  SELECT * INTO season_row
  FROM gymapp.group_seasons
  WHERE id = NEW.season_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'season % does not exist', NEW.season_id USING ERRCODE = 'foreign_key_violation';
  END IF;

  IF season_row.status <> 'active' THEN
    RAISE EXCEPTION 'season % is not active', NEW.season_id USING ERRCODE = 'check_violation';
  END IF;

  IF NEW.occurred_at < season_row.starts_at OR NEW.occurred_at >= season_row.ends_at THEN
    RAISE EXCEPTION 'claim timestamp must be inside the season range' USING ERRCODE = 'check_violation';
  END IF;

  PERFORM 1
  FROM gymapp.group_memberships
  WHERE group_id = season_row.group_id
    AND user_id = NEW.user_id
    AND status = 'active';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'claim user must be an active season-group member' USING ERRCODE = 'foreign_key_violation';
  END IF;

  NEW.credited_value := 0;

  IF NOT (season_row.accepted_sources @> ARRAY[NEW.source]::gymapp.activity_source[]) THEN
    NEW.status := 'source_not_allowed';
    RETURN NEW;
  END IF;

  IF NEW.raw_value < season_row.minimum_value THEN
    NEW.status := 'below_minimum';
    RETURN NEW;
  END IF;

  SELECT count(*) INTO credited_today
  FROM gymapp.activity_claims claims
  WHERE claims.season_id = NEW.season_id
    AND claims.user_id = NEW.user_id
    AND claims.status = 'credited'
    AND (claims.occurred_at AT TIME ZONE season_row.timezone)::date =
        (NEW.occurred_at AT TIME ZONE season_row.timezone)::date;

  IF credited_today >= season_row.daily_event_limit THEN
    NEW.status := 'daily_limit';
    RETURN NEW;
  END IF;

  NEW.status := 'credited';
  NEW.credited_value := LEAST(NEW.raw_value, season_row.maximum_value);
  RETURN NEW;
END;
$$;

CREATE TRIGGER activity_claims_score_before_insert
BEFORE INSERT ON gymapp.activity_claims
FOR EACH ROW EXECUTE FUNCTION gymapp.score_activity_claim();

CREATE OR REPLACE FUNCTION gymapp.prevent_activity_claim_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'activity claims are immutable; create a compensating event instead' USING ERRCODE = 'check_violation';
END;
$$;

CREATE TRIGGER activity_claims_immutable_before_update_or_delete
BEFORE UPDATE OR DELETE ON gymapp.activity_claims
FOR EACH ROW EXECUTE FUNCTION gymapp.prevent_activity_claim_mutation();

CREATE OR REPLACE FUNCTION gymapp.prevent_scoring_rule_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (OLD.metric, OLD.minimum_value, OLD.maximum_value, OLD.daily_event_limit,
      OLD.accepted_sources, OLD.timezone, OLD.starts_at, OLD.ends_at)
      IS DISTINCT FROM
     (NEW.metric, NEW.minimum_value, NEW.maximum_value, NEW.daily_event_limit,
      NEW.accepted_sources, NEW.timezone, NEW.starts_at, NEW.ends_at)
     AND EXISTS (SELECT 1 FROM gymapp.activity_claims WHERE season_id = OLD.id) THEN
    RAISE EXCEPTION 'scoring rules are immutable after the first claim; create a new season' USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER group_seasons_prevent_rule_mutation
BEFORE UPDATE ON gymapp.group_seasons
FOR EACH ROW EXECUTE FUNCTION gymapp.prevent_scoring_rule_mutation();

CREATE TABLE gymapp.fauna_progress (
  user_id uuid PRIMARY KEY REFERENCES gymapp.user_profiles(id) ON DELETE CASCADE,
  form_points numeric(12, 3) NOT NULL DEFAULT 0 CHECK (form_points >= 0),
  legacy_points numeric(12, 3) NOT NULL DEFAULT 0 CHECK (legacy_points >= 0),
  current_tier gymapp.fauna_tier NOT NULL DEFAULT 'rat',
  best_annual_tier gymapp.fauna_tier NOT NULL DEFAULT 'rat',
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER fauna_progress_set_updated_at
BEFORE UPDATE ON gymapp.fauna_progress
FOR EACH ROW EXECUTE FUNCTION gymapp.set_updated_at();

CREATE OR REPLACE VIEW gymapp.season_leaderboard
WITH (security_invoker = true)
AS
WITH totals AS (
  SELECT
    season_id,
    user_id,
    sum(credited_value) AS total_credited,
    count(*) AS credited_events,
    max(occurred_at) AS reached_score_at,
    max(occurred_at) AS last_credited_at
  FROM gymapp.activity_claims
  WHERE status = 'credited'
  GROUP BY season_id, user_id
)
SELECT
  totals.season_id,
  totals.user_id,
  totals.total_credited,
  totals.credited_events,
  totals.last_credited_at,
  row_number() OVER (
    PARTITION BY totals.season_id
    ORDER BY totals.total_credited DESC, totals.reached_score_at ASC, totals.user_id ASC
  ) AS position
FROM totals;

COMMENT ON TABLE gymapp.activity_claims IS 'Immutable audit events. The trigger preserves raw value and calculates credited value/status.';
COMMENT ON VIEW gymapp.season_leaderboard IS 'Transparent score view; tie-breaks by the latest event needed to reach the score, then user UUID.';
