import express from 'express';
import { rateLimit, ipKeyGenerator } from 'express-rate-limit';
import { createHmac, randomBytes } from 'node:crypto';
import { analyticsRouter, errorResponse } from './routes/analytics.js';

export function createApp(db, config) {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', config.trustedProxies.length ? config.trustedProxies : false);
  app.use((_req, res, next) => {
    res.set('Cache-Control', 'no-store');
    res.set('X-Content-Type-Options', 'nosniff');
    next();
  });

  // Only transient abuse-control keys exist in memory. They are never analytics fields.
  // The process-local random key prevents stable identifiers across server restarts.
  const salt = randomBytes(32);
  app.use('/api', rateLimit({
    windowMs: config.rateLimitWindowMs,
    limit: config.rateLimitMax,
    standardHeaders: 'draft-8',
    legacyHeaders: false,
    keyGenerator: req => createHmac('sha256', salt)
      .update(ipKeyGenerator(req.ip || req.socket.remoteAddress || 'unknown')).digest('hex'),
    handler: (_req, res) => errorResponse(res, 429, 'rate_limited', 'Too many requests. Retry after the indicated delay.'),
  }));

  app.use('/api', (req, res, next) => {
    if (req.method === 'POST' && !req.is('application/json')) {
      return errorResponse(res, 415, 'unsupported_media_type', 'Use Content-Type: application/json.');
    }
    next();
  });
  app.use('/api', express.json({ limit: '4kb', strict: true, inflate: false }));
  app.use('/api', analyticsRouter(db));
  app.use((_req, res) => errorResponse(res, 404, 'not_found', 'Endpoint not found.'));

  app.use((error, _req, res, _next) => {
    if (error.type === 'entity.too.large') {
      return errorResponse(res, 413, 'payload_too_large', 'JSON payloads must not exceed 4 KiB.');
    }
    if (error.status === 415) {
      return errorResponse(res, 415, 'unsupported_encoding', 'Use uncompressed UTF-8 JSON.');
    }
    if (error.status === 400) {
      return errorResponse(res, 400, 'invalid_json', 'Request body is not valid JSON.');
    }
    // No payloads, identifiers, database paths, SQL, or stack traces in responses/logs.
    if (error.code === 'ERR_SQLITE_ERROR' && [5, 6].includes(error.errcode)) {
      res.set('Retry-After', '2');
      return errorResponse(res, 503, 'storage_busy', 'Storage is busy. Retry shortly.');
    }
    return errorResponse(res, 500, 'internal_error', 'The request could not be recorded. It may be retried.');
  });
  return app;
}
