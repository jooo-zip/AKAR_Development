BEGIN IMMEDIATE;

CREATE TABLE IF NOT EXISTS sessions (
    session_id TEXT PRIMARY KEY NOT NULL
        CHECK (length(session_id) = 36
            AND session_id NOT GLOB '*[^0-9a-f-]*'
            AND length(replace(session_id, '-', '')) = 32
            AND substr(session_id, 9, 1) = '-'
            AND substr(session_id, 14, 1) = '-'
            AND substr(session_id, 19, 1) = '-'
            AND substr(session_id, 24, 1) = '-'
            AND substr(session_id, 15, 1) = '4'
            AND substr(session_id, 20, 1) IN ('8', '9', 'a', 'b')),
    started_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    device_type TEXT NOT NULL DEFAULT 'unknown'
        CHECK (device_type IN ('mobile', 'tablet', 'desktop', 'unknown')),
    access_source TEXT NOT NULL DEFAULT 'unknown'
        CHECK (access_source IN ('museum_tablet', 'museum_qr', 'direct', 'unknown'))
) STRICT;

CREATE TABLE IF NOT EXISTS landmark_visits (
    session_id TEXT NOT NULL REFERENCES sessions(session_id),
    landmark_id TEXT NOT NULL
        CHECK (landmark_id IN ('co_cathedral', 'urduja_house', 'provincial_capitol',
                              'limahong_channel', 'casa_real')),
    first_opened_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    PRIMARY KEY (session_id, landmark_id)
) STRICT;

CREATE TABLE IF NOT EXISTS admins (
    admin_id INTEGER PRIMARY KEY,
    username TEXT NOT NULL UNIQUE CHECK (length(trim(username)) > 0),
    password_hash TEXT NOT NULL CHECK (length(password_hash) > 0),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
) STRICT;

CREATE INDEX IF NOT EXISTS sessions_started_at_idx ON sessions(started_at);
CREATE INDEX IF NOT EXISTS landmark_visits_landmark_time_idx
    ON landmark_visits(landmark_id, first_opened_at);

-- Milestone 2: separately approved authentication storage, not visitor sessions.
CREATE TABLE IF NOT EXISTS admin_sessions (
    token_hash TEXT PRIMARY KEY NOT NULL CHECK (length(token_hash) = 64),
    admin_id INTEGER NOT NULL REFERENCES admins(admin_id) ON DELETE CASCADE,
    credential_fingerprint TEXT NOT NULL CHECK (length(credential_fingerprint) = 64),
    created_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL CHECK (expires_at > created_at)
) STRICT;
CREATE INDEX IF NOT EXISTS admin_sessions_expiry_idx ON admin_sessions(expires_at);
CREATE INDEX IF NOT EXISTS admin_sessions_admin_idx ON admin_sessions(admin_id);

COMMIT;
