import { Router } from 'express';
import { rateLimit, ipKeyGenerator } from 'express-rate-limit';
import { createHmac, randomBytes } from 'node:crypto';
import { normalizeUsername, verifyPassword } from '../auth/passwords.js';
import { createAdminSessions } from '../auth/sessions.js';
import { adminSecurity } from '../auth/security.js';
import { errorResponse } from './analytics.js';

export function adminRouter(db, config) {
  const router = Router();
  const sessions = createAdminSessions(db, config);
  const salt = randomBytes(32);
  const keyHash = value => createHmac('sha256', salt).update(value).digest('hex');
  const failure = res => errorResponse(res, 401, 'invalid_credentials', 'Incorrect username or password.');
  const limitOptions = {
    windowMs: config.loginLimitWindowMs, limit: config.loginLimitMax,
    skipSuccessfulRequests: true, standardHeaders: 'draft-8', legacyHeaders: false,
    handler: (_req, res) => errorResponse(res, 429, 'login_rate_limited', 'Too many sign-in attempts. Try again later.'),
  };
  const byNetwork = rateLimit({ ...limitOptions,
    keyGenerator: req => keyHash(ipKeyGenerator(req.ip || req.socket.remoteAddress || 'unknown')) });
  const byUsername = rateLimit({ ...limitOptions,
    keyGenerator: req => keyHash(normalizeUsername(req.body?.username) || 'invalid-username') });
  // Each verification needs about 128 MiB. Bound work instead of accumulating a queue.
  let activeVerifications = 0;
  router.use(adminSecurity(config));
  router.post('/login', byNetwork, byUsername, async (req, res) => {
    const { username, password } = req.body || {};
    if (!req.body || Array.isArray(req.body)
        || Object.keys(req.body).some(key => !['username', 'password'].includes(key))
        || !normalizeUsername(username) || typeof password !== 'string'
        || Buffer.byteLength(password, 'utf8') > 512) return failure(res);
    if (activeVerifications >= 2) {
      res.set('Retry-After', '2');
      return errorResponse(res, 503, 'authentication_busy', 'Sign-in is busy. Try again shortly.');
    }
    activeVerifications++;
    try {
      const admin = db.prepare('SELECT * FROM admins WHERE username = ?').get(normalizeUsername(username));
      const verified = await verifyPassword(password, admin?.password_hash);
      const current = admin && db.prepare('SELECT * FROM admins WHERE admin_id = ?').get(admin.admin_id);
      if (!verified || !current?.is_active || current.password_hash !== admin.password_hash) return failure(res);
      const expires = sessions.issue(req, res, current);
      return res.json({ ok: true, data: {
        admin: { admin_id: current.admin_id, username: current.username },
        expires_at: new Date(expires).toISOString(),
      } });
    } finally { activeVerifications--; }
  });
  router.post('/logout', (req, res) => {
    sessions.revoke(req);
    sessions.clear(res);
    res.json({ ok: true, data: { signed_out: true } });
  });
  // Every future route added below this gate is administrator-only.
  router.use(sessions.requireAdmin);
  router.get('/me', (req, res) => res.json({ ok: true, data: {
    admin: req.admin, expires_at: req.adminSessionExpiresAt,
  } }));
  return router;
}
