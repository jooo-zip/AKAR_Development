import { hashPassword, normalizeUsername } from './passwords.js';

export async function provisionAdmin(db, username, password) {
  const normalized = normalizeUsername(username);
  if (!normalized) throw new Error('Username must contain 3–64 ASCII letters, digits, periods, underscores or hyphens, starting with a letter or digit.');
  if (db.prepare('SELECT 1 FROM admins WHERE lower(username) = ?').get(normalized)) {
    throw new Error('Username already exists.');
  }
  const hash = await hashPassword(password);
  try {
    const result = db.prepare('INSERT INTO admins(username, password_hash) VALUES (?, ?)').run(normalized, hash);
    return { admin_id: Number(result.lastInsertRowid), username: normalized };
  } catch (error) {
    if (error.errcode === 2067) throw new Error('Username already exists.');
    throw new Error('Administrator could not be created. Check local database availability.');
  }
}
