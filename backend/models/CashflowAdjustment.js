const db = require('../config/db');

const CashflowAdjustment = {
  async findAllByUser(userId, filters = {}, sort = null) {
    let sql = 'SELECT * FROM cashflow_adjustments WHERE user_id = ?';
    const params = [userId];

    if (filters.year !== undefined) {
      sql += ' AND year = ?';
      params.push(filters.year);
    }

    const colMap = { month_number: 'month_number', year: 'year', created_date: 'created_at', created_at: 'created_at' };
    const dir = sort && sort.startsWith('-') ? 'DESC' : 'ASC';
    const rawCol = sort ? sort.replace(/^-/, '') : 'month_number';
    const col = colMap[rawCol] || 'month_number';
    sql += ` ORDER BY ${col} ${dir}`;

    const [rows] = await db.query(sql, params);
    return rows;
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM cashflow_adjustments WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return rows[0] || null;
  },

  async create(userId, data) {
    const { month, month_number, year, adjustment_amount = 0, notes = null } = data;
    const [result] = await db.query(
      `INSERT INTO cashflow_adjustments (user_id, month, month_number, year, adjustment_amount, notes)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE adjustment_amount = VALUES(adjustment_amount), notes = VALUES(notes)`,
      [userId, month, month_number, year, parseFloat(adjustment_amount) || 0, notes]
    );

    if (result.insertId) return this.findById(result.insertId, userId);
    const [rows] = await db.query(
      'SELECT * FROM cashflow_adjustments WHERE user_id = ? AND year = ? AND month_number = ?',
      [userId, year, month_number]
    );
    return rows[0] || null;
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = ['month', 'month_number', 'year', 'adjustment_amount', 'notes'];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE cashflow_adjustments SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM cashflow_adjustments WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },
};

module.exports = CashflowAdjustment;
