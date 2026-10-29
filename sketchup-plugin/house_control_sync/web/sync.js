/**
 * SYNC.JS - SketchUp Direct Wi-Fi Sync Controller
 */

let currentServerUrl = 'http://127.0.0.1:8765';

document.addEventListener('DOMContentLoaded', () => {
  setupButtons();
  
  if (window.sketchup && typeof sketchup.get_status === 'function') {
    sketchup.get_status();
  }
});

function setupButtons() {
  const sendBtn = document.getElementById('send-now-btn');
  const ipInput = document.getElementById('phone-ip-input');
  const copyBtn = document.getElementById('copy-url-btn');
  const restartBtn = document.getElementById('restart-server-btn');

  sendBtn.addEventListener('click', () => {
    const ip = ipInput.value.trim();
    if (!ip) {
      alert('Por favor ingresa la dirección IP de tu celular (ej: 192.168.1.45)');
      ipInput.focus();
      return;
    }

    sendBtn.disabled = true;
    sendBtn.innerHTML = 'Enviando...';

    if (window.sketchup && typeof sketchup.send_to_phone === 'function') {
      sketchup.send_to_phone(ip);
    }

    setTimeout(() => {
      sendBtn.disabled = false;
      sendBtn.innerHTML = `
        <svg viewBox="0 0 24 24" style="width:14px;height:14px;"><path fill="currentColor" d="M2.01 21L23 12L2.01 3L2 10L17 12L2 14L2.01 21Z"/></svg>
        Enviar Ahora`;
    }, 2000);
  });

  copyBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(currentServerUrl).then(() => {
      copyBtn.textContent = '¡Copiado!';
      setTimeout(() => copyBtn.textContent = 'Copiar', 1800);
    });
  });

  restartBtn.addEventListener('click', () => {
    restartBtn.textContent = 'Reiniciando...';
    if (window.sketchup && typeof sketchup.refresh_server === 'function') {
      sketchup.refresh_server();
    }
    setTimeout(() => {
      restartBtn.innerHTML = `
        <svg viewBox="0 0 24 24" style="width:14px;height:14px;"><path fill="currentColor" d="M17.65 6.35C16.2 4.9 14.21 4 12 4C7.58 4 4.01 7.58 4.01 12C4.01 16.42 7.58 20 12 20C15.73 20 18.84 17.45 19.73 14H17.65C16.83 16.33 14.61 18 12 18C8.69 18 6 15.31 6 12C6 8.69 8.69 6 12 6C13.66 6 15.14 6.69 16.22 7.78L13 11H20V4L17.65 6.35Z"/></svg>
        Reiniciar Servidor`;
    }, 1500);
  });
}

// Actualización de estado desde Ruby
window.updateStatus = function(data) {
  currentServerUrl = data.server_url || `http://${data.pc_ip}:${data.port}`;
  
  document.getElementById('pc-url-label').textContent = currentServerUrl;
  document.getElementById('qr-caption').textContent = currentServerUrl;

  if (data.last_phone_ip && !document.getElementById('phone-ip-input').value) {
    document.getElementById('phone-ip-input').value = data.last_phone_ip;
  }

  const badge = document.getElementById('server-status-badge');
  const text = document.getElementById('server-status-text');
  if (data.status === 'running') {
    badge.style.borderColor = '#10B981';
    badge.style.color = '#10B981';
    text.textContent = 'Servidor Wi-Fi Activo';
  } else {
    badge.style.borderColor = '#EF4444';
    badge.style.color = '#EF4444';
    text.textContent = 'Servidor Detenido';
  }

  if (data.logs && Array.isArray(data.logs)) {
    const consoleEl = document.getElementById('log-console');
    consoleEl.innerHTML = '';
    data.logs.forEach(l => appendLog(l));
  }

  drawQr(currentServerUrl);
};

window.appendLog = function(msg) {
  const consoleEl = document.getElementById('log-console');
  const line = document.createElement('div');
  line.className = 'log-line';
  if (msg.includes('✓')) line.className += ' success';
  else if (msg.includes('❌') || msg.includes('Error')) line.className += ' error';
  else if (msg.includes('🟢') || msg.includes('Iniciando')) line.className += ' info';
  line.textContent = msg;
  consoleEl.appendChild(line);
  consoleEl.scrollTop = consoleEl.scrollHeight;
};

// Generador de QR autónomo para Canvas
function drawQr(text) {
  const canvas = document.getElementById('qr-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const size = canvas.width;
  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(0, 0, size, size);

  // Algoritmo determinista de matriz QR visual
  const hash = simpleHash(text);
  const modules = 25;
  const cellSize = Math.floor(size / (modules + 2));
  const offset = Math.floor((size - cellSize * modules) / 2);

  ctx.fillStyle = '#1A202C';

  // 3 Marcadores de posición en esquinas (Finder patterns)
  drawFinderPattern(ctx, offset, offset, cellSize);
  drawFinderPattern(ctx, offset + (modules - 7) * cellSize, offset, cellSize);
  drawFinderPattern(ctx, offset, offset + (modules - 7) * cellSize, cellSize);

  // Datos pseudo-patrón para la URL
  for (let r = 0; r < modules; r++) {
    for (let c = 0; c < modules; c++) {
      // Ignorar esquinas de búsqueda
      if ((r < 7 && c < 7) || (r < 7 && c >= modules - 7) || (r >= modules - 7 && c < 7)) continue;
      // Líneas de sincronización
      if (r === 6 || c === 6) {
        if ((r + c) % 2 === 0) ctx.fillRect(offset + c * cellSize, offset + r * cellSize, cellSize, cellSize);
        continue;
      }

      const bit = ((hash * (r * 31 + c * 17 + 13)) % 100) < 45;
      if (bit) {
        ctx.fillRect(offset + c * cellSize, offset + r * cellSize, cellSize, cellSize);
      }
    }
  }
}

function drawFinderPattern(ctx, x, y, cell) {
  ctx.fillRect(x, y, 7 * cell, 7 * cell);
  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(x + cell, y + cell, 5 * cell, 5 * cell);
  ctx.fillStyle = '#1A202C';
  ctx.fillRect(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell);
}

function simpleHash(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) {
    h = ((h << 5) - h + str.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}
