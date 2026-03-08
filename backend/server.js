require('dotenv').config();
const http = require('http');
const app = require('./app');
const wsServer = require('./wsServer');

const PORT = parseInt(process.env.PORT || '4000');
const server = http.createServer(app);

wsServer.attachToServer(server);

server.listen(PORT, () => {
  console.log(`Cashflow Clarity API running on http://localhost:${PORT}`);
  console.log(`WebSocket endpoint: ws://localhost:${PORT}/ws (use ?token=<jwt>)`);
});
