import { DatabaseSync } from 'node:sqlite';
import { readConfig } from '../config.js';

// Local read-only inspection: never expose database contents through a public API.
const db = new DatabaseSync(readConfig().databasePath, { readOnly: true });
try {
  console.log(JSON.stringify({
    counts: {
      sessions: db.prepare('SELECT count(*) AS count FROM sessions').get().count,
      landmark_visits: db.prepare('SELECT count(*) AS count FROM landmark_visits').get().count,
      admins: db.prepare('SELECT count(*) AS count FROM admins').get().count,
    },
    recent_sessions: db.prepare('SELECT * FROM sessions ORDER BY started_at DESC LIMIT 20').all(),
    recent_landmark_visits: db.prepare('SELECT * FROM landmark_visits ORDER BY first_opened_at DESC LIMIT 20').all(),
  }, null, 2));
} finally {
  db.close();
}
