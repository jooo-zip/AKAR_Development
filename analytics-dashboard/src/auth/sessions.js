import { createHash, randomBytes } from 'node:crypto';
import { errorResponse } from '../routes/analytics.js';

const digest = value => createHash('sha256').update(value).digest('hex');
const tokenPattern = /^[A-Za-z0-9_-]{43}$/;

export function createAdminSessions(db, config) {
  const cookieName = config.secureCookies ? '__Host-akar_admin' : 'akar_admin_local';
  const cookieOptions = { httpOnly: true, secure: config.secureCookies, sameSite: 'strict', path: '/' };
  function readToken(req) {
    const matches = (req.headers.cookie || '').split(';').map(part => part.trim())
      .filter(part => part.startsWith(`${cookieName}=`));
    if (matches.length !== 1) return null;
    const token = matches[0].slice(cookieName.length + 1);
    return tokenPattern.test(token) ? token : null;
  }
  function revoke(req) {
    const token = readToken(req);
    if (token) db.prepare('DELETE FROM admin_sessions WHERE token_hash = ?').run(digest(token));
  }
  function clear(res) { res.clearCookie(cookieName, cookieOptions); }
  function issue(req, res, admin) {
    const token = randomBytes(32).toString('base64url');
    const now = Date.now();
    const expires = now + config.adminSessionTtlMs;
    db.exec('BEGIN IMMEDIATE');
    try {
      revoke(req);
      db.prepare('DELETE FROM admin_sessions WHERE expires_at <= ?').run(now);
      db.prepare(`INSERT INTO admin_sessions
        (token_hash, admin_id, credential_fingerprint, created_at, expires_at) VALUES (?, ?, ?, ?, ?)`)
        .run(digest(token), admin.admin_id, digest(admin.password_hash), now, expires);
      db.exec('COMMIT');
    } catch (error) { db.exec('ROLLBACK'); throw error; }
    res.cookie(cookieName, token, { ...cookieOptions, maxAge: config.adminSessionTtlMs });
    return expires;
  }
  function requireAdmin(req, res, next) {
    const token = readToken(req);
    const row = token && db.prepare(`SELECT s.expires_at, s.credential_fingerprint,
      a.admin_id, a.username, a.password_hash, a.is_active
      FROM admin_sessions s JOIN admins a ON a.admin_id = s.admin_id WHERE s.token_hash = ?`).get(digest(token));
    if (!row || !row.is_active || row.expires_at <= Date.now()
        || row.credential_fingerprint !== digest(row.password_hash)) {
      revoke(req);
      clear(res);
      return errorResponse(res, 401, 'authentication_required', 'Sign in to continue.');
    }
    req.admin = { admin_id: row.admin_id, username: row.username };
    req.adminSessionExpiresAt = new Date(row.expires_at).toISOString();
    next();
  }
  return { issue, revoke, clear, requireAdmin };
}
