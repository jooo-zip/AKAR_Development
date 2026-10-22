import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { once } from 'node:events';
import { execFileSync } from 'node:child_process';
import { openDatabase } from '../src/db/database.js';
import { resolveRange, buildReport, MAX_RANGE_DAYS } from '../src/reporting.js';
import { createApp } from '../src/app.js';
import { readConfig, moduleRoot } from '../src/config.js';
import { hashPassword } from '../src/auth/passwords.js';

const now = new Date('2026-04-08T02:00:00.000Z'); // Wednesday, 10:00 in Manila.
const custom = (start, end = start) => ({ period: 'custom', start, end });
const testPassword = `Report-test-only-${randomBytes(20).toString('hex')}`;
const testHash = await hashPassword(testPassword);
function database(t) {
  const directory = mkdtempSync(join(tmpdir(), 'akar-report-test-'));
  const db = openDatabase(join(directory, 'test.sqlite'));
  t.after(() => { db.close(); rmSync(directory, { recursive: true, force: true }); });
  return db;
}
function session(db, timestamp, device = 'unknown') {
  const id = randomUUID();
  db.prepare('INSERT INTO sessions(session_id,started_at,device_type) VALUES (?,?,?)')
    .run(id, new Date(timestamp).toISOString(), device);
  return id;
}
function visit(db, id, landmark, timestamp) {
  db.prepare('INSERT INTO landmark_visits(session_id,landmark_id,first_opened_at) VALUES (?,?,?)')
    .run(id, landmark, new Date(timestamp).toISOString());
}
async function server(t) {
  const db = database(t);
  db.prepare('INSERT INTO admins(username,password_hash) VALUES (?,?)').run('report-test-admin', testHash);
  const config = { ...readConfig({}), rateLimitMax: 1000 };
  const listener = createApp(db, config).listen(0, '127.0.0.1');
  await once(listener, 'listening');
  const base = `http://127.0.0.1:${listener.address().port}`;
  config.adminOrigin = base;
  t.after(() => new Promise(resolve => listener.close(resolve)));
  const request = (path, cookie, body) => fetch(base + path, { method: body === undefined ? 'GET' : 'POST',
    headers: { ...(cookie ? { Cookie: cookie } : {}), ...(body === undefined ? {} : {
      'Content-Type': 'application/json', Origin: base, 'X-AKAR-Admin': '1',
    }) }, body: body === undefined ? undefined : JSON.stringify(body) });
  const login = await request('/api/admin/login', undefined, { username: 'report-test-admin', password: testPassword });
  assert.equal(login.status, 200);
  return { db, request, cookie: login.headers.get('set-cookie').split(';')[0] };
}

test('Manila presets have exact UTC boundaries and completed month semantics', () => {
  const week = resolveRange({ period: 'this_week' }, now);
  assert.equal(week.start_date, '2026-04-06');
  assert.equal(week.end_date, '2026-04-08');
  assert.equal(week.start_utc, '2026-04-05T16:00:00.000Z');
  assert.equal(week.end_utc_exclusive, '2026-04-08T16:00:00.000Z');
  const month = resolveRange({}, now);
  assert.equal(month.start_date, '2026-04-01');
  const three = resolveRange({ period: 'last_3_months' }, now);
  assert.equal(three.start_date, '2026-01-01');
  assert.equal(three.end_date, '2026-03-31');
  assert.equal(three.days, 90);
  assert.equal(three.grouping, 'weekly');
});

test('Philippine day, Monday and year rollover do not use the host timezone', () => {
  const boundary = new Date('2025-12-31T16:00:00.000Z');
  const month = resolveRange({}, boundary);
  assert.equal(month.start_date, '2026-01-01');
  assert.equal(month.days, 1);
  assert.equal(resolveRange({ period: 'this_week' }, new Date('2026-04-05T15:59:59.999Z')).start_date, '2026-03-30');
  assert.equal(resolveRange({ period: 'this_week' }, new Date('2026-04-05T16:00:00.000Z')).start_date, '2026-04-06');
});

test('empty database returns zeros, complete period denominators and null device percentages', t => {
  const data = buildReport(database(t), {}, now);
  assert.equal(data.metrics.total_sessions, 0);
  assert.equal(data.metrics.total_landmark_views, 0);
  assert.equal(data.metrics.weekly_average.value, 0);
  assert.equal(data.metrics.weekly_average.periods.length, 4);
  assert.equal(data.metrics.monthly_average.periods.length, 3);
  assert.equal(data.landmarks.length, 5);
  assert.equal(data.devices.length, 4);
  assert.ok(data.devices.every(row => row.sessions === 0 && row.percentage === null));
  assert.ok(data.usage.every(row => row.sessions === 0));
  assert.ok(data.landmarks.every(row => row.views === 0));
});

test('total sessions and daily trend include exact start and exclude next-day midnight', t => {
  const db = database(t);
  session(db, '2026-03-31T15:59:59.999Z');
  session(db, '2026-03-31T16:00:00.000Z', 'tablet');
  session(db, '2026-04-01T15:59:59.999Z', 'mobile');
  session(db, '2026-04-01T16:00:00.000Z');
  const data = buildReport(db, custom('2026-04-01'), now);
  assert.equal(data.metrics.total_sessions, 2);
  assert.deepEqual(data.usage, [{ start_date: '2026-04-01', end_date: '2026-04-01', sessions: 2 }]);
});

test('weekly average includes four completed Monday-Sunday weeks including zero weeks', t => {
  const db = database(t);
  session(db, '2026-03-08T15:59:59.999Z'); // Before first week.
  session(db, '2026-03-08T16:00:00.000Z');
  session(db, '2026-03-09T02:00:00.000Z');
  session(db, '2026-03-29T16:00:00.000Z');
  session(db, '2026-04-05T15:59:59.999Z');
  session(db, '2026-04-05T16:00:00.000Z'); // Current week excluded.
  const result = buildReport(db, {}, now).metrics.weekly_average;
  assert.equal(result.value, 1);
  assert.equal(result.denominator, 4);
  assert.deepEqual(result.periods.map(row => row.sessions), [2, 0, 0, 2]);
  assert.equal(result.start_date, '2026-03-09');
  assert.equal(result.end_date, '2026-04-05');
});

test('monthly average includes three completed months, zeros, and exact month boundaries', t => {
  const db = database(t);
  session(db, '2025-12-31T15:59:59.999Z');
  session(db, '2025-12-31T16:00:00.000Z');
  session(db, '2026-03-01T00:00:00.000Z');
  session(db, '2026-03-31T15:59:59.999Z');
  session(db, '2026-03-31T16:00:00.000Z');
  const result = buildReport(db, {}, now).metrics.monthly_average;
  assert.equal(result.value, 1);
  assert.equal(result.denominator, 3);
  assert.deepEqual(result.periods.map(row => row.sessions), [1, 0, 2]);
});

test('average periods stay independent of selected reporting dates', t => {
  const db = database(t);
  session(db, '2026-03-20T03:00:00Z');
  session(db, '2026-04-01T03:00:00Z');
  const a = buildReport(db, custom('2026-04-01'), now);
  const b = buildReport(db, custom('2026-02-01'), now);
  assert.equal(a.metrics.total_sessions, 1);
  assert.equal(b.metrics.total_sessions, 0);
  assert.deepEqual(a.metrics.weekly_average, b.metrics.weekly_average);
  assert.deepEqual(a.metrics.monthly_average, b.metrics.monthly_average);
});

test('landmark views use opening timestamp independent of session start and include all five rankings', t => {
  const db = database(t);
  const old = session(db, '2026-03-01T00:00:00Z');
  const fresh = session(db, '2026-04-01T00:00:00Z');
  visit(db, old, 'urduja_house', '2026-04-01T00:00:00Z');
  visit(db, fresh, 'urduja_house', '2026-04-01T01:00:00Z');
  visit(db, fresh, 'casa_real', '2026-04-01T15:59:59.999Z');
  visit(db, fresh, 'limahong_channel', '2026-04-01T16:00:00Z');
  assert.throws(() => visit(db, old, 'urduja_house', '2026-04-01T05:00:00Z'), /UNIQUE/);
  const data = buildReport(db, custom('2026-04-01'), now);
  assert.equal(data.metrics.total_sessions, 1);
  assert.equal(data.metrics.total_landmark_views, 3);
  assert.deepEqual(data.landmarks.map(row => row.views), [2, 1, 0, 0, 0]);
  assert.equal(new Set(data.landmarks.map(row => row.landmark_id)).size, 5);
  assert.equal(data.landmarks[0].landmark_id, 'urduja_house');
  assert.equal(data.landmarks[1].landmark_id, 'casa_real');
});

test('device percentages use filtered sessions and include unknown', t => {
  const db = database(t);
  for (const device of ['mobile', 'mobile', 'tablet', 'desktop', 'unknown']) session(db, '2026-04-01T00:00:00Z', device);
  session(db, '2026-03-01T00:00:00Z', 'desktop');
  const data = buildReport(db, custom('2026-04-01'), now);
  assert.deepEqual(data.devices.map(row => row.percentage), [40, 20, 20, 20]);
  assert.deepEqual(data.devices.map(row => row.sessions), [2, 1, 1, 1]);
});

test('weekly and monthly trend buckets clip edge periods and fill missing intervals', t => {
  const db = database(t);
  session(db, '2026-01-02T00:00:00Z');
  session(db, '2026-03-01T00:00:00Z');
  const weekly = buildReport(db, custom('2026-01-02', '2026-04-08'), now);
  assert.equal(weekly.range.grouping, 'weekly');
  assert.equal(weekly.usage[0].start_date, '2026-01-02');
  assert.equal(weekly.usage[0].end_date, '2026-01-04');
  assert.equal(weekly.usage.at(-1).end_date, '2026-04-08');
  assert.equal(weekly.usage.reduce((n, row) => n + row.sessions, 0), 2);
  assert.ok(weekly.usage.some(row => row.sessions === 0));
  const monthly = buildReport(db, custom('2025-01-15', '2026-04-08'), now);
  assert.equal(monthly.range.grouping, 'monthly');
  assert.equal(monthly.usage.length, 16);
  assert.equal(monthly.usage[0].start_date, '2025-01-15');
  assert.equal(monthly.usage.at(-1).end_date, '2026-04-08');
  assert.equal(monthly.usage.reduce((n, row) => n + row.sessions, 0), 2);
});

test('invalid, duplicate, future, impossible, and excessive date parameters are rejected', () => {
  for (const query of [custom('2026-02-30'), custom('2026-04-02', '2026-04-01'),
    custom('2026-04-09'), custom('1999-01-01'), custom('2026-4-1'), custom('2026-04-01T00:00:00Z'),
    { period: 'custom', start: '2026-04-01' }, { period: ['this_week', 'custom'] },
    { period: 'this_month', start: '2026-04-01' }, { period: 'all' }, { timezone: 'UTC' },
    custom('2000-01-01', '2026-04-01'), custom("2026-04-01' OR 1=1 --")]) {
    assert.throws(() => resolveRange(query, now));
  }
  assert.equal(resolveRange(custom('2024-02-29'), now).days, 1);
  const end = new Date('2026-04-08T00:00:00Z');
  const start = new Date(end - (MAX_RANGE_DAYS - 1) * 86400000).toISOString().slice(0, 10);
  assert.equal(resolveRange(custom(start, '2026-04-08'), now).days, MAX_RANGE_DAYS);
});

test('reports and dashboard HTML require authentication, logout revokes access, assets stay local', async t => {
  const f = await server(t);
  for (const path of ['/api/admin/reports', '/admin/dashboard', '/admin/dashboard.html']) {
    assert.equal((await f.request(path)).status, 401);
    const authenticated = await f.request(path, f.cookie);
    assert.equal(authenticated.status, 200);
    assert.equal(authenticated.headers.get('cache-control'), 'no-store');
  }
  assert.equal((await f.request('/admin//dashboard.html')).status, 404);
  const chart = await f.request('/admin/vendor/chart.js');
  assert.equal(chart.status, 200);
  assert.match(await chart.text(), /Chart\.js v4\.5\.1/);
  assert.equal((await f.request('/admin/vendor/package.json')).status, 404);
  assert.equal((await f.request('/api/admin/logout', f.cookie, {})).status, 200);
  assert.equal((await f.request('/api/admin/reports', f.cookie)).status, 401);
  const again = await f.request('/api/admin/login', undefined, { username: 'report-test-admin', password: testPassword });
  assert.equal(again.status, 200);
  const expiringCookie = again.headers.get('set-cookie').split(';')[0];
  const currentTime = Date.now();
  f.db.prepare('UPDATE admin_sessions SET created_at = ?, expires_at = ?').run(currentTime - 2000, currentTime - 1000);
  assert.equal((await f.request('/api/admin/reports', expiringCookie)).status, 401);
  assert.equal((await f.request('/admin/dashboard', expiringCookie)).status, 401);
});

test('report API validates query parameters and exposes only aggregates', async t => {
  const f = await server(t);
  for (const suffix of ['?period=custom&start=2026-02-30&end=2026-03-01', '?period=all', '?period=this_week&period=this_month']) {
    const result = await f.request('/api/admin/reports' + suffix, f.cookie);
    assert.equal(result.status, 400);
    assert.equal((await result.json()).error.code, 'invalid_date_range');
  }
  const id = session(f.db, new Date());
  const result = await f.request('/api/admin/reports', f.cookie);
  const body = await result.json();
  assert.equal(body.data.metrics.total_sessions, 1);
  const serialized = JSON.stringify(body);
  for (const secret of [id, testHash, 'password_hash', 'token_hash', 'session_id', 'report-test-admin']) assert.equal(serialized.includes(secret), false);
});

test('public landmark API remains idempotent and report counts one pair', async t => {
  const f = await server(t);
  const id = randomUUID();
  assert.equal((await f.request('/api/sessions', undefined, { session_id: id })).status, 201);
  assert.equal((await f.request('/api/landmark-visits', undefined, { session_id: id, landmark_id: 'urduja_house' })).status, 201);
  assert.equal((await f.request('/api/landmark-visits', undefined, { session_id: id, landmark_id: 'urduja_house' })).status, 200);
  const report = await (await f.request('/api/admin/reports', f.cookie)).json();
  assert.equal(report.data.metrics.total_landmark_views, 1);
});

test('report reads do not mutate visitor records or the approved four-table schema', t => {
  const db = database(t);
  session(db, '2026-04-01T00:00:00Z');
  const before = db.prepare('SELECT total_changes() AS n').get().n;
  buildReport(db, {}, now);
  assert.equal(db.prepare('SELECT total_changes() AS n').get().n, before);
  assert.equal(execFileSync('git', ['diff', 'HEAD', '--', 'src/db/schema.sql'], { cwd: moduleRoot, encoding: 'utf8' }), '');
});
