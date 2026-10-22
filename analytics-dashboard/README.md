# AKAR Museum Analytics Backend

Milestone 1 supplies an independent anonymous tracking API and SQLite database.
Milestone 2 adds local administrator provisioning, secure login/logout, persistent
administrator sessions, and a simple login page. Milestone 3 adds a protected,
read-only usage dashboard with server-calculated statistics and locally served
Chart.js charts. Godot integration is not implemented.
The visitor Main Menu, Begin Walkthrough handler and landmark navigation are
not present in this checkout. No session is created automatically by the Godot
application. A future client must generate a fresh random UUID v4 per visit,
reuse it for retries, and keep navigation independent of analytics success.

## Requirements and boundaries

- Node.js 24.x and npm. No separate SQLite server or native SQLite npm package.
- Runtime dependencies: Express, express-rate-limit, and Chart.js, pinned in package.json
  and package-lock.json. Installation scripts are not needed.
- Tests use Node's built-in test runner, assertions, HTTP client, and SQLite.
- `.gdignore` keeps this module out of Godot's resource scanning. Existing scenes,
  scripts, assets, historical resources, and project.godot remain unchanged.
- Database files, environment files, dependencies, and temporary outputs are
  ignored by this module's `.gitignore`. Only `public/` is served at `/admin/`;
  it contains login HTML and frontend CSS/JavaScript, never database files or credentials.

## Files

- `src/server.js`: local listener and shutdown handling.
- `src/app.js`: HTTP middleware, payload limit, rate limiting, and JSON errors.
- `src/config.js`: environment configuration and validation.
- `src/validation.js`: UUID v4 and allowed metadata validation.
- `src/routes/analytics.js`: health, session, and landmark-visit routes.
- `src/routes/admin.js`: login/logout, protected identity route, login throttling.
- `src/auth/passwords.js`, `provision.js`: password hashing and administrator creation.
- `src/auth/create-admin.js`, `terminal.js`: interactive CLI with hidden password input.
- `src/auth/sessions.js`, `security.js`: persistent sessions, authentication gate, CSRF/HTTPS checks.
- `public/login.html`, `login.css`, `login.js`: responsive administrator login page.
- `src/reporting.js`: validated Manila date ranges and read-only aggregate queries.
- `src/views/dashboard.html`: protected dashboard document, outside public assets.
- `public/dashboard.css`, `dashboard.js`: responsive charts, filters, tables, and session handling.
- `tests/reporting.test.js`: isolated reporting, date boundary, and authorization tests.
- `src/db/schema.sql`: tables and indexes; no administrator seed.
- `src/db/database.js`: initialization, foreign keys, WAL, and connection timeout.
- `src/db/init.js`: explicit database initialization command.
- `src/db/inspect.js`: local read-only inspection, excluding administrator credentials.
- `tests/`: isolated database/API tests and repository-preservation checks.

## Start locally in Windows PowerShell

```powershell
Set-Location 'C:\Users\Admin\OneDrive\JOSEPH\Capstone\AKAR_Development\analytics-dashboard'
node --version
npm.cmd ci --ignore-scripts
Copy-Item .env.example .env
npm.cmd run db:init
npm.cmd start
```

Copy the environment example only when creating your configuration for the first
time; preserve an existing `.env`. Initialization is also performed automatically
on server startup. It is repeatable and does not erase records. Stop the server
with Ctrl+C. `npm.cmd` avoids PowerShell's script-policy restrictions on npm.ps1.

Defaults are `http://127.0.0.1:3000` and the ignored
`analytics-dashboard/data/analytics.sqlite`. The database is created locally when
initialized or started, not committed as a binary file. A fresh database has zero
administrators. Provision one locally as described below; there is no public
registration or administrator-creation endpoint.

Environment variables override values loaded from `.env`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `HOST` | `127.0.0.1` | Bind address; use a wider address only for deliberate deployment |
| `PORT` | `3000` | Listener port, 1–65535 |
| `DATABASE_PATH` | `./data/analytics.sqlite` | Relative to this module, or an absolute persistent-storage path |
| `RATE_LIMIT_WINDOW_MS` | `60000` | Window length, 1–3600000 milliseconds |
| `RATE_LIMIT_MAX` | `120` | Requests per client network key per window, 1–100000 |
| `TRUSTED_PROXIES` | empty | Comma-separated trusted proxy IPs/CIDRs; direct connections by default |
| `NODE_ENV` | unset (`development` in example) | Set `production` for deployment; requires explicit HTTPS admin origin |
| `ADMIN_ORIGIN` | `http://127.0.0.1:PORT` | Exact browser origin, including nondefault port, without trailing slash or path |
| `ADMIN_SESSION_TTL_MINUTES` | `480` | Absolute session lifetime, 1–1440 minutes; activity does not extend it |
| `LOGIN_FAILURE_LIMIT` | `5` | Failed requests per network and per normalized username in each 15-minute window, 1–20 |

For example, `$env:DATABASE_PATH = 'D:\AKARStorage\analytics.sqlite'` selects an
external persistent location. Give the service account access to that directory.
Do not put the database or its WAL/SHM sidecars in a publicly served folder.
Avoid cloud-synchronized or network directories for deployed databases; use a
local persistent disk and a planned SQLite backup procedure. Tests never use
`DATABASE_PATH` or `.env` data.

Behind a reverse proxy, configure only actual trusted proxy addresses. Do not
enable blanket proxy trust: a client must not control the address used for abuse
limits. Restrict direct access to the backend when deploying through a proxy.
Configure HTTPS and the target origin during deployment. This milestone enables
no cross-origin browser access and sets no visitor cookies.

## Provision and sign in as an administrator

From the module directory in a local interactive PowerShell terminal, using the
same database configuration as the server:

```powershell
npm.cmd run admin:create
npm.cmd start
```

The CLI prompts for a username, password, and password confirmation. Password
entry is hidden, with no characters or asterisks echoed. Usernames are trimmed,
lowercased, and must contain 3–64 ASCII letters, digits, dots, underscores, or
hyphens, beginning with a letter or digit. Duplicate usernames are rejected
case-insensitively. Passwords must contain 15–128 Unicode characters and no more
than 512 UTF-8 bytes; choose a unique long passphrase. Passwords are not trimmed.
There are no default credentials.

Do not put passwords in command arguments, environment variables, scripts,
shell pipelines, logs, or tracked files. The CLI rejects arguments and redirected
input/output. If the terminal cannot disable echo, it fails before displaying a
password prompt; use an ordinary interactive terminal. Ctrl+C cancels hidden
entry. Provisioning does not log the username, password, or hash.

Open `http://127.0.0.1:3000/admin/` for the default configuration. Use the exact
configured origin: `localhost` and `127.0.0.1` are different origins. A successful
login redirects to the protected `/admin/dashboard` page. An already authenticated
visit to the login page offers an Open Analytics Dashboard link. Logout on the
dashboard (or Sign Out on the login page) invalidates the session in SQLite; simply
closing a tab is not logout. No real museum administrator was created during
verification; use the local CLI to create the approved account when ready.

Back up an existing database using an appropriate SQLite backup procedure before
an operational upgrade. Startup/provisioning repeat the additive schema setup:
the approved `admin_sessions` table and its indexes are created if absent, while
the original tables and records are preserved. Existing administrator records
must contain supported scrypt hashes to authenticate; arbitrary legacy strings
are rejected. Automated password reset or legacy hash conversion is not provided.

## Database schema

Visitor timestamps are generated by SQLite in UTC as `YYYY-MM-DDTHH:mm:ss.sssZ`.
Administrator session times are server-generated Unix milliseconds, returned by
the API as ISO UTC strings. All four tables use SQLite STRICT mode. The original
three-table architecture is preserved with the explicitly approved fourth table
for durable authentication. The full schema is in `src/db/schema.sql`.

| Table | Fields and constraints |
| --- | --- |
| `sessions` | `session_id`: canonical lowercase UUID v4, primary key; `started_at`: server UTC timestamp; `device_type`: mobile/tablet/desktop/unknown; `access_source`: museum_tablet/museum_qr/direct/unknown |
| `landmark_visits` | `session_id`: required foreign key to sessions; `landmark_id`: one of the five IDs below; `first_opened_at`: server UTC timestamp; composite primary key `(session_id, landmark_id)` |
| `admins` | `admin_id`: integer primary key; `username`: nonempty and unique; `password_hash`: nonempty; `is_active`: 0 or 1, defaults to 1 |
| `admin_sessions` | `token_hash`: SHA-256 digest, primary key; `admin_id`: foreign key with cascade on administrator deletion; `credential_fingerprint`: SHA-256 of current password hash; `created_at`, `expires_at`: integer milliseconds, expiry later than creation |

Foreign keys are enabled on each application connection. Deleting a session with
visits is blocked; there is no deletion API. Indexes support session-time queries
and landmark/time queries; the composite visit primary key also supports lookup
by session. WAL is enabled, with a two-second SQLite busy timeout.

Administrator sessions are separate from anonymous visitor sessions and support
independent devices. Indexes support administrator and expiration lookup. No
plaintext password or raw session token is stored in SQLite. No production
credentials or hardcoded administrator passwords are supplied.

Stable landmark IDs:

| ID | Landmark |
| --- | --- |
| `co_cathedral` | Co-Cathedral Parish of the Epiphany of Our Lord |
| `urduja_house` | Urduja House |
| `provincial_capitol` | Pangasinan Provincial Capitol |
| `limahong_channel` | Limahong Channel |
| `casa_real` | Casa Real |

These are analytics identifiers, not changes to existing hotspot folder names.

## API contract

API responses are JSON. Success has `{ "ok": true, "data": ... }`; errors have
`{ "ok": false, "error": { "code": "...", "message": "..." } }`.
POST requires uncompressed UTF-8 `application/json`, at most 4 KiB. Bodies must
be objects containing only the fields accepted by that endpoint. Unexpected
fields, including visitor information and client timestamps, are rejected.

| Endpoint | Accepted fields | Success |
| --- | --- | --- |
| `GET /api/health` | None | 200 with service name and status after a database connection check |
| `POST /api/sessions` | Required `session_id`; optional `device_type`, `access_source` defaulting to `unknown` | 201 with `data.created: true` and `data.session`; 200 with `created: false` for a retry |
| `POST /api/landmark-visits` | Required `session_id`, `landmark_id` | 201 with `data.created: true` and `data.visit`; 200 with `created: false` for a repeat visit |

UUID v4 syntax and variant are checked; uppercase UUIDs normalize to lowercase.
The server cannot prove the client's UUID was actually randomly generated.
Repeated session requests retain the first metadata and timestamp, even if a
retry supplies different valid metadata. Reopening a landmark retains its first
timestamp. A different session may record that same landmark again.

Errors: 400 invalid payload/JSON, 404 nonexistent session or unknown endpoint,
413 oversized payload, 415 unsupported content type/encoding, 429 rate limit,
503 busy storage, and 500 unexpected server failure. Rate-limit and busy-storage
responses include `Retry-After`. SQL, stack traces, paths, and request bodies are
not included in error responses. There is no request logging in this service.

Clients should retry transient failures with bounded backoff and the same UUID,
respect `Retry-After`, and create the session before submitting visits. A failed
request is not permission to block the walkthrough. Database uniqueness makes
retrying after a lost response safe. Invalid payloads need correction, not an
unbounded retry loop.

## Administrator API and security

| Endpoint | Behavior |
| --- | --- |
| `POST /api/admin/login` | JSON `username` and `password`; 200 returns only administrator ID/username and expiry, setting a session cookie; wrong, unknown, or inactive credentials share the same 401 message |
| `POST /api/admin/logout` | Send `{}`; 200 confirms sign-out, deletes the presented session from SQLite, and clears the cookie; safely repeatable when already signed out |
| `GET /api/admin/me` | 200 returns administrator ID/username and expiry for a valid session; otherwise 401; never returns password hashes or tokens |

Administrator POSTs require both an exact matching `Origin` and
`X-AKAR-Admin: 1`. If `Sec-Fetch-Site` is present, it must be `same-origin`.
The supplied page sends these requests correctly. Missing/foreign origins or
missing custom headers receive 403; no CORS access is enabled. Do not disable
these checks to accommodate a mismatched browser URL. The shared JSON size/type
checks still apply. Failed login limits return 429 with `Retry-After`; at most two
expensive password verifications run concurrently, with excess requests receiving
503 and `Retry-After`. The general API limiter also applies.

`src/auth/sessions.js` exposes `requireAdmin`. In `src/routes/admin.js`, `/me`
and every future route registered below `router.use(sessions.requireAdmin)` are
protected. Visitor session and landmark tracking endpoints remain public and
independent of administrator authentication. `/reports` uses the same authentication gate.

- Passwords use Node's asynchronous scrypt with `N=131072`, `r=8`, `p=1`,
  a random 16-byte salt, and a 64-byte result. Encoded hashes include parameters
  and salt. Verification uses a constant-time comparison and dummy derivation
  for unknown accounts. Each derivation needs about 128 MiB; provision enough
  memory for two concurrent verifications plus the application.
- Each login creates a fresh random 256-bit opaque token. SQLite stores only its
  SHA-256 digest, administrator link, credential fingerprint, and absolute expiry.
  A presented old session is revoked during successful login to prevent fixation.
  Other devices' sessions remain independent. Logout deletes the server-side row;
  replaying the old cookie fails even after restarting the server.
- Every protected request checks expiry, active status, and the current password
  hash fingerprint. Password changes/deactivation invalidate access on the next
  check. Expired rows are removed during login and when presented; no scheduled
  cleanup job exists. Sessions survive service restarts until expiration/revocation.
- Cookies are HttpOnly, SameSite=Strict, host-only, and Path=/. HTTPS uses
  `__Host-akar_admin` with Secure. Only local development permits HTTP with the
  separate `akar_admin_local` cookie. Production requires an explicit HTTPS
  `ADMIN_ORIGIN` and rejects administrator requests not recognized as secure.
- The browser uses cookies, never localStorage/sessionStorage authentication
  tokens. The password input is masked and cleared after requests. Responses use
  no-store, a restrictive CSP, no-referrer, nosniff, and frame-blocking headers.
  No credentials, request bodies, session tokens, or password hashes are logged.

The login page is HTML/CSS/vanilla JavaScript with labeled inputs, visible focus,
48-pixel controls, accessible status/error feedback, and a disabled loading button.
Its colors come from `../resources/themes/akar_hotspot_theme.tres` and the existing
hotspot handoff palette: dark green `#101D19`, brown `#9C4A25`, dark brown
`#6F3317`, terracotta `#D37148`, cream `#E8D5B4`, border `#8E6C51`, text
`#F9F5F0`, and secondary text `#D6C5AB`. A supplementary dark input shade is
`#0B1512`. The museum mark remains explicitly labeled **Temporary logo placeholder**;
no approved official logo asset has been supplied or fabricated.

## Museum Analytics Dashboard (Milestone 3)

Start the local service with `npm.cmd start`, sign in at
`http://127.0.0.1:3000/admin/`, and use `/admin/dashboard`. Use the configured
`ADMIN_ORIGIN` if it differs from the default. Dashboard HTML is served only
after authentication, including its `/admin/dashboard.html` alias. An unauthenticated
direct request returns 401 JSON; open `/admin/` to sign in. Expiration while using
the dashboard hides the reports and displays a sign-in link. Logout returns to
the login page; refreshing or revisiting protected routes does not restore access.

The interface includes four summary cards, a usage line chart, a horizontal
landmark chart, and a device doughnut chart. Exact values are also available in
accessible tables, with all five landmark names and all four device categories.
The layout has no sidebar, editing tools, visitor accounts, or export controls.
Chart.js 4.5.1 is served from the pinned npm package at `/admin/vendor/chart.js`;
the service exposes only that library file, not `node_modules`. No external CDN,
additional browser telemetry, or inline-script CSP exception is required.

### Reporting endpoint

`GET /api/admin/reports` requires the existing administrator session cookie.
It returns `{ "ok": true, "data": ... }` containing reporting timezone, generation
time, selected date/UTC boundaries, summary metrics, usage intervals, landmark
counts, and device counts/percentages. It exposes no session IDs, individual
visitor rows, administrator credentials, or raw tokens. Calculations run on the
server using parameterized SQLite queries in one consistent read transaction.
The four-table schema is unchanged in Milestone 3.

Supported query examples:

```text
/api/admin/reports?period=this_week
/api/admin/reports?period=this_month
/api/admin/reports?period=last_3_months
/api/admin/reports?period=custom&start=2026-10-01&end=2026-10-15
```

Omitting `period` selects `this_month`. Unknown/repeated parameters, invalid
periods, dates attached to a non-custom period, and invalid ranges receive
400 `invalid_date_range`. Authentication failure receives 401; general rate
limits receive 429, SQLite busy errors 503, and unexpected storage errors a
sanitized 500. Responses retain no-store and the existing security headers.

### Date filters and metric definitions

All reporting uses **Asia/Manila**. Timestamps remain canonical UTC ISO strings
in SQLite. User-facing dates are inclusive; queries use `timestamp >= start`
and `timestamp < next-day midnight`, converting Philippine midnight to UTC.
For example, 1 October 2026 covers `2026-09-30T16:00:00.000Z` through, but not
including, `2026-10-01T16:00:00.000Z`. Modern Philippine dates use UTC+08:00;
reporting does not depend on the server or browser's local timezone.

| Filter | Calendar boundaries in Asia/Manila |
| --- | --- |
| This Week | Monday 00:00 through today, inclusive |
| This Month | First day of the current month through today, inclusive |
| Last 3 Months | Three completed calendar months before the current month |
| Custom Date Range | Explicit inclusive start/end dates in `YYYY-MM-DD`; from 2000 onward, end no later than today, at most 3660 days |

| Metric | Calculation |
| --- | --- |
| Total Sessions | Count of anonymous `sessions` rows whose `started_at` falls in the selected period; not unique people or museum attendance |
| Weekly Average | Sessions in the last four completed Monday–Sunday weeks divided by exactly 4, including zero weeks; current week excluded |
| Monthly Average | Sessions in the last three completed calendar months divided by exactly 3, including zero months; current month excluded |
| Total Landmark Views | Count of unique `(session_id, landmark_id)` rows with `first_opened_at` in the selected period; the original composite primary key prevents repeated access being counted again |
| Most Viewed Landmarks | Same view counts, grouped by landmark and sorted descending; all five included at zero where needed; ties follow the configured landmark order |
| Device Distribution | Each mobile/tablet/desktop/unknown count divided by the selected period's session count × 100; rounded to one decimal |

The two average cards ignore the selected filter and show their own date basis.
Averages are displayed to at most two decimals; the API retains the computed
value and denominator. A landmark opening may count even if its session began
before the selected period. Consequently landmark views and sessions have
independent timestamp filters; views are not restricted to sessions created
inside the range.

Usage intervals are daily for ranges up to 62 days, Monday-based weekly for
63–366 days, and calendar-monthly beyond 366 days. Intervals at the edges are
clipped to the requested range; missing intervals are filled with zero. The
sum of all usage intervals equals Total Sessions. Reports reflect available
records at request time and refresh on Apply dates or window focus, not continuous
polling. Today is included as a calendar date; normal ingestion uses server time.

### Empty states and failures

An empty database returns zero counts and zero averages, all five landmarks,
and four device counts of zero. Device percentages are `null` in the API and
displayed as an em dash, with no doughnut chart. Missing chart assets leave
the statistic tables available. Invalid ranges, network failures, and unavailable
storage show explanatory messages and hide stale reports. Apply dates retries
the request. Report content is cleared before browser back/forward caching and
authentication is checked when the page returns or regains focus.

### Isolated verification and deployment limits

Never insert demonstration records into the default/deployed database. For
manual testing, use a separate PowerShell session and set `DATABASE_PATH` to a
unique temporary path **before** provisioning and starting the server. Automated
tests create and remove their own temporary databases and never use `.env` data.
No demonstration seed runs during ordinary startup and no sample metric values
are hardcoded into the dashboard.

Production still requires Node.js 24, persistent local SQLite storage, filesystem
permissions, SQLite-aware backups, HTTPS termination, explicit HTTPS `ADMIN_ORIGIN`,
`NODE_ENV=production`, correct trusted-proxy addresses, and restricted direct
backend access. Keep request-body/credential logging disabled at the proxy too.
Chart.js must be installed by `npm.cmd ci --ignore-scripts` along with the server
dependencies. No public hosting is configured by this milestone.

Reports use synchronous SQLite reads; large data volumes need load testing and
an index/performance review before deployment. Custom ranges are capped at 3660
days. Historical usage before collection began is unknown and contributes zero
to the defined denominators; averages are not adjusted to deployment age. Device
categories are client claims, and rounded shares may not total exactly 100%.
There is no visitor-duration metric, real-time push, cross-device visitor identity,
museum-attendance metric, export, or Godot tracking integration. Modern browsers
with fetch, AbortSignal.any/timeout, and responsive canvas support are required.

## Exercise the API from a second PowerShell window

Use an isolated demonstration database if these requests should not contribute
to your real analytics. Set `DATABASE_PATH` before starting that server.

```powershell
$akarBase = 'http://127.0.0.1:3000'
Invoke-RestMethod "$akarBase/api/health"

$akarSessionId = [guid]::NewGuid().ToString()
$akarSession = @{
    session_id = $akarSessionId
    device_type = 'tablet'
    access_source = 'museum_tablet'
} | ConvertTo-Json
Invoke-RestMethod "$akarBase/api/sessions" -Method Post -ContentType 'application/json' -Body $akarSession

$akarVisit = @{
    session_id = $akarSessionId
    landmark_id = 'urduja_house'
} | ConvertTo-Json
Invoke-RestMethod "$akarBase/api/landmark-visits" -Method Post -ContentType 'application/json' -Body $akarVisit

# Replay: created becomes false and the original timestamp remains.
Invoke-RestMethod "$akarBase/api/landmark-visits" -Method Post -ContentType 'application/json' -Body $akarVisit
```

## Inspect records safely

From the module directory, with the same environment configuration as the server:

```powershell
npm.cmd run db:inspect
```

This opens the configured database read-only, prints counts and at most 20 recent
sessions/visits, and never initializes a missing file or displays password hashes.
It is a local operator command, not a public API. Do not publish its output.

## Tests and Godot preservation

```powershell
npm.cmd test
Get-ChildItem src,public,tests -Recurse -Filter *.js | ForEach-Object {
    node --check $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "JavaScript syntax check failed" }
}
git -C .. diff --check
git -C .. diff --name-only HEAD -- project.godot scenes scripts data assets resources tests
```

Run these commands from the module directory. API tests start listeners on
ephemeral loopback ports and create uniquely named databases in the OS temporary
directory. They close connections and remove their own temporary directories.
Tests cover initialization, persistence, session/visit idempotency, all five IDs,
three visits, distinct sessions, UTC timestamps, rejection cases, privacy-field
rejection, database constraints, limits, retryable lock failures, and public data
exposure. The repository test checks existing Godot paths against HEAD, including
staged changes; it is not a historical guarantee after unrelated changes are committed.

Milestone 2 adds provisioning, salted password verification, duplicate usernames,
hidden terminal entry and fail-closed raw-mode setup, login success/failure,
network and username throttling, authorization, server-side logout, persistence
across restart, fixation prevention, expiry, deactivation/password changes,
CSRF, production cookie settings, login assets, and an additive migration test.
The migration test starts from Milestone 1 schema at commit `5568040`, then proves
existing administrator, visitor session, and landmark records remain intact.
The original 21 tests remain, with the initialization assertion updated for the
approved fourth table; 18 authentication tests bring the total to 39.

Milestone 3 final verification on **22 October 2026**: all **54 tests passed**
(39 existing + 15 reporting), with zero failures/skips. JavaScript syntax checks
and `git diff --check` passed. Reporting tests cover empty results, calendar/day/
Monday/year/leap-day boundaries, zero-period averages, independent filters,
opening-time landmark counts, deduplication, device percentages, interval grouping,
invalid ranges, aggregate-only responses, authenticated/expired/logged-out access,
read-only queries, and unchanged schema. Milestone 1 and 2 regression tests pass.

Local browser verification used a disposable database and test administrator,
never the default database. Empty reports showed zero counts and no percentages.
The isolated populated fixture showed 6 October sessions, 7 landmark views,
weekly average 1.25, and monthly average 1.67. All five landmarks appeared; device
shares were 33.3%, 33.3%, 16.7%, and 16.7%. These are **test-only values**, not museum
usage statistics. Week/month/three-month/custom filters and the reversed-date
error were verified. Login redirected to the protected dashboard; server-side
expiration hid reports and required reauthentication. Logout, login-page refresh,
and repeated direct dashboard access did not restore authenticated access.

Responsive checks used browser viewport overrides at 1280×720, 960×540, and
390×844. Charts resized, cards reflowed, controls remained usable, full landmark
names remained available in tables, and document width did not overflow the
viewport. Vertical scrolling is expected. These are local browser checks, not a
physical-device or cross-browser certification. The existing AKAR colors and
clearly marked temporary museum-logo placeholder were retained. The local server
was stopped and the disposable database removed after verification. Godot files,
the 34 existing hotspots, and the four-table schema remain unchanged; Godot
runtime tests were not run because this milestone changes no Godot resources.

Continuation verification on 22 October 2026: **39 tests passed, zero failures or
skips**, using Node.js 24.20.0. An actual interactive CLI run created a disposable
administrator in an isolated temporary database; both password prompts hid input.
Browser verification confirmed generic invalid-credential feedback, loading state,
successful login, persistence after reload, logout, and protected `/api/admin/me`
rejection after logout. No credentials appeared in server output. The local browser
check used HTTP loopback; production HTTPS/proxy behavior was covered by automated
tests, not a public deployment. No full cross-browser or mobile-device matrix was run.
The test server was stopped and its disposable database removed afterward.

Verified for Milestone 1 on 21 October 2026: Node.js 24.20.0, npm 11.19.0,
Express 5.3.0, express-rate-limit 8.7.1, and bundled SQLite 3.53.4. All 21 tests
passed, with zero failures or skips. The dependency installation audit reported
zero vulnerabilities. The first restricted test run could not connect to loopback
(`EACCES`); the same suite passed with local networking allowed, without code
changes. A separate PowerShell smoke check launched `src/server.js`, received a
healthy response, created a session and Urduja visit, replayed the visit without
duplication, and read back one session/one visit/zero administrators. Its temporary
database and server were removed/stopped. The default local database was initialized
empty. Godot runtime/visual tests were not run because no Godot files changed.

Optional manual preservation check after this milestone: launch the existing
Godot project and confirm its foundation screen is unchanged. F6 the existing
Urduja and Limahong preview scenes, open/close/reopen a hotspot, and check
UH-ENT-01 Skip. No Godot changes or new navigation are needed for backend testing.

## Privacy, limits, and later milestones

- Each UUID identifies one visit, not a person or permanent browser identity.
  Do not reuse it between independent visits or persist it as a visitor profile.
- Analytics fields exclude names, email, demographics, GPS, full user agents,
  referrer URLs, and IP addresses. Request headers are not written to SQLite.
- Rate limiting uses an HMAC of the client IP/network in temporary memory, with
  a random process-local key and expiring windows. Raw addresses and keys are not
  stored in analytics or logs. IPv6 addresses are grouped by the limiter helper.
  Proxy/hosting logs require a separate privacy review before deployment.
- The limiter is per server process. It resets on restart, can group visitors on
  shared networks, and is not a distributed abuse-prevention system. Adjust limits
  for museum usage. A public endpoint cannot identify unique human visitors or
  completely prevent fabricated traffic. Device/source values are client claims.
- Synchronous SQLite suits this small initial service; lock waits briefly occupy
  its event loop. Load testing, retention, backups, monitoring, and storage sizing
  are deployment work. This initial schema has no migration framework.
- Session duration is not implemented: the requested Milestone 1 schema has no
  duration, heartbeat, or session-end fields. Usage counts and averages do not
  establish learning effectiveness or museum attendance.
- Login failure counters are in memory per process, reset on restart, and can
  temporarily block a targeted username or a shared network. Durable SQLite
  authentication sessions are separate from these counters. Multi-process or
  Internet deployment needs shared abuse controls and an operational review.
- TLS termination, security headers such as HSTS at the HTTPS edge, trusted proxy
  configuration, firewalling, database/backup filesystem permissions, patching,
  and monitoring are deployment responsibilities. SQLite files are not encrypted
  by this application. Never put the database in a public or synchronized folder.
- There is no MFA, password-reset UI, account-management UI, administrator audit
  trail, or automatic legacy password migration. JavaScript cannot guarantee
  zeroization of transient password strings. Modern browser support for fetch,
  AbortSignal.timeout, and CSS viewport units is assumed. Do not add visitor
  registration or a content CMS.
- Future Godot integration belongs in the actual application controller, once it
  exists. Do not count preview launches or individual hotspots as landmark visits.

## Research alignment

The researcher explicitly authorized this isolated module and its JavaScript
exception. The locally identified manuscript candidate
`../Documents/PAPER/AKAR_V2_Chapter1-3_1.docx` (relative to the repository root)
describes a file-based Godot visitor system and does not document this dashboard
architecture; its latest-approved status remains unverified. Reconcile the
authoritative Chapters 1–3 scope, technology description, administrator actor,
and analytics data flows before claiming manuscript alignment. Historical content
remains in existing Godot resources. Usage counts do not measure learning gains
or replace the study's acceptability evaluation.

## Implementation references

- [Node.js 24 SQLite API](https://nodejs.org/docs/latest-v24.x/api/sqlite.html)
- [Express 5 API](https://expressjs.com/en/5x/api.html)
- [express-rate-limit documentation](https://express-rate-limit.mintlify.app/)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [Chart.js script-tag integration](https://www.chartjs.org/docs/latest/getting-started/integration.html)
- [Chart.js responsive charts](https://www.chartjs.org/docs/latest/configuration/responsive.html)
- [Chart.js accessibility](https://www.chartjs.org/docs/latest/general/accessibility.html)
