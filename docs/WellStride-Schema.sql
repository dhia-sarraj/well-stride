-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE gender_enum AS ENUM ('Male', 'Female');
CREATE TYPE mood_enum AS ENUM ('Happy', 'Calm', 'Neutral', 'Sad', 'Anxious');
CREATE TYPE mood_reason_enum AS ENUM ('Work', 'Exercise', 'Sleep', 'Family', 'Friends', 'Health', 'Weather', 'Food', 'Stress', 'Relaxation', 'Other');
CREATE TYPE pattern_enum AS ENUM ('Box', 'Relaxing', 'Energizing');
CREATE TYPE notification_enum AS ENUM ('Progress', 'Motivational', 'Quote', 'Reminder');
CREATE TYPE notification_status_enum AS ENUM ('Pending', 'Sent', 'Failed', 'Cancelled');
CREATE TYPE export_status_enum AS ENUM ('Pending', 'Processing', 'Completed', 'Failed');
CREATE TYPE user_provider AS ENUM ('Email', 'Google');
CREATE TYPE export_format AS ENUM ('JSON', 'CSV');

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    password_hash VARCHAR(255),              -- nullable for OAuth users
    provider user_provider NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

CREATE INDEX ix_users_email ON users(email);

-- User Profiles
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(100) NOT NULL,
    photo_url TEXT,
    age SMALLINT NOT NULL,
    gender gender_enum NOT NULL,
    height_cm NUMERIC(6,2) NOT NULL,
    weight_kg NUMERIC(6,2) NOT NULL,
    goal INTEGER NOT NULL DEFAULT 10000,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Refresh Token
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_refresh_tokens_user_active ON refresh_tokens(user_id) WHERE revoked = false;

-- Password Reset Token
CREATE TABLE password_reset_token (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pwdreset_user ON password_reset_token(user_id);
CREATE INDEX idx_pwdreset_token_hash ON password_reset_token(token_hash);

-- Step Summaries (daily aggregates)
CREATE TABLE step_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,             -- day bucket
    step_count INTEGER NOT NULL DEFAULT 0,
    goal INTEGER NOT NULL,
    distance_meters NUMERIC(10,2),
    active_minutes INTEGER,
    stairs_climbed INTEGER,
    calories_estimated INTEGER,
    source step_source_enum NOT NULL DEFAULT 'Merged',
    synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE INDEX ix_step_summaries_user_date ON step_summaries(user_id, date DESC);


-- Mood
CREATE TABLE mood_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emoji mood_enum NOT NULL, 
    reason mood_reason_enum NOT NULL,
    note TEXT,
    steps_at_time INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Breather Sessions
CREATE TABLE breather_session (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL,
    pattern pattern_enum NOT NULL,
    duration_seconds INTEGER NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_breather_sessions_user_started ON breather_session(user_id, started_at DESC);

-- Quotes
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text TEXT NOT NULL,
    author VARCHAR(200),
    category VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User's Favorite Quotes
CREATE TABLE user_favorite_quotes (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quote_id UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    favorited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, quote_id)
);

-- Analytic Events
-- NOTE: store hashed user id for privacy; optionally store user_id for internal only if opted in
-- CREATE TABLE analytics_events (
--  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--  user_id_hash VARCHAR(128) NOT NULL,           -- e.g. sha256(user_id || salt)
--  session_id UUID,
--  event_name VARCHAR(128) NOT NULL,
--  properties JSONB,
--  platform VARCHAR(20) CHECK (platform IN ('ios','android')),
--  app_version VARCHAR(64),
--  timestamp TIMESTAMPTZ NOT NULL,
--  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
-- CREATE INDEX ix_analytics_events_name_ts ON analytics_events(event_name, timestamp DESC);
-- CREATE INDEX ix_analytics_events_userhash_ts ON analytics_events(user_id_hash, timestamp DESC);

-- Consider partitioning analytics_events by time in high-volume production.

-- Notification Queue
CREATE TABLE notification_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_enum NOT NULL,
    title VARCHAR(200),
    body TEXT,
    scheduled_for TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    status notification_status_enum NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_notification_queue_scheduled ON notification_queue(scheduled_for) WHERE status = 'Pending';

-- Export Requests
CREATE TABLE export_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status export_status_enum NOT NULL DEFAULT 'Pending',
    format export_format,
    file_url TEXT,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX ix_export_requests_user_status ON export_requests(user_id, status);

-- Materialized View for Streaks
CREATE MATERIALIZED VIEW user_streaks AS
SELECT 
    user_id,
    COUNT(*) AS current_streak,
    MAX(date) AS last_goal_date
FROM (
    SELECT
        user_id,
        date,
        date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date)::integer AS grp
    FROM step_summaries
    WHERE step_count >= goal
) s
GROUP BY user_id, grp
ORDER BY user_id, last_goal_date DESC;