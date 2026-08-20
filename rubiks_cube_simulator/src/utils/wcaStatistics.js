export function calculateWCAAverage(times, count) {
  if (times.length < count) return 'N/A';
  const sample = times.slice(-count).slice().sort((a, b) => a - b);
  const trimmed = sample.slice(1, -1);
  return formatTime(trimmed.reduce((sum, time) => sum + time, 0) / trimmed.length);
}

export function formatTime(ms) {
  if (Number.isNaN(ms) || ms === Infinity) return '00:00.00';
  const minutes = Math.floor(ms / 60000);
  const seconds = Math.floor((ms % 60000) / 1000);
  const centiseconds = Math.floor((ms % 1000) / 10);
  const minStr = minutes > 0 ? `${minutes}:` : '';
  const secStr = seconds < 10 && minutes > 0 ? `0${seconds}` : seconds;
  const centStr = centiseconds < 10 ? `0${centiseconds}` : centiseconds;
  return `${minStr}${secStr}.${centStr}`;
}