const db = require('../config/db');

const TreasurySettings = {
  async findByUser(userId) {
    const [rows] = await db.query(
      'SELECT * FROM treasury_settings WHERE user_id = ?',
      [userId]
    );
    if (!rows[0]) return null;
    const row = rows[0];
    return { ...row, vat_exemption_scheme: !!row.vat_exemption_scheme, invest_enabled: !!row.invest_enabled };
  },

  async upsert(userId, data) {
    const existing = await this.findByUser(userId);
    if (existing) {
      return this.update(existing.id, userId, data);
    }
    await db.query(
      `INSERT INTO treasury_settings
         (user_id, vat_exemption_scheme, run_percentage, pay_percentage,
          pay_cap, grow_percentage, invest_enabled, invest_min_months_positive, currency)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        data.vat_exemption_scheme ? 1 : 0,
        data.run_percentage !== undefined ? data.run_percentage : 50,
        data.pay_percentage !== undefined ? data.pay_percentage : 20,
        data.pay_cap !== undefined ? data.pay_cap : 0,
        data.grow_percentage !== undefined ? data.grow_percentage : 30,
        data.invest_enabled !== undefined ? (data.invest_enabled ? 1 : 0) : 1,
        data.invest_min_months_positive || 3,
        data.currency || 'EUR',
      ]
    );
    return this.findByUser(userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = [
      'vat_exemption_scheme', 'run_percentage', 'pay_percentage',
      'pay_cap', 'grow_percentage', 'invest_enabled',
      'invest_min_months_positive', 'currency',
    ];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        const val = (key === 'vat_exemption_scheme' || key === 'invest_enabled')
          ? (data[key] ? 1 : 0)
          : data[key];
        params.push(val);
      }
    }

    if (fields.length === 0) return this.findByUser(userId);

    params.push(id, userId);
    await db.query(
      `UPDATE treasury_settings SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findByUser(userId);
  },
};

module.exports = TreasurySettings;
