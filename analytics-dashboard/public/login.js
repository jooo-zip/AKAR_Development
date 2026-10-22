const form = document.querySelector('#login-form');
const message = document.querySelector('#form-message');
const signIn = document.querySelector('#sign-in');
const signedIn = document.querySelector('#signed-in');
const loginButton = document.querySelector('#sign-in-button');
const logoutButton = document.querySelector('#sign-out-button');
const password = document.querySelector('#password');
let expiryTimer;

function tell(text, focus = false) {
  message.textContent = text;
  if (focus) message.focus();
}
function showLogin(text = '') {
  clearTimeout(expiryTimer);
  signIn.hidden = false;
  signedIn.hidden = true;
  password.value = '';
  tell(text);
}
function showAdmin(data) {
  clearTimeout(expiryTimer);
  signIn.hidden = true;
  signedIn.hidden = false;
  password.value = '';
  document.querySelector('#signed-in-user').textContent = `Signed in as ${data.admin.username}.`;
  tell('');
  expiryTimer = setTimeout(() => showLogin('Your session expired. Sign in again.'),
    Math.max(0, Date.parse(data.expires_at) - Date.now()));
}
async function request(path, body) {
  const response = await fetch(`/api/admin/${path}`, {
    method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store',
    headers: body === undefined ? {} : { 'Content-Type': 'application/json', 'X-AKAR-Admin': '1' },
    body: body === undefined ? undefined : JSON.stringify(body),
    signal: AbortSignal.timeout(15000),
  });
  const result = await response.json();
  if (!response.ok) {
    const error = new Error(response.status === 429
      ? 'Too many sign-in attempts. Wait before trying again.'
      : result.error?.message || 'Unable to complete the request. Try again.');
    error.status = response.status;
    throw error;
  }
  return result.data;
}
form.addEventListener('submit', async event => {
  event.preventDefault();
  loginButton.disabled = true;
  loginButton.textContent = 'Signing in…';
  form.setAttribute('aria-busy', 'true');
  tell('');
  try {
    showAdmin(await request('login', { username: form.elements.username.value, password: password.value }));
    location.replace('/admin/dashboard');
  } catch (error) { tell(error.status ? error.message : 'Unable to connect. Please try again.', true); }
  finally {
    password.value = '';
    loginButton.disabled = false;
    loginButton.textContent = 'Sign In';
    form.removeAttribute('aria-busy');
  }
});
logoutButton.addEventListener('click', async () => {
  logoutButton.disabled = true;
  try {
    await request('logout', {});
    showLogin('You have signed out.');
    form.elements.username.focus();
  } catch (error) { tell(error.status ? error.message : 'Sign-out could not be confirmed. Please try again.', true); }
  finally { logoutButton.disabled = false; }
});
async function refresh() {
  try { showAdmin(await request('me')); }
  catch (error) {
    if (error.status === 401) showLogin(signedIn.hidden ? '' : 'Your session ended. Sign in again.');
    else tell('Unable to check sign-in status. Please try again.');
  }
}
window.addEventListener('focus', refresh);
refresh();
