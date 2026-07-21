-- GymApp remote social schema. Apply migrations in lexical order.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS gymapp;
SET search_path TO gymapp, public;

DO $$
BEGIN
  CREATE TYPE gymapp.identity_provider AS ENUM ('google', 'microsoft', 'apple');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.faction AS ENUM ('lion', 'dragon');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.fauna_tier AS ENUM ('rat', 'wolf', 'bear', 'rhino', 'gorilla', 'apex');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.membership_role AS ENUM ('owner', 'moderator', 'member');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.membership_status AS ENUM ('active', 'left', 'banned');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.season_status AS ENUM ('draft', 'active', 'ended');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.score_metric AS ENUM ('workouts', 'minutes', 'kilometers', 'posts');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.activity_source AS ENUM ('synced', 'check_in', 'post');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.claim_status AS ENUM ('credited', 'below_minimum', 'daily_limit', 'source_not_allowed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.post_type AS ENUM ('activity', 'check_in', 'conversation');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gymapp.reaction_type AS ENUM ('clap', 'fire', 'roar');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE OR REPLACE FUNCTION gymapp.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

COMMENT ON SCHEMA gymapp IS 'Remote-only social, identity and ranking state. Personal workout history remains in local SQLite.';
