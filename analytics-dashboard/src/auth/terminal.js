import { emitKeypressEvents } from 'node:readline';

export function readHiddenLine(prompt, input = process.stdin, output = process.stdout) {
  if (!input.isTTY || !output.isTTY || typeof input.setRawMode !== 'function') {
    return Promise.reject(new Error('A local interactive terminal is required; piped passwords are not accepted.'));
  }
  emitKeypressEvents(input);
  const wasRaw = Boolean(input.isRaw);
  // Fail before displaying a password prompt if the host cannot disable echo.
  input.setRawMode(true);
  input.resume();
  output.write(prompt);
  return new Promise((resolve, reject) => {
    let value = '';
    function finish(error) {
      input.off('keypress', onKey);
      input.off('end', onEnd);
      input.setRawMode(wasRaw);
      input.pause();
      output.write('\n');
      if (error) reject(error); else resolve(value);
      value = '';
    }
    function onEnd() { finish(new Error('Input ended. No administrator created.')); }
    function onKey(text, key = {}) {
      if (key.ctrl && ['c', 'd'].includes(key.name)) return finish(new Error('Cancelled. No administrator created.'));
      if (['return', 'enter'].includes(key.name)) return finish();
      if (key.name === 'backspace') { value = [...value].slice(0, -1).join(''); return; }
      if (!key.ctrl && !key.meta && text && !/[\u0000-\u001f\u007f]/.test(text)) {
        if (Buffer.byteLength(value + text, 'utf8') <= 512) value += text;
        else finish(new Error('Password exceeds 512 UTF-8 bytes. No administrator created.'));
      }
    }
    input.on('keypress', onKey);
    input.once('end', onEnd);
  });
}
