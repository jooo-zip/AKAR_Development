export const DEVICE_TYPES = ['mobile', 'tablet', 'desktop', 'unknown'];
export const ACCESS_SOURCES = ['museum_tablet', 'museum_qr', 'direct', 'unknown'];
export const LANDMARK_IDS = ['co_cathedral', 'urduja_house', 'provincial_capitol', 'limahong_channel', 'casa_real'];

const uuidV4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function validatePayload(body, kind) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { error: 'A JSON object is required.' };
  }
  const allowed = kind === 'session'
    ? ['session_id', 'device_type', 'access_source'] : ['session_id', 'landmark_id'];
  if (Object.keys(body).some(key => !allowed.includes(key))) {
    return { error: 'Unexpected fields are not accepted.' };
  }
  if (typeof body.session_id !== 'string' || !uuidV4.test(body.session_id)) {
    return { error: 'session_id must be a random UUID version 4.' };
  }
  const session_id = body.session_id.toLowerCase();
  if (kind === 'session') {
    const device_type = body.device_type === undefined ? 'unknown' : body.device_type;
    const access_source = body.access_source === undefined ? 'unknown' : body.access_source;
    if (!DEVICE_TYPES.includes(device_type) || !ACCESS_SOURCES.includes(access_source)) {
      return { error: 'device_type or access_source is invalid.' };
    }
    return { value: { session_id, device_type, access_source } };
  }
  if (!LANDMARK_IDS.includes(body.landmark_id)) {
    return { error: 'landmark_id must be one of the five supported landmark identifiers.' };
  }
  return { value: { session_id, landmark_id: body.landmark_id } };
}
