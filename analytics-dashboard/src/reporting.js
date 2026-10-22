import { DEVICE_TYPES, LANDMARK_IDS } from './validation.js';

const DAY = 86400000;
const OFFSET = 8 * 3600000;
export const REPORT_TIMEZONE = 'Asia/Manila';
export const MAX_RANGE_DAYS = 3660;
const names = [
  'Co-Cathedral Parish of the Epiphany of Our Lord', 'Urduja House',
  'Pangasinan Provincial Capitol', 'Limahong Channel', 'Casa Real',
];
const isoDay = date => date.toISOString().slice(0, 10);
const calendar = value => new Date(`${value}T00:00:00.000Z`);
const shift = (date, days) => new Date(date.getTime() + days * DAY);
const monthStart = (date, delta = 0) => new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + delta, 1));
const monday = date => shift(date, -((date.getUTCDay() + 6) % 7));
// Accepted reporting dates are modern Philippine dates (2000 onward), UTC+08:00.
const utcBoundary = date => new Date(date.getTime() - OFFSET).toISOString();
const localToday = now => calendar(new Intl.DateTimeFormat('en-CA', {
  timeZone: REPORT_TIMEZONE, year: 'numeric', month: '2-digit', day: '2-digit',
}).format(now));

export class ReportValidationError extends Error {}
function fail(message) { throw new ReportValidationError(message); }
function validDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const parsed = calendar(value);
  return Number.isFinite(parsed.getTime()) && isoDay(parsed) === value && value >= '2000-01-01';
}

export function resolveRange(query = {}, now = new Date()) {
  if (Object.keys(query).some(key => !['period', 'start', 'end'].includes(key))
      || Object.values(query).some(value => typeof value !== 'string')) fail('Use a single valid reporting period and dates.');
  const period = query.period ?? 'this_month';
  const today = localToday(now);
  let start;
  let end = shift(today, 1);
  if (period !== 'custom' && (query.start !== undefined || query.end !== undefined)) fail('Custom dates require the custom period.');
  switch (period) {
    case 'this_week': start = monday(today); break;
    case 'this_month': start = monthStart(today); break;
    case 'last_3_months': start = monthStart(today, -3); end = monthStart(today); break;
    case 'custom':
      if (!validDate(query.start) || !validDate(query.end)) fail('Enter valid dates in YYYY-MM-DD format, from 2000 onward.');
      start = calendar(query.start); end = shift(calendar(query.end), 1);
      if (start >= end) fail('The start date must be on or before the end date.');
      if (end > shift(today, 1)) fail('The end date cannot be later than today in Asia/Manila.');
      break;
    default: fail('Choose this_week, this_month, last_3_months, or custom.');
  }
  const days = (end - start) / DAY;
  if (days > MAX_RANGE_DAYS) fail(`Choose a range of at most ${MAX_RANGE_DAYS} days.`);
  return { period, start_date: isoDay(start), end_date: isoDay(shift(end, -1)),
    start_utc: utcBoundary(start), end_utc_exclusive: utcBoundary(end),
    days, grouping: days <= 62 ? 'daily' : days <= 366 ? 'weekly' : 'monthly' };
}

function intervals(start, end, grouping) {
  const result = [];
  for (let cursor = start; cursor < end;) {
    const next = grouping === 'daily' ? shift(cursor, 1)
      : grouping === 'weekly' ? shift(monday(cursor), 7) : monthStart(cursor, 1);
    const stop = next < end ? next : end;
    result.push({ start_date: isoDay(cursor), end_date: isoDay(shift(stop, -1)) });
    cursor = stop;
  }
  return result;
}
function sumDays(daily, start, end) {
  return daily.filter(row => row.day >= start && row.day <= end).reduce((sum, row) => sum + row.sessions, 0);
}

export function buildReport(db, query = {}, now = new Date()) {
  const range = resolveRange(query, now);
  const today = localToday(now);
  const weekEnd = monday(today);
  const weekStart = shift(weekEnd, -28);
  const monthEnd = monthStart(today);
  const monthBegin = monthStart(today, -3);
  const dailyQuery = db.prepare(`SELECT date(started_at, '+8 hours') AS day, count(*) AS sessions
    FROM sessions WHERE started_at >= ? AND started_at < ? GROUP BY day ORDER BY day`);
  const dailyBetween = (start, end) => dailyQuery.all(utcBoundary(start), utcBoundary(end));
  const average = (start, end, grouping, denominator) => {
    const days = dailyBetween(start, end);
    const periods = intervals(start, end, grouping).map(period => ({ ...period,
      sessions: sumDays(days, period.start_date, period.end_date) }));
    const total = periods.reduce((sum, period) => sum + period.sessions, 0);
    return { value: total / denominator, total_sessions: total, denominator,
      start_date: isoDay(start), end_date: isoDay(shift(end, -1)), periods };
  };
  // One read snapshot keeps cards and charts consistent during concurrent ingestion.
  db.exec('BEGIN');
  try {
    const daily = dailyQuery.all(range.start_utc, range.end_utc_exclusive);
    const total = daily.reduce((sum, row) => sum + row.sessions, 0);
    const usage = intervals(calendar(range.start_date), shift(calendar(range.end_date), 1), range.grouping)
      .map(period => ({ ...period, sessions: sumDays(daily, period.start_date, period.end_date) }));
    const visits = new Map(db.prepare(`SELECT landmark_id, count(*) AS views FROM landmark_visits
      WHERE first_opened_at >= ? AND first_opened_at < ? GROUP BY landmark_id`)
      .all(range.start_utc, range.end_utc_exclusive).map(row => [row.landmark_id, row.views]));
    const landmarks = LANDMARK_IDS.map((id, index) => ({ landmark_id: id, name: names[index], views: visits.get(id) ?? 0 }))
      .sort((a, b) => b.views - a.views || LANDMARK_IDS.indexOf(a.landmark_id) - LANDMARK_IDS.indexOf(b.landmark_id));
    const devices = new Map(db.prepare(`SELECT device_type, count(*) AS sessions FROM sessions
      WHERE started_at >= ? AND started_at < ? GROUP BY device_type`)
      .all(range.start_utc, range.end_utc_exclusive).map(row => [row.device_type, row.sessions]));
    const report = { timezone: REPORT_TIMEZONE, generated_at: now.toISOString(), today: isoDay(today), range,
      metrics: { total_sessions: total, total_landmark_views: landmarks.reduce((sum, row) => sum + row.views, 0),
        weekly_average: average(weekStart, weekEnd, 'weekly', 4),
        monthly_average: average(monthBegin, monthEnd, 'monthly', 3) },
      usage, landmarks, devices: DEVICE_TYPES.map(device_type => {
        const sessions = devices.get(device_type) ?? 0;
        return { device_type, sessions, percentage: total ? Math.round(sessions / total * 1000) / 10 : null };
      }) };
    db.exec('COMMIT');
    return report;
  } catch (error) { db.exec('ROLLBACK'); throw error; }
}
