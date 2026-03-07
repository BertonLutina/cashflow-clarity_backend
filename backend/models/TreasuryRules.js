const db = require('../config/db');

const TreasuryRules = {
  async findByUser(userId) {
    const [rows] = await db.query(
      'SELECT * FROM treasury_rules WHERE user_id = ?',
      [userId]
    );
    return rows[0] || null;
  },

  async upsert(userId, data) {
    const existing = await this.findByUser(userId);
    if (existing) {
      return this.update(existing.id, userId, data);
    }
    const [result] = await db.query(
      `INSERT INTO treasury_rules (user_id, run_percentage, pay_percentage, grow_percentage, pay_cap, currency)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        userId,
        data.run_percentage !== undefined ? data.run_percentage : 50,
        data.pay_percentage !== undefined ? data.pay_percentage : 20,
        data.grow_percentage !== undefined ? data.grow_percentage : 30,
        data.pay_cap !== undefined ? data.pay_cap : null,
        data.currency || 'EUR',
      ]
    );
    return this.findByUser(userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = ['run_percentage', 'pay_percentage', 'grow_percentage', 'pay_cap', 'currency'];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findByUser(userId);

    params.push(id, userId);
    await db.query(
      `UPDATE treasury_rules SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findByUser(userId);
  },
};

module.exports = TreasuryRules;
