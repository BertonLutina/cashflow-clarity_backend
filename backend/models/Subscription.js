const db = require('../config/db');

const Subscription = {
  async findByUser(userId) {
    const [rows] = await db.query(
      'SELECT * FROM subscriptions WHERE user_id = ?',
      [userId]
    );
    return rows[0] || null;
  },

  async findByExternalId(externalId) {
    const [rows] = await db.query(
      'SELECT * FROM subscriptions WHERE external_id = ?',
      [externalId]
    );
    return rows[0] || null;
  },

  async upsertByUser(userId, data) {
    const existing = await this.findByUser(userId);
    const payload = {
      user_email: data.user_email,
      plan: data.plan,
      status: data.status ?? 'active',
      current_period_end: data.current_period_end ?? null,
      grace_period_end: data.grace_period_end ?? null,
      external_id: data.external_id ?? null,
    };
    if (existing) {
      await this.update(existing.id, userId, payload);
      return this.findById(existing.id, userId);
    }
    return this.create(userId, payload);
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM subscriptions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return rows[0] || null;
  },

  async create(userId, data) {
    const {
      user_email,
      plan,
      status = 'active',
      current_period_end = null,
      grace_period_end = null,
      external_id = null,
    } = data;

    const [result] = await db.query(
      `INSERT INTO subscriptions
        (user_id, user_email, plan, status, current_period_end, grace_period_end, external_id)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, user_email, plan, status, current_period_end, grace_period_end, external_id]
    );
    return this.findById(result.insertId, userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = [
      'user_email', 'plan', 'status', 'current_period_end', 'grace_period_end', 'external_id',
    ];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE subscriptions SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM subscriptions WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },

  async updateByExternalId(externalId, data) {
    const sub = await this.findByExternalId(externalId);
    if (!sub) return null;
    const fields = [];
    const params = [];
    const allowed = ['plan', 'status', 'current_period_end', 'grace_period_end'];
    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }
    if (fields.length === 0) return sub;
    params.push(externalId);
    await db.query(
      `UPDATE subscriptions SET ${fields.join(', ')} WHERE external_id = ?`,
      params
    );
    return this.findByExternalId(externalId);
  },
};

module.exports = Subscription;
