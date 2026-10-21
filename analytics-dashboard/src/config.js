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
  return {
    host: env.HOST || '127.0.0.1',
    port: integerSetting(env, 'PORT', 3000, 65535),
    databasePath: resolve(moduleRoot, env.DATABASE_PATH || 'data/analytics.sqlite'),
    rateLimitWindowMs: integerSetting(env, 'RATE_LIMIT_WINDOW_MS', 60000, 3600000),
    rateLimitMax: integerSetting(env, 'RATE_LIMIT_MAX', 120, 100000),
    trustedProxies: (env.TRUSTED_PROXIES || '').split(',').map(value => value.trim()).filter(Boolean),
  };
}
