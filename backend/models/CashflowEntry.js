const db = require('../config/db');

const CashflowEntry = {
  async findAllByUser(userId, filters = {}, sort = null) {
    let sql = 'SELECT * FROM cashflow_entries WHERE user_id = ?';
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
    return rows.map(r => ({
      ...r,
      expense_categories: r.expense_categories
        ? (typeof r.expense_categories === 'string' ? JSON.parse(r.expense_categories) : r.expense_categories)
        : []
    }));
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM cashflow_entries WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    if (!rows[0]) return null;
    const r = rows[0];
    return {
      ...r,
      expense_categories: r.expense_categories
        ? (typeof r.expense_categories === 'string' ? JSON.parse(r.expense_categories) : r.expense_categories)
        : []
    };
  },

  async upsert(userId, data) {
    const { month, month_number, year, cash_in = 0, cash_out = 0, expense_categories = [], notes = null } = data;
    const [result] = await db.query(
      `INSERT INTO cashflow_entries (user_id, month, month_number, year, cash_in, cash_out, expense_categories, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         cash_in = VALUES(cash_in),
         cash_out = VALUES(cash_out),
         expense_categories = VALUES(expense_categories),
         notes = VALUES(notes)`,
      [userId, month, month_number, year,
       parseFloat(cash_in) || 0,
       parseFloat(cash_out) || 0,
       JSON.stringify(expense_categories),
       notes]
    );

    if (result.insertId) return this.findById(result.insertId, userId);
    const [rows] = await db.query(
      'SELECT * FROM cashflow_entries WHERE user_id = ? AND year = ? AND month_number = ?',
      [userId, year, month_number]
    );
    return rows[0] || null;
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];

    if (data.month !== undefined) { fields.push('month = ?'); params.push(data.month); }
    if (data.month_number !== undefined) { fields.push('month_number = ?'); params.push(data.month_number); }
    if (data.year !== undefined) { fields.push('year = ?'); params.push(data.year); }
    if (data.cash_in !== undefined) { fields.push('cash_in = ?'); params.push(parseFloat(data.cash_in) || 0); }
    if (data.cash_out !== undefined) { fields.push('cash_out = ?'); params.push(parseFloat(data.cash_out) || 0); }
    if (data.expense_categories !== undefined) { fields.push('expense_categories = ?'); params.push(JSON.stringify(data.expense_categories)); }
    if (data.notes !== undefined) { fields.push('notes = ?'); params.push(data.notes); }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE cashflow_entries SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM cashflow_entries WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },
};

module.exports = CashflowEntry;
