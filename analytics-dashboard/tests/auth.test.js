import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID, createHash } from 'node:crypto';
import { mkdtempSync, rmSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { once, EventEmitter } from 'node:events';
import { execFileSync, spawnSync } from 'node:child_process';
import { DatabaseSync } from 'node:sqlite';
import { openDatabase } from '../src/db/database.js';
import { createApp } from '../src/app.js';
import { moduleRoot, readConfig } from '../src/config.js';
import { hashPassword, verifyPassword, validPassword } from '../src/auth/passwords.js';
import { provisionAdmin } from '../src/auth/provision.js';
import { readHiddenLine } from '../src/auth/terminal.js';

// Ephemeral test credentials only, never provisioned in the operational database.
const password = `Test-only-${randomBytes(20).toString('hex')}`;
const passwordHash = await hashPassword(password);

async function fixture(t, overrides = {}) {
  const directory = mkdtempSync(join(tmpdir(), 'akar-auth-test-'));
  const path = join(directory, 'auth.sqlite');
  let db = openDatabase(path);
  const config = { ...readConfig({}), rateLimitMax: 1000, loginLimitMax: 100, ...overrides };
  let server;
  let base;
  async function start() {
    server = createApp(db, config).listen(0, '127.0.0.1');
    await once(server, 'listening');
    base = `http://127.0.0.1:${server.address().port}`;
    config.adminOrigin = config.secureCookies ? 'https://museum.example' : base;
  }
  await start();
  t.after(async () => {
    await new Promise(resolve => server.close(resolve));
    db.close();
    rmSync(directory, { recursive: true, force: true });
  });
  async function request(endpoint, { body, cookie, headers = {}, method } = {}) {
    const response = await fetch(base + endpoint, {
      method: method || (body === undefined ? 'GET' : 'POST'),
      headers: {
        ...(body === undefined ? {} : { 'Content-Type': 'application/json', Origin: config.adminOrigin, 'X-AKAR-Admin': '1' }),
        ...(cookie ? { Cookie: cookie } : {}), ...headers,
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await response.text();
    return { status: response.status, headers: response.headers,
      body: response.headers.get('content-type')?.includes('application/json') ? JSON.parse(text) : text,
      cookie: response.headers.get('set-cookie')?.split(';')[0] };
  }
  function seed() { db.prepare('INSERT INTO admins(username,password_hash) VALUES (?,?)').run('museum-admin', passwordHash); }
  async function login(options = {}) { return request('/api/admin/login', { body: { username: 'museum-admin', password }, ...options }); }
  return { get db() { return db; }, path, config, request, login, seed,
    restart: async () => {
      await new Promise(resolve => server.close(resolve));
      db.close();
      db = openDatabase(path);
      await start();
    } };
}

test('scrypt hashes are salted, use approved cost, and verify without storing plaintext', async () => {
  const another = await hashPassword(password);
  assert.notEqual(another, passwordHash);
  assert.match(another, /^scrypt\$131072\$8\$1\$/);
  assert.equal(another.includes(password), false);
  assert.equal(await verifyPassword(password, another), true);
  assert.equal(await verifyPassword('incorrect test password', another), false);
  assert.equal(await verifyPassword(password, 'malformed hash'), false);
  assert.equal(await verifyPassword(password, undefined), false);
  assert.equal(validPassword('too-short'), false);
  assert.equal(validPassword('x'.repeat(129)), false);
  await assert.rejects(hashPassword('short'));
});

test('local provisioning normalizes usernames, rejects duplicates and creates no visitor records', async t => {
  const f = await fixture(t);
  const admin = await provisionAdmin(f.db, ' Museum.Admin ', password);
  assert.deepEqual(admin, { admin_id: 1, username: 'museum.admin' });
  const row = f.db.prepare('SELECT * FROM admins').get();
  assert.equal(row.is_active, 1);
  assert.equal(await verifyPassword(password, row.password_hash), true);
  await assert.rejects(provisionAdmin(f.db, 'MUSEUM.ADMIN', password), /already exists/);
  await assert.rejects(provisionAdmin(f.db, 'invalid name', password), /Username/);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM admins').get().n, 1);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM sessions').get().n, 0);
});

test('hidden password prompt does not echo input and restores terminal state', async () => {
  const input = new EventEmitter();
  input.isTTY = true;
  input.isRaw = false;
  input.setRawMode = value => { input.isRaw = value; };
  input.resume = () => {};
  input.pause = () => {};
  let outputText = '';
  const output = { isTTY: true, write: text => { outputText += text; } };
  const result = readHiddenLine('Password: ', input, output);
  input.emit('keypress', 'private-test-input', {});
  input.emit('keypress', '\r', { name: 'return' });
  assert.equal(await result, 'private-test-input');
  assert.equal(outputText, 'Password: \n');
  assert.equal(input.isRaw, false);
  const cancelled = readHiddenLine('Password: ', input, output);
  input.emit('keypress', '', { ctrl: true, name: 'c' });
  await assert.rejects(cancelled, /Cancelled/);
  assert.equal(input.isRaw, false);
  outputText = '';
  input.setRawMode = () => { throw new Error('Terminal mode unavailable'); };
  assert.throws(() => readHiddenLine('Password: ', input, output), /Terminal mode/);
  assert.equal(outputText, '', 'Never invite password input until echo is disabled');
});

test('provisioning CLI rejects password arguments and redirected input without echoing them', () => {
  const script = resolve(moduleRoot, 'src/auth/create-admin.js');
  for (const args of [[], ['do-not-echo-this-test-value']]) {
    const child = spawnSync(process.execPath, [script, ...args], { input: 'do-not-echo-this-test-value\n', encoding: 'utf8' });
    assert.equal(child.status, 1);
    assert.match(child.stderr, /interactive terminal/);
    assert.equal((child.stdout + child.stderr).includes('do-not-echo-this-test-value'), false);
  }
});

test('successful login sets HttpOnly SameSite cookie and exposes only public administrator fields', async t => {
  const f = await fixture(t); f.seed();
  const result = await f.login();
  assert.equal(result.status, 200);
  assert.deepEqual(result.body.data.admin, { admin_id: 1, username: 'museum-admin' });
  assert.match(result.headers.get('set-cookie'), /HttpOnly/);
  assert.match(result.headers.get('set-cookie'), /SameSite=Strict/);
  assert.match(result.headers.get('set-cookie'), /Path=\//);
  assert.match(result.headers.get('set-cookie'), /Max-Age=28800/);
  assert.equal(JSON.stringify(result.body).includes(passwordHash), false);
  const row = f.db.prepare('SELECT * FROM admin_sessions').get();
  assert.equal(row.token_hash, createHash('sha256').update(result.cookie.split('=')[1]).digest('hex'));
  assert.equal(JSON.stringify(row).includes(result.cookie.split('=')[1]), false);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM sessions').get().n, 0);
  const me = await f.request('/api/admin/me', { cookie: result.cookie });
  assert.equal(me.status, 200);
  assert.deepEqual(me.body.data.admin, result.body.data.admin);
});

test('unknown, incorrect and inactive credentials get the same generic error', async t => {
  const f = await fixture(t); f.seed();
  const wrong = await f.login({ body: { username: 'museum-admin', password: 'wrong test password' } });
  const unknown = await f.login({ body: { username: 'absent-admin', password } });
  f.db.prepare('UPDATE admins SET is_active = 0').run();
  const inactive = await f.login();
  for (const result of [wrong, unknown, inactive]) {
    assert.equal(result.status, 401);
    assert.deepEqual(result.body, wrong.body);
    assert.equal(result.cookie, undefined);
  }
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM admin_sessions').get().n, 0);
});

test('failed logins are throttled even when usernames change', async t => {
  const f = await fixture(t, { loginLimitMax: 2 });
  for (const username of ['test-one', 'test-two']) {
    assert.equal((await f.login({ body: { username, password } })).status, 401);
  }
  const blocked = await f.login({ body: { username: 'test-three', password } });
  assert.equal(blocked.status, 429);
  assert.ok(Number(blocked.headers.get('retry-after')) > 0);
});

test('username failure limit applies across trusted client networks; successful login does not consume failures', async t => {
  const f = await fixture(t, { loginLimitMax: 2, trustedProxies: ['loopback'] }); f.seed();
  for (let i = 0; i < 3; i++) assert.equal((await f.login()).status, 200);
  for (const address of ['192.0.2.1', '192.0.2.2']) {
    assert.equal((await f.login({ body: { username: 'museum-admin', password: 'wrong password' },
      headers: { 'X-Forwarded-For': address } })).status, 401);
  }
  assert.equal((await f.login({ headers: { 'X-Forwarded-For': '192.0.2.3' } })).status, 429);
});

test('administrator routes reject missing, fabricated and duplicate cookies; public tracking stays available', async t => {
  const f = await fixture(t);
  for (const cookie of [undefined, 'akar_admin_local=fabricated', `akar_admin_local=${randomBytes(32).toString('base64url')}`,
    'akar_admin_local=one; akar_admin_local=two']) {
    assert.equal((await f.request('/api/admin/me', { cookie })).status, 401);
    assert.equal((await f.request('/api/admin/future-protected-route', { cookie })).status, 401);
  }
  const session_id = randomUUID();
  assert.equal((await f.request('/api/sessions', { body: { session_id } })).status, 201);
  assert.equal((await f.request('/api/landmark-visits', { body: { session_id, landmark_id: 'urduja_house' } })).status, 201);
  assert.equal((await f.request('/api/admin/register', { body: { username: 'test', password } })).status, 401);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM admins').get().n, 0);
});

test('logout deletes the server record and copied cookies cannot be replayed, including after restart', async t => {
  const f = await fixture(t); f.seed();
  const { cookie } = await f.login();
  const result = await f.request('/api/admin/logout', { cookie, body: {} });
  assert.equal(result.status, 200);
  assert.match(result.headers.get('set-cookie'), /Expires=Thu, 01 Jan 1970/);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM admin_sessions').get().n, 0);
  await f.restart();
  assert.equal((await f.request('/api/admin/me', { cookie })).status, 401);
  assert.equal((await f.request('/api/admin/logout', { body: {} })).status, 200);
});

test('persistent authenticated sessions survive server/database restart', async t => {
  const f = await fixture(t); f.seed();
  const { cookie } = await f.login();
  await f.restart();
  assert.equal((await f.request('/api/admin/me', { cookie })).status, 200);
});

test('re-login rotates a token and revokes its predecessor without ending another device session', async t => {
  const f = await fixture(t); f.seed();
  const first = await f.login();
  const otherDevice = await f.login();
  const fresh = await f.login({ cookie: first.cookie });
  assert.notEqual(fresh.cookie, first.cookie);
  assert.equal((await f.request('/api/admin/me', { cookie: first.cookie })).status, 401);
  assert.equal((await f.request('/api/admin/me', { cookie: otherDevice.cookie })).status, 200);
  assert.equal((await f.request('/api/admin/me', { cookie: fresh.cookie })).status, 200);
});

test('expired sessions are rejected and removed server-side', async t => {
  const f = await fixture(t); f.seed();
  const { cookie } = await f.login();
  f.db.prepare('UPDATE admin_sessions SET created_at = ?, expires_at = ?').run(Date.now() - 2000, Date.now() - 1000);
  assert.equal((await f.request('/api/admin/me', { cookie })).status, 401);
  assert.equal(f.db.prepare('SELECT count(*) AS n FROM admin_sessions').get().n, 0);
});

test('administrator deactivation or password-hash change invalidates existing access', async t => {
  const f = await fixture(t); f.seed();
  const first = await f.login();
  f.db.prepare('UPDATE admins SET is_active = 0').run();
  assert.equal((await f.request('/api/admin/me', { cookie: first.cookie })).status, 401);
  f.db.prepare('UPDATE admins SET is_active = 1').run();
  const second = await f.login();
  f.db.prepare("UPDATE admins SET password_hash = 'changed-test-hash'").run();
  assert.equal((await f.request('/api/admin/me', { cookie: second.cookie })).status, 401);
});

test('login/logout reject absent or foreign origin, absent custom header and cross-site fetch metadata', async t => {
  const f = await fixture(t); f.seed();
  const { cookie } = await f.login();
  for (const headers of [{ Origin: '' }, { Origin: 'https://attacker.example' }, { 'X-AKAR-Admin': '' },
    { 'Sec-Fetch-Site': 'cross-site' }, { Origin: 'null' }]) {
    assert.equal((await f.login({ headers })).status, 403);
    assert.equal((await f.request('/api/admin/logout', { cookie, body: {}, headers })).status, 403);
  }
  assert.equal((await f.request('/api/admin/me', { cookie })).status, 200);
});

test('production requires explicit HTTPS origin, secure transport and __Host- HttpOnly cookies', async t => {
  assert.throws(() => readConfig({ NODE_ENV: 'production' }), /HTTPS/);
  assert.throws(() => readConfig({ NODE_ENV: 'production', ADMIN_ORIGIN: 'http://localhost:3000' }), /HTTPS/);
  assert.throws(() => readConfig({ ADMIN_ORIGIN: 'http://museum.example' }), /HTTPS/);
  assert.throws(() => readConfig({ ADMIN_ORIGIN: 'https://museum.example/path' }), /origin/);
  const production = readConfig({ NODE_ENV: 'production', ADMIN_ORIGIN: 'https://museum.example' });
  const f = await fixture(t, { secureCookies: production.secureCookies, trustedProxies: ['loopback'] }); f.seed();
  assert.equal((await f.login()).status, 403);
  const secure = await f.login({ headers: { 'X-Forwarded-Proto': 'https' } });
  assert.equal(secure.status, 200);
  assert.match(secure.headers.get('set-cookie'), /^__Host-akar_admin=/);
  assert.match(secure.headers.get('set-cookie'), /; Secure/);
  assert.equal(secure.headers.get('set-cookie').includes('Domain='), false);
});

test('approved fourth table upgrades the Milestone 1 schema without changing original records', () => {
  const directory = mkdtempSync(join(tmpdir(), 'akar-auth-upgrade-'));
  const path = join(directory, 'old.sqlite');
  let db;
  try {
    // HEAD is the user's committed Milestone 1 baseline, not a rewritten test fixture.
    const oldSchema = execFileSync('git', ['show', '5568040:analytics-dashboard/src/db/schema.sql'], {
      cwd: resolve(moduleRoot, '..'), encoding: 'utf8',
    });
    db = new DatabaseSync(path);
    db.exec(oldSchema);
    const session_id = randomUUID();
    db.prepare('INSERT INTO sessions(session_id) VALUES (?)').run(session_id);
    db.prepare('INSERT INTO landmark_visits(session_id,landmark_id) VALUES (?,?)').run(session_id, 'urduja_house');
    db.prepare('INSERT INTO admins(username,password_hash) VALUES (?,?)').run('preserved-admin', passwordHash);
    const before = JSON.stringify(['sessions', 'landmark_visits', 'admins'].map(table => db.prepare(`SELECT * FROM ${table}`).all()));
    db.close();
    db = openDatabase(path);
    assert.equal(JSON.stringify(['sessions', 'landmark_visits', 'admins'].map(table => db.prepare(`SELECT * FROM ${table}`).all())), before);
    assert.equal(db.prepare('SELECT count(*) AS n FROM admin_sessions').get().n, 0);
    assert.throws(() => db.prepare('INSERT INTO admin_sessions VALUES (?, ?, ?, ?, ?)')
      .run('a'.repeat(64), 999, 'b'.repeat(64), 1, 2), /FOREIGN KEY/);
  } finally { db?.close(); rmSync(directory, { recursive: true, force: true }); }
});

test('login page and local assets are available with security headers and no persistent token storage', async t => {
  const f = await fixture(t);
  const page = await f.request('/admin/');
  assert.equal(page.status, 200);
  for (const text of ['AKAR Admin', 'Museum Analytics Dashboard', 'Banáan Pangasinan Provincial Museum',
    'Temporary logo placeholder', 'autocomplete="current-password"', 'aria-live="polite"']) assert.ok(page.body.includes(text));
  assert.equal(page.headers.get('x-frame-options'), 'DENY');
  const passwordInput = page.body.match(/<input id="password"[^>]*>/)[0];
  assert.ok(Number(passwordInput.match(/maxlength="(\d+)"/)[1]) >= '😀'.repeat(128).length,
    'The browser must not truncate a valid 128-character Unicode password.');
  assert.match(page.headers.get('content-security-policy'), /frame-ancestors 'none'/);
  const script = await f.request('/admin/login.js');
  assert.equal(script.status, 200);
  assert.equal(/localStorage|sessionStorage/.test(script.body), false);
  assert.equal((await f.request('/admin/login.css')).status, 200);
  assert.equal((await f.request('/admin/../src/auth/passwords.js')).status, 404);
  assert.ok(readFileSync(resolve(moduleRoot, 'public/login.css'), 'utf8').includes('#101d19'));
});
