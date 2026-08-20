export function generateHoneycombNormalMap() {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = 'rgb(128, 128, 255)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  const size = 16;
  const height = size * Math.sqrt(3);
  ctx.lineWidth = 2;

  for (let y = -height; y < canvas.height + height; y += height) {
    for (let x = -size; x < canvas.width + size; x += size * 3) {
      for (const offset of [0, size * 1.5]) {
        const cx = x + offset;
        const cy = y + (offset ? height / 2 : 0);
        ctx.beginPath();
        for (let i = 0; i < 6; i += 1) {
          const angle = (Math.PI / 3) * i;
          const px = cx + size * Math.cos(angle);
          const py = cy + size * Math.sin(angle);
          ctx.strokeStyle = i < 3 ? 'rgb(160, 100, 255)' : 'rgb(96, 150, 255)';
          if (i === 0) ctx.moveTo(px, py);
          else ctx.lineTo(px, py);
        }
        ctx.closePath();
        ctx.stroke();
      }
    }
  }
  return canvas;
}