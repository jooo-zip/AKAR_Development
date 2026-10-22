const $ = selector => document.querySelector(selector);
const reports = $('#reports');
const status = $('#status');
const filters = $('#filters');
const apply = $('#apply');
const integer = new Intl.NumberFormat('en-PH');
const decimal = new Intl.NumberFormat('en-PH', { maximumFractionDigits: 2 });
const dateLabel = value => new Intl.DateTimeFormat('en-PH', {
  day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC',
}).format(new Date(`${value}T00:00:00Z`));
const spanLabel = row => row.start_date === row.end_date ? dateLabel(row.start_date)
  : `${dateLabel(row.start_date)} – ${dateLabel(row.end_date)}`;
let charts = [];
let requestNumber = 0;
let pending;
let expiryTimer;
let signedOut = false;
let applied = new URLSearchParams({ period: 'this_month' });

function clearReports() {
  reports.hidden = true;
  charts.forEach(chart => chart.destroy());
  charts = [];
}
function endSession() {
  signedOut = true;
  requestNumber++;
  pending?.abort();
  clearTimeout(expiryTimer);
  clearReports();
  apply.disabled = true;
  $('#logout').disabled = true;
  status.textContent = 'Your administrator session ended. Sign in again to view reports.';
  $('#login-link').hidden = false;
  status.focus();
}
async function api(path, options = {}) {
  const response = await fetch(`/api/admin/${path}`, {
    credentials: 'same-origin', cache: 'no-store', ...options,
  });
  if (response.status === 401) { endSession(); throw new Error('session-ended'); }
  const body = await response.json();
  if (!response.ok) {
    const error = new Error(response.status === 400 ? body.error?.message
      : response.status === 429 ? 'Too many requests. Wait a moment, then apply the dates again.'
        : 'Reports are temporarily unavailable. Please try again.');
    error.status = response.status;
    throw error;
  }
  return body.data;
}
function rows(target, values) {
  $(target).replaceChildren(...values.map(values => {
    const row = document.createElement('tr');
    values.forEach(value => { const cell = document.createElement('td'); cell.textContent = value; row.append(cell); });
    return row;
  }));
}
function draw(id, type, labels, values, options = {}) {
  charts.push(new Chart($(id), {
    type, data: { labels, datasets: [{ label: type === 'bar' ? 'Landmark views' : 'Sessions', data: values,
      backgroundColor: type === 'doughnut' ? ['#d37148', '#e8d5b4', '#8e6c51', '#6f3317'] : '#d37148',
      borderColor: type === 'doughnut' ? '#101d19' : '#d37148', borderWidth: 2,
      pointRadius: values.length > 40 ? 0 : 3, tension: 0, borderRadius: type === 'bar' ? 3 : 0,
    }] },
    options: { responsive: true, maintainAspectRatio: false, animation: false,
      plugins: { legend: { display: false } }, ...options },
  }));
}
function render(data) {
  $('#total-sessions').textContent = integer.format(data.metrics.total_sessions);
  $('#total-views').textContent = integer.format(data.metrics.total_landmark_views);
  $('#weekly-average').textContent = decimal.format(data.metrics.weekly_average.value);
  $('#monthly-average').textContent = decimal.format(data.metrics.monthly_average.value);
  $('#weekly-basis').textContent = spanLabel(data.metrics.weekly_average);
  $('#monthly-basis').textContent = spanLabel(data.metrics.monthly_average);
  $('#range-label').textContent = `${spanLabel(data.range)} · dates in Asia/Manila`;
  $('#updated').textContent = `Updated ${new Intl.DateTimeFormat('en-PH', {
    timeZone: data.timezone, hour: 'numeric', minute: '2-digit',
  }).format(new Date(data.generated_at))} PHT`;
  $('#grouping').textContent = `${data.range.grouping[0].toUpperCase() + data.range.grouping.slice(1)} intervals · partial edge periods included`;
  $('#usage-empty').hidden = data.metrics.total_sessions !== 0;
  $('#landmark-empty').hidden = data.metrics.total_landmark_views !== 0;
  $('#device-empty').hidden = data.metrics.total_sessions !== 0;
  $('#device-chart-container').hidden = data.metrics.total_sessions === 0;
  for (const input of [$('#start'), $('#end')]) input.max = data.today;
  if (!$('#start').value) $('#start').value = data.range.start_date;
  if (!$('#end').value) $('#end').value = data.range.end_date;
  rows('#usage-table', data.usage.map(row => [spanLabel(row), integer.format(row.sessions)]));
  rows('#landmark-table', data.landmarks.map(row => [row.name, integer.format(row.views)]));
  rows('#device-table', data.devices.map(row => [row.device_type[0].toUpperCase() + row.device_type.slice(1),
    integer.format(row.sessions), row.percentage === null ? '—' : `${row.percentage.toFixed(1)}%`]));
  reports.hidden = false;
  if (typeof Chart === 'undefined') {
    status.textContent = 'Charts could not load. The recorded statistics are available in the tables.';
    return;
  }
  Chart.defaults.color = '#d6c5ab';
  Chart.defaults.font.family = 'system-ui, sans-serif';
  const countAxis = { beginAtZero: true, ticks: { precision: 0 }, grid: { color: '#8e6c5133' } };
  draw('#usage-chart', 'line', data.usage.map(spanLabel), data.usage.map(row => row.sessions), {
    scales: { y: countAxis, x: { grid: { display: false }, ticks: { maxTicksLimit: 8, maxRotation: 0, font: { size: 10 } } } },
  });
  const shortNames = { co_cathedral: ['Co-Cathedral Parish', 'of the Epiphany'], urduja_house: 'Urduja House',
    provincial_capitol: ['Pangasinan Provincial', 'Capitol'], limahong_channel: 'Limahong Channel', casa_real: 'Casa Real' };
  draw('#landmark-chart', 'bar', data.landmarks.map(row => shortNames[row.landmark_id]), data.landmarks.map(row => row.views), {
    indexAxis: 'y', scales: { x: countAxis, y: { grid: { display: false }, ticks: { font: { size: 10 } } } },
  });
  if (data.metrics.total_sessions) draw('#device-chart', 'doughnut',
    data.devices.map(row => row.device_type), data.devices.map(row => row.sessions), { cutout: '72%' });
}
async function load() {
  if (signedOut) return;
  const sequence = ++requestNumber;
  pending?.abort();
  pending = new AbortController();
  const signal = AbortSignal.any([pending.signal, AbortSignal.timeout(15000)]);
  clearReports();
  apply.disabled = true;
  reports.setAttribute('aria-busy', 'true');
  status.textContent = 'Loading reports…';
  try {
    const identity = await api('me', { signal });
    if (sequence !== requestNumber) return;
    clearTimeout(expiryTimer);
    expiryTimer = setTimeout(endSession, Math.max(0, Date.parse(identity.expires_at) - Date.now()));
    const data = await api(`reports?${applied}`, { signal });
    if (sequence !== requestNumber) return;
    status.textContent = '';
    render(data);
  } catch (error) {
    if (sequence !== requestNumber || signedOut) return;
    clearReports();
    status.textContent = error.status ? error.message : 'Unable to load reports. Check your connection, then apply the dates again.';
    status.focus();
  } finally {
    if (sequence === requestNumber) { apply.disabled = signedOut; reports.removeAttribute('aria-busy'); }
  }
}
$('#period').addEventListener('change', () => {
  const custom = $('#period').value === 'custom';
  $('#custom-dates').hidden = !custom;
  for (const input of [$('#start'), $('#end')]) { input.disabled = !custom; input.required = custom; }
});
filters.addEventListener('submit', event => {
  event.preventDefault();
  applied = new URLSearchParams(new FormData(filters));
  load();
});
$('#logout').addEventListener('click', async () => {
  const button = $('#logout');
  button.disabled = true;
  requestNumber++;
  pending?.abort();
  clearReports();
  try {
    await api('logout', { method: 'POST', headers: { 'Content-Type': 'application/json', 'X-AKAR-Admin': '1' },
      body: '{}', signal: AbortSignal.timeout(15000) });
    signedOut = true;
    location.replace('/admin/');
  } catch {
    if (!signedOut) {
      $('#session-status').textContent = 'Logout could not be confirmed. Please try Logout again.';
      $('#session-status').focus();
      button.disabled = false;
      apply.disabled = false;
    }
  }
});
// Clear visible report data before the page can enter the browser's back/forward cache.
window.addEventListener('pagehide', () => { requestNumber++; pending?.abort(); clearReports(); });
window.addEventListener('pageshow', () => load());
window.addEventListener('focus', () => load());
