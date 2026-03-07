const db = require('../config/db');
const bcrypt = require('bcryptjs');

const User = {
  async findById(id) {
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [id]);
    return rows[0] || null;
  },

  async findByEmail(email) {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0] || null;
  },

  async create(data) {
    const { email, password, full_name = null } = data;
    const password_hash = await bcrypt.hash(password, 12);
    const [result] = await db.query(
      'INSERT INTO users (email, password_hash, full_name) VALUES (?, ?, ?)',
      [email, password_hash, full_name]
    );
    return this.findById(result.insertId);
  },

  async update(id, data) {
    const fields = [];
    const params = [];
    const allowed = [
      'full_name', 'company_name', 'company_street', 'company_zipcode',
      'company_city', 'company_vat_number', 'company_phone',
      'company_phone_prefix', 'company_currency', 'company_country',
    ];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    }

    if (data.password) {
      fields.push('password_hash = ?');
      params.push(await bcrypt.hash(data.password, 12));
    }

    if (fields.length === 0) return this.findById(id);

    params.push(id);
    await db.query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, params);
    return this.findById(id);
  },

  async verifyPassword(user, password) {
    return bcrypt.compare(password, user.password_hash);
  },

  sanitize(user) {
    if (!user) return null;
    const { password_hash, ...safe } = user;
    return safe;
  },
};

module.exports = User;
