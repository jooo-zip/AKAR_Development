import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { once } from 'node:events';
import { openDatabase } from '../src/db/database.js';
import { createApp } from '../src/app.js';
import { readConfig } from '../src/config.js';
import { LANDMARK_IDS } from '../src/validation.js';

async function fixture(t, overrides = {}) {
  const directory = mkdtempSync(join(tmpdir(), 'akar-analytics-test-'));
  const path = join(directory, 'test.sqlite');
  const db = openDatabase(path);
  const server = createApp(db, { ...readConfig({}), rateLimitMax: 1000, ...overrides })
    .listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(async () => {
    await new Promise(resolve => server.close(resolve));
    db.close();
    // This path comes directly from mkdtempSync, never from request/config input.
    rmSync(directory, { recursive: true, force: true });
  });
  const base = `http://127.0.0.1:${server.address().port}`;
  async function request(pathname, body, options = {}) {
    const response = await fetch(base + pathname, {
      method: body === undefined ? 'GET' : 'POST',
      headers: body === undefined ? {} : { 'Content-Type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body),
      ...options,
    });
    return { status: response.status, headers: response.headers, body: await response.json() };
  }
  return { db, path, request };
}

function count(db, table) {
  // Table names here are test constants, never request input.
  return db.prepare(`SELECT count(*) AS count FROM ${table}`).get().count;
}

function assertUtcTimestamp(timestamp, lowerBound) {
  assert.match(timestamp, /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/);
  assert.ok(Date.parse(timestamp) >= lowerBound);
  assert.ok(Date.parse(timestamp) <= Date.now());
}

test('database initializes all three tables, indexes, foreign keys, and no admin seed', async t => {
  const { db, path } = await fixture(t);
  const tables = db.prepare("SELECT name FROM sqlite_schema WHERE type = 'table' ORDER BY name").all();
  assert.deepEqual(tables.map(row => row.name), ['admins', 'landmark_visits', 'sessions']);
  assert.equal(db.prepare('PRAGMA foreign_keys').get().foreign_keys, 1);
  assert.equal(db.prepare('PRAGMA journal_mode').get().journal_mode, 'wal');
  assert.equal(count(db, 'admins'), 0);
  const indexes = db.prepare("SELECT name FROM sqlite_schema WHERE type = 'index'").all().map(row => row.name);
  assert.ok(indexes.includes('sessions_started_at_idx'));
  assert.ok(indexes.includes('landmark_visits_landmark_time_idx'));
  const reopened = openDatabase(path);
  assert.equal(count(reopened, 'sessions'), 0);
  reopened.close();
});

test('health endpoint returns consistent JSON without exposing configuration', async t => {
  const { request } = await fixture(t);
  const result = await request('/api/health');
  assert.equal(result.status, 200);
  assert.deepEqual(result.body, { ok: true, data: { status: 'ok', service: 'akar-museum-analytics' } });
  assert.equal(result.headers.get('cache-control'), 'no-store');
  assert.equal(result.headers.get('x-powered-by'), null);
});

test('session creation stores only allowed metadata with a server UTC timestamp and survives reopen', async t => {
  const { request, db, path } = await fixture(t);
  const before = Date.now();
  const session_id = randomUUID();
  const result = await request('/api/sessions', { session_id, device_type: 'tablet', access_source: 'museum_tablet' });
  assert.equal(result.status, 201);
  assert.equal(result.body.data.created, true);
  assert.equal(count(db, 'sessions'), 1);
  assert.equal(result.body.data.session.device_type, 'tablet');
  assert.equal(result.body.data.session.access_source, 'museum_tablet');
  assertUtcTimestamp(result.body.data.session.started_at, before);
  const reopened = openDatabase(path);
  assert.equal(reopened.prepare('SELECT session_id FROM sessions').get().session_id, session_id);
  reopened.close();
});

test('repeated and simultaneous session requests preserve first timestamp and metadata', async t => {
  const { request, db } = await fixture(t);
  const session_id = randomUUID();
  const first = await request('/api/sessions', { session_id, device_type: 'mobile', access_source: 'museum_qr' });
  const retries = await Promise.all(Array.from({ length: 8 }, () => request('/api/sessions', {
    session_id: session_id.toUpperCase(), device_type: 'desktop', access_source: 'direct',
  })));
  for (const retry of retries) {
    assert.equal(retry.status, 200);
    assert.equal(retry.body.data.created, false);
    assert.deepEqual(retry.body.data.session, first.body.data.session);
  }
  assert.equal(count(db, 'sessions'), 1);
});

test('omitted optional categories become unknown', async t => {
  const { request } = await fixture(t);
  const result = await request('/api/sessions', { session_id: randomUUID() });
  assert.equal(result.status, 201);
  assert.equal(result.body.data.session.device_type, 'unknown');
  assert.equal(result.body.data.session.access_source, 'unknown');
});

test('opening and reopening Urduja House creates one visit and preserves its timestamp', async t => {
  const { request, db } = await fixture(t);
  const session_id = randomUUID();
  await request('/api/sessions', { session_id });
  const before = Date.now();
  const payload = { session_id, landmark_id: 'urduja_house' };
  const first = await request('/api/landmark-visits', payload);
  assert.equal(first.status, 201);
  assert.equal(first.body.data.created, true);
  assertUtcTimestamp(first.body.data.visit.first_opened_at, before);
  for (const retry of await Promise.all(Array.from({ length: 8 }, () => request('/api/landmark-visits', payload)))) {
    assert.equal(retry.status, 200);
    assert.equal(retry.body.data.created, false);
    assert.deepEqual(retry.body.data.visit, first.body.data.visit);
  }
  assert.equal(count(db, 'landmark_visits'), 1);
});

test('three distinct landmarks produce three visits in one session', async t => {
  const { request, db } = await fixture(t);
  const session_id = randomUUID();
  await request('/api/sessions', { session_id });
  for (const landmark_id of ['urduja_house', 'limahong_channel', 'casa_real']) {
    assert.equal((await request('/api/landmark-visits', { session_id, landmark_id })).status, 201);
  }
  assert.equal(count(db, 'landmark_visits'), 3);
});

test('all five landmark IDs are supported and separate sessions may visit the same landmark', async t => {
  const { request, db } = await fixture(t);
  for (let i = 0; i < 2; i++) {
    const session_id = randomUUID();
    await request('/api/sessions', { session_id });
    for (const landmark_id of LANDMARK_IDS) {
      assert.equal((await request('/api/landmark-visits', { session_id, landmark_id })).status, 201);
    }
  }
  assert.equal(count(db, 'landmark_visits'), 10);
});

test('invalid landmark IDs including SQL-like strings are rejected without writes', async t => {
  const { request, db } = await fixture(t);
  const session_id = randomUUID();
  await request('/api/sessions', { session_id });
  for (const landmark_id of ['unknown', 'URDUJA_HOUSE', "'); DROP TABLE sessions; --", '', null, 2]) {
    const result = await request('/api/landmark-visits', { session_id, landmark_id });
    assert.equal(result.status, 400);
    assert.equal(result.body.error.code, 'invalid_payload');
  }
  assert.equal(count(db, 'landmark_visits'), 0);
  assert.equal(count(db, 'sessions'), 1);
});

test('missing, malformed, non-v4, and nonexistent sessions are rejected', async t => {
  const { request, db } = await fixture(t);
  for (const session_id of [undefined, '', 'not-a-uuid', null, 123, '00000000-0000-0000-0000-000000000000']) {
    assert.equal((await request('/api/sessions', { session_id })).status, 400);
    assert.equal((await request('/api/landmark-visits', { session_id, landmark_id: 'urduja_house' })).status, 400);
  }
  const missing = await request('/api/landmark-visits', { session_id: randomUUID(), landmark_id: 'urduja_house' });
  assert.equal(missing.status, 404);
  assert.equal(missing.body.error.code, 'session_not_found');
  assert.equal(count(db, 'landmark_visits'), 0);
});

test('invalid device/source values and non-object payloads are rejected', async t => {
  const { request, db } = await fixture(t);
  for (const body of [[], null, 'text', { session_id: randomUUID(), device_type: 'phone' },
    { session_id: randomUUID(), access_source: 'https://example.com/private' },
    { session_id: randomUUID(), device_type: null }]) {
    assert.equal((await request('/api/sessions', body)).status, 400);
  }
  assert.equal(count(db, 'sessions'), 0);
});

test('extra personal-data fields and client timestamps are rejected, not silently stored', async t => {
  const { request, db } = await fixture(t);
  for (const field of ['name', 'email', 'age', 'gps', 'user_agent', 'referrer', 'visitor_id', 'started_at']) {
    assert.equal((await request('/api/sessions', { session_id: randomUUID(), [field]: 'not-accepted' })).status, 400);
  }
  const session_id = randomUUID();
  await request('/api/sessions', { session_id });
  assert.equal((await request('/api/landmark-visits', {
    session_id, landmark_id: 'urduja_house', first_opened_at: '2000-01-01T00:00:00Z',
  })).status, 400);
  assert.equal(count(db, 'sessions'), 1);
  assert.equal(count(db, 'landmark_visits'), 0);
  assert.deepEqual(db.prepare('PRAGMA table_info(sessions)').all().map(row => row.name),
    ['session_id', 'started_at', 'device_type', 'access_source']);
});

test('foreign keys, session/visit uniqueness, enum checks and admin uniqueness are enforced in SQLite', async t => {
  const { db } = await fixture(t);
  const session_id = randomUUID();
  const session = db.prepare('INSERT INTO sessions(session_id) VALUES (?)');
  const visit = db.prepare('INSERT INTO landmark_visits(session_id, landmark_id) VALUES (?, ?)');
  assert.throws(() => visit.run(session_id, 'urduja_house'), /FOREIGN KEY/);
  session.run(session_id);
  assert.throws(() => session.run(session_id), /UNIQUE/);
  assert.throws(() => session.run('invalid'), /CHECK/);
  visit.run(session_id, 'urduja_house');
  assert.throws(() => visit.run(session_id, 'urduja_house'), /UNIQUE/);
  assert.throws(() => visit.run(session_id, 'not_a_landmark'), /CHECK/);
  assert.throws(() => db.prepare('DELETE FROM sessions WHERE session_id = ?').run(session_id), /FOREIGN KEY/);
  assert.throws(() => db.prepare('INSERT INTO sessions(session_id, device_type) VALUES (?, ?)').run(randomUUID(), 'phone'), /CHECK/);
  const admin = db.prepare('INSERT INTO admins(username, password_hash) VALUES (?, ?)');
  admin.run('test-only-admin', 'test-only-placeholder-hash');
  assert.throws(() => admin.run('test-only-admin', 'test-only-placeholder-hash'), /UNIQUE/);
  assert.throws(() => db.prepare('UPDATE admins SET is_active = 2').run(), /CHECK/);
});

test('malformed JSON, oversized bodies, unsupported content types and encodings return JSON errors', async t => {
  const { request } = await fixture(t);
  assert.equal((await request('/api/sessions', {}, { body: '{broken' })).status, 400);
  assert.equal((await request('/api/sessions', { session_id: 'a'.repeat(5000) })).status, 413);
  assert.equal((await request('/api/sessions', {}, { headers: { 'Content-Type': 'text/plain' } })).status, 415);
  assert.equal((await request('/api/sessions', {}, {
    headers: { 'Content-Type': 'application/json', 'Content-Encoding': 'gzip' },
  })).status, 415);
});

test('rate limits return 429 and retry metadata; spoofed forwarding headers do not bypass them', async t => {
  const { request } = await fixture(t, { rateLimitMax: 2 });
  assert.equal((await request('/api/health')).status, 200);
  assert.equal((await request('/api/health')).status, 200);
  const result = await request('/api/health', undefined, { headers: { 'X-Forwarded-For': '203.0.113.4' } });
  assert.equal(result.status, 429);
  assert.equal(result.body.error.code, 'rate_limited');
  assert.ok(Number(result.headers.get('retry-after')) > 0);
  assert.ok(result.headers.get('ratelimit'));
});

test('database locks return recoverable 503 and a subsequent retry succeeds', async t => {
  const { request, db, path } = await fixture(t);
  db.exec('PRAGMA busy_timeout = 20');
  const blocker = openDatabase(path);
  try {
    blocker.exec('BEGIN IMMEDIATE');
    const payload = { session_id: randomUUID() };
    const blocked = await request('/api/sessions', payload);
    assert.equal(blocked.status, 503);
    assert.equal(blocked.body.error.code, 'storage_busy');
    assert.equal(blocked.headers.get('retry-after'), '2');
    blocker.exec('ROLLBACK');
    assert.equal((await request('/api/sessions', payload)).status, 201);
  } finally {
    blocker.close();
  }
});

test('unexpected storage failures do not expose SQL, paths, or stack traces', async t => {
  const { request, db } = await fixture(t);
  db.exec('DROP TABLE landmark_visits; DROP TABLE sessions');
  const result = await request('/api/sessions', { session_id: randomUUID() });
  assert.equal(result.status, 500);
  assert.deepEqual(result.body, { ok: false, error: {
    code: 'internal_error', message: 'The request could not be recorded. It may be retried.',
  } });
});

test('database, admin data, and arbitrary paths are not publicly served', async t => {
  const { request } = await fixture(t);
  for (const path of ['/data/analytics.sqlite', '/api/admins', '/api/sessions', '/.env', '/does-not-exist']) {
    const result = await request(path);
    assert.equal(result.status, 404);
    assert.equal(result.body.ok, false);
  }
});

test('deployment configuration has safe defaults and rejects invalid numeric settings', () => {
  const defaults = readConfig({});
  assert.equal(defaults.host, '127.0.0.1');
  assert.equal(defaults.port, 3000);
  assert.deepEqual(defaults.trustedProxies, []);
  assert.ok(defaults.databasePath.endsWith(join('data', 'analytics.sqlite')));
  assert.equal(readConfig({ PORT: '3100' }).port, 3100);
  for (const env of [{ PORT: '0' }, { PORT: '65536' }, { RATE_LIMIT_MAX: '-1' },
    { RATE_LIMIT_WINDOW_MS: 'abc' }, { DATABASE_PATH: ' ' }]) {
    assert.throws(() => readConfig(env));
  }
});
