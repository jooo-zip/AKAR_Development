import { createInterface } from 'node:readline/promises';
import { readConfig } from '../config.js';
import { openDatabase } from '../db/database.js';
import { provisionAdmin } from './provision.js';
import { readHiddenLine } from './terminal.js';

let db;
try {
  if (process.argv.length !== 2 || !process.stdin.isTTY || !process.stdout.isTTY) {
    throw new Error('Run npm.cmd run admin:create in an interactive terminal without arguments or redirected input.');
  }
  const prompt = createInterface({ input: process.stdin, output: process.stdout });
  let username;
  try { username = await prompt.question('Administrator username: '); }
  finally { prompt.close(); }
  let password = await readHiddenLine('Password (hidden; 15–128 characters): ');
  let confirmation = await readHiddenLine('Confirm password (hidden): ');
  if (password !== confirmation) throw new Error('Passwords do not match. No administrator created.');
  db = openDatabase(readConfig().databasePath);
  await provisionAdmin(db, username, password);
  password = '';
  confirmation = '';
  console.log('Administrator created. Sign in at /admin/.');
} catch (error) {
  // Expected validation messages contain no supplied credentials or database values.
  console.error(error.code ? 'Provisioning failed. Check local configuration and database availability.' : error.message);
  process.exitCode = 1;
} finally { db?.close(); }
