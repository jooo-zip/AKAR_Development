import { errorResponse } from '../routes/analytics.js';

export function adminSecurity(config) {
  return (req, res, next) => {
    if (config.secureCookies && !req.secure) {
      return errorResponse(res, 403, 'https_required', 'Administrator access requires HTTPS.');
    }
    // Custom header + exact configured Origin defend login/logout CSRF. No CORS is enabled.
    // Never derive the allowed origin from untrusted Host/X-Forwarded-Host headers.
    if (!['GET', 'HEAD', 'OPTIONS'].includes(req.method)
        && (req.get('Origin') !== config.adminOrigin || req.get('X-AKAR-Admin') !== '1'
          || (req.get('Sec-Fetch-Site') && req.get('Sec-Fetch-Site') !== 'same-origin'))) {
      return errorResponse(res, 403, 'origin_rejected', 'Use the administrator page on the configured origin.');
    }
    next();
  };
}
