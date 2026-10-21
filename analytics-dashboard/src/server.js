import { readConfig } from './config.js';
import { openDatabase } from './db/database.js';
import { createApp } from './app.js';

const config = readConfig();
const db = openDatabase(config.databasePath);
const server = createApp(db, config).listen(config.port, config.host, () => {
  console.log(`AKAR analytics listening on http://${config.host}:${config.port}`);
});
server.requestTimeout = 10000;
server.headersTimeout = 10000;

let stopping = false;
function stop() {
  if (stopping) return;
  stopping = true;
  server.close(() => db.close());
  const deadline = setTimeout(() => server.closeAllConnections(), 10000);
  deadline.unref();
}
process.once('SIGINT', stop);
process.once('SIGTERM', stop);
server.once('error', error => {
  console.error(`Server could not listen (${error.code || 'unknown_error'}).`);
  db.close();
  process.exitCode = 1;
});
