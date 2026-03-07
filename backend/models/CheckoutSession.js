const db = require('../config/db');

const CheckoutSession = {
  async findAllByUser(userId, filters = {}) {
    let sql = 'SELECT * FROM checkout_sessions WHERE user_id = ?';
    const params = [userId];

    if (filters.plan) {
      sql += ' AND plan = ?';
      params.push(filters.plan);
    }
    if (filters.status) {
      sql += ' AND status = ?';
      params.push(filters.status);
    }

    sql += ' ORDER BY created_at DESC';
    const [rows] = await db.query(sql, params);
    return rows;
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM checkout_sessions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return rows[0] || null;
  },

  async create(userId, data) {
    const {
      plan,
      success_url = null,
      cancel_url = null,
      external_id = null,
      status = 'pending',
    } = data;

    const [result] = await db.query(
      `INSERT INTO checkout_sessions
        (user_id, plan, success_url, cancel_url, external_id, status)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, plan, success_url, cancel_url, external_id, status]
    );
    return this.findById(result.insertId, userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = ['plan', 'success_url', 'cancel_url', 'external_id', 'status'];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE checkout_sessions SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM checkout_sessions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },
};

module.exports = CheckoutSession;
