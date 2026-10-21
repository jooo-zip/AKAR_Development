import { readConfig } from '../config.js';
import { openDatabase } from './database.js';

const config = readConfig();
const db = openDatabase(config.databasePath);
db.close();
console.log('Analytics database initialized. No administrator was created.');
