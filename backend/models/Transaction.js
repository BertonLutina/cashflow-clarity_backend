const db = require('../config/db');

const Transaction = {
  async findAllByUser(userId, filters = {}, sort = null) {
    let sql = 'SELECT * FROM transactions WHERE user_id = ?';
    const params = [userId];

    if (filters.year !== undefined) {
      sql += ' AND year = ?';
      params.push(filters.year);
    }
    if (filters.month !== undefined) {
      sql += ' AND month = ?';
      params.push(filters.month);
    }
    if (filters.type !== undefined) {
      sql += ' AND type = ?';
      params.push(filters.type);
    }

    const colMap = { month_number: 'month_number', year: 'year', type: 'type', created_date: 'created_at', created_at: 'created_at', amount_excl_vat: 'amount_excl_vat' };
    if (sort) {
      const rawCol = sort.replace(/^-/, '');
      const col = colMap[rawCol];
      if (col) {
        const dir = sort.startsWith('-') ? 'DESC' : 'ASC';
        sql += ` ORDER BY ${col} ${dir}`;
      } else {
        sql += ' ORDER BY month_number ASC, id ASC';
      }
    } else {
      sql += ' ORDER BY month_number ASC, id ASC';
    }

    const [rows] = await db.query(sql, params);
    return rows;
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM transactions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return rows[0] || null;
  },

  async create(userId, data) {
    const {
      month, month_number, year, type, category = null,
      description = null, amount_excl_vat, vat_rate = 0, vat_status = 'not applicable', flow_type = 'Cash Out'
    } = data;

    const [result] = await db.query(
      `INSERT INTO transactions
        (user_id, month, month_number, year, type, category, description, amount_excl_vat, vat_rate, vat_status, flow_type)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [userId, month, month_number, year, type, category, description,
       parseFloat(amount_excl_vat) || 0, parseFloat(vat_rate) || 0, vat_status, flow_type]
    );
    return this.findById(result.insertId, userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = ['month', 'month_number', 'year', 'type', 'category',
                     'description', 'amount_excl_vat', 'vat_rate', 'vat_status', 'flow_type'];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE transactions SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM transactions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },
};

module.exports = Transaction;
