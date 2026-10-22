import { scrypt, randomBytes, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

const derive = promisify(scrypt);
const N = 131072;
const r = 8;
const p = 1;
const options = { N, r, p, maxmem: 256 * 1024 * 1024 };
// Used only to give unknown users a real verification operation, never as a login.
const dummy = `scrypt$${N}$${r}$${p}$${randomBytes(16).toString('hex')}$${randomBytes(64).toString('hex')}`;

export function validPassword(password) {
  return typeof password === 'string' && [...password].length >= 15
    && [...password].length <= 128 && Buffer.byteLength(password, 'utf8') <= 512;
}

export function normalizeUsername(username) {
  if (typeof username !== 'string') return null;
  const normalized = username.trim().toLowerCase();
  return /^[a-z0-9][a-z0-9._-]{2,63}$/.test(normalized) ? normalized : null;
}

export async function hashPassword(password) {
  if (!validPassword(password)) throw new Error('Use a password or passphrase of 15–128 characters (at most 512 UTF-8 bytes).');
  const salt = randomBytes(16);
  const derived = await derive(password, salt, 64, options);
  try {
    return `scrypt$${N}$${r}$${p}$${salt.toString('hex')}$${derived.toString('hex')}`;
  } finally { derived.fill(0); }
}

export async function verifyPassword(password, encoded) {
  // Accept only this known cost/format; malformed database values cannot request huge work.
  const format = /^scrypt\$131072\$8\$1\$([a-f0-9]{32})\$([a-f0-9]{128})$/;
  const match = typeof encoded === 'string' ? format.exec(encoded) : null;
  const parts = match || format.exec(dummy);
  const bounded = typeof password === 'string' && Buffer.byteLength(password, 'utf8') <= 512;
  const derived = await derive(bounded ? password : '', Buffer.from(parts[1], 'hex'), 64, options);
  try { return timingSafeEqual(derived, Buffer.from(parts[2], 'hex')) && Boolean(match) && bounded; }
  finally { derived.fill(0); }
}
