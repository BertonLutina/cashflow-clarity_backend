const { WebSocketServer } = require('ws');
const jwt = require('jsonwebtoken');
const url = require('url');

const PING_INTERVAL_MS = 30000;

let wss = null;
const clients = new Set();

/**
 * Validate JWT from query string (?token=...) using same secret as REST auth.
 * @returns { { userId: number } | null } payload or null if invalid
 */
function validateToken(token) {
  if (!token || typeof token !== 'string') return null;
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    return payload.userId != null ? { userId: payload.userId } : null;
  } catch {
    return null;
  }
}

/**
 * Send a CRUD notification to all connected authenticated clients.
 * Call this after any successful create/update/delete on the listed resources.
 * @param {string} entity - One of: transactions, cashflow-entries, cashflow-adjustments, treasury-settings, treasury-rules, expense-categories, reviewed-notifications, subscription
 * @param {'create'|'update'|'delete'} action
 */
function broadcastCrud(entity, action) {
  const message = JSON.stringify({ type: 'crud', entity, action });
  let sent = 0;
  for (const client of clients) {
    if (client.readyState === 1) {
      try {
        client.send(message);
        sent++;
      } catch (err) {
        console.error('WebSocket send error:', err.message);
      }
    }
  }
  if (sent > 0) {
    console.log(`WS broadcast: ${entity} ${action} -> ${sent} client(s)`);
  }
}

/**
 * Attach WebSocket server to the same HTTP server as Express.
 * Handles upgrade only for path /ws; validates JWT from query ?token=<jwt>.
 * @param {import('http').Server} httpServer
 */
function attachToServer(httpServer) {
  wss = new WebSocketServer({ noServer: true });

  httpServer.on('upgrade', (request, socket, head) => {
    const pathname = url.parse(request.url, true).pathname;
    if (pathname !== '/ws') {
      socket.destroy();
      return;
    }

    const { query } = url.parse(request.url, true);
    const token = query.token;
    const payload = validateToken(token);
    if (!payload) {
      console.warn('WebSocket connection rejected: missing or invalid token');
      socket.write(`HTTP/1.1 401 Unauthorized\r\nConnection: close\r\n\r\n`);
      socket.destroy();
      return;
    }

    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit('connection', ws, request, payload);
    });
  });

  wss.on('connection', (ws, request, payload) => {
    ws.userId = payload.userId;
    clients.add(ws);

    ws.on('close', () => {
      clients.delete(ws);
    });

    ws.on('error', (err) => {
      console.error('WebSocket client error:', err.message);
      clients.delete(ws);
    });

    // Optional: heartbeat to detect dead connections
    ws.isAlive = true;
    ws.on('pong', () => {
      ws.isAlive = true;
    });
  });

  const pingInterval = setInterval(() => {
    for (const client of clients) {
      if (client.isAlive === false) {
        clients.delete(client);
        client.terminate();
        continue;
      }
      client.isAlive = false;
      client.ping();
    }
  }, PING_INTERVAL_MS);

  wss.on('close', () => {
    clearInterval(pingInterval);
  });

  console.log('WebSocket server attached at path /ws');
}

module.exports = {
  attachToServer,
  broadcastCrud,
};
