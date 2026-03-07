const db = require('../config/db');

const ReviewedNotification = {
  async findAllByUser(userId, filters = {}) {
    let sql = 'SELECT * FROM reviewed_notifications WHERE user_id = ?';
    const params = [userId];

    if (filters.year !== undefined) {
      sql += ' AND year = ?';
      params.push(filters.year);
    }

    sql += ' ORDER BY reviewed_at DESC';
    const [rows] = await db.query(sql, params);
    return rows;
  },

  async create(userId, data) {
    const { year, notification_type, month = null, reviewed_at } = data;
    const [result] = await db.query(
      `INSERT INTO reviewed_notifications (user_id, year, notification_type, month, reviewed_at)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, year, notification_type, month || null,
       reviewed_at ? new Date(reviewed_at) : new Date()]
    );
    const [rows] = await db.query(
      'SELECT * FROM reviewed_notifications WHERE id = ?',
      [result.insertId]
    );
    return rows[0];
  },
};

module.exports = ReviewedNotification;
