import { Router } from 'express';
import { validatePayload } from '../validation.js';

export function errorResponse(res, status, code, message) {
  return res.status(status).json({ ok: false, error: { code, message } });
}

export function analyticsRouter(db) {
  const router = Router();
  const findSession = db.prepare('SELECT * FROM sessions WHERE session_id = ?');
  const insertSession = db.prepare(`
    INSERT INTO sessions (session_id, device_type, access_source) VALUES (?, ?, ?)
    ON CONFLICT(session_id) DO NOTHING
  `);
  const findVisit = db.prepare('SELECT * FROM landmark_visits WHERE session_id = ? AND landmark_id = ?');
  const insertVisit = db.prepare(`
    INSERT INTO landmark_visits (session_id, landmark_id) VALUES (?, ?)
    ON CONFLICT(session_id, landmark_id) DO NOTHING
  `);

  router.get('/health', (_req, res) => {
    db.prepare('SELECT 1').get();
    res.json({ ok: true, data: { status: 'ok', service: 'akar-museum-analytics' } });
  });

  router.post('/sessions', (req, res) => {
    const result = validatePayload(req.body, 'session');
    if (result.error) return errorResponse(res, 400, 'invalid_payload', result.error);
    const { session_id, device_type, access_source } = result.value;
    const created = insertSession.run(session_id, device_type, access_source).changes === 1;
    // A replay preserves the first timestamp and metadata, even if the client changes them.
    return res.status(created ? 201 : 200).json({
      ok: true, data: { created, session: findSession.get(session_id) },
    });
  });

  router.post('/landmark-visits', (req, res) => {
    const result = validatePayload(req.body, 'visit');
    if (result.error) return errorResponse(res, 400, 'invalid_payload', result.error);
    const { session_id, landmark_id } = result.value;
    if (!findSession.get(session_id)) {
      return errorResponse(res, 404, 'session_not_found', 'Create the session before recording a landmark visit.');
    }
    const created = insertVisit.run(session_id, landmark_id).changes === 1;
    return res.status(created ? 201 : 200).json({
      ok: true, data: { created, visit: findVisit.get(session_id, landmark_id) },
    });
  });
  return router;
}
