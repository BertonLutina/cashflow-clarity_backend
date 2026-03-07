const mysql2 = require('mysql2/promise');
const fs = require('fs');

const XAMPP_SOCKET = '/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock';
const socketPath = process.env.DB_SOCKET
  || (fs.existsSync(XAMPP_SOCKET) ? XAMPP_SOCKET : undefined);

const config = {
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'cashflow_clarity',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
};

if (socketPath) {
  config.socketPath = socketPath;
} else {
  config.host = process.env.DB_HOST || 'localhost';
  config.port = parseInt(process.env.DB_PORT || '3306');
}

const pool = mysql2.createPool(config);

pool.getConnection()
  .then(conn => {
    conn.release();
    console.log(`DB connected via ${socketPath ? 'socket: ' + socketPath : config.host + ':' + config.port}`);
  })
  .catch(err => {
    console.error('DB connection failed:', err.message);
  });

module.exports = pool;
