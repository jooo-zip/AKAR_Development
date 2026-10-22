import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

export const moduleRoot = fileURLToPath(new URL('../', import.meta.url));

function integerSetting(env, key, fallback, maximum) {
  const raw = env[key] ?? String(fallback);
  if (!/^\d+$/.test(raw) || Number(raw) < 1 || Number(raw) > maximum) {
    throw new Error(`${key} must be an integer from 1 to ${maximum}.`);
  }
  return Number(raw);
}

export function readConfig(env = process.env) {
  if (env.DATABASE_PATH !== undefined && !env.DATABASE_PATH.trim()) {
    throw new Error('DATABASE_PATH must not be empty.');
  }
  const port = integerSetting(env, 'PORT', 3000, 65535);
  const production = env.NODE_ENV === 'production';
  const originText = env.ADMIN_ORIGIN || `http://127.0.0.1:${port}`;
  const origin = new URL(originText);
  if (origin.origin !== originText || origin.username || origin.password
      || !['http:', 'https:'].includes(origin.protocol)
      || (origin.protocol === 'http:' && !['localhost', '127.0.0.1', '[::1]'].includes(origin.hostname))
      || (production && (!env.ADMIN_ORIGIN || origin.protocol !== 'https:'))) {
    throw new Error('ADMIN_ORIGIN must be an exact HTTPS origin, or a loopback HTTP origin for local development. Production requires explicit HTTPS.');
  }
  return {
    host: env.HOST || '127.0.0.1',
    port,
    adminOrigin: origin.origin,
    secureCookies: origin.protocol === 'https:',
    adminSessionTtlMs: integerSetting(env, 'ADMIN_SESSION_TTL_MINUTES', 480, 1440) * 60000,
    loginLimitWindowMs: 15 * 60000,
    loginLimitMax: integerSetting(env, 'LOGIN_FAILURE_LIMIT', 5, 20),
    databasePath: resolve(moduleRoot, env.DATABASE_PATH || 'data/analytics.sqlite'),
    rateLimitWindowMs: integerSetting(env, 'RATE_LIMIT_WINDOW_MS', 60000, 3600000),
    rateLimitMax: integerSetting(env, 'RATE_LIMIT_MAX', 120, 100000),
    trustedProxies: (env.TRUSTED_PROXIES || '').split(',').map(value => value.trim()).filter(Boolean),
  };
}
