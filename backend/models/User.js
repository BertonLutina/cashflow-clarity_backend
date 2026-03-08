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

  async getAll(pagination = {}) {
    const page = Math.max(1, parseInt(pagination.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(pagination.limit, 10) || 20));
    const offset = (page - 1) * limit;

    const [[{ total }]] = await db.query(
      'SELECT COUNT(*) AS total FROM users'
    );
    const [rows] = await db.query(
      'SELECT * FROM users ORDER BY full_name, email LIMIT ? OFFSET ?',
      [limit, offset]
    );
    return { rows, total, page, limit };
  },

  async getUsersSearchByName(search, pagination = {}) {
    if (!search || typeof search !== 'string') {
      return { rows: [], total: 0, page: 1, limit: pagination.limit || 20 };
    }
    const pattern = `%${search.trim()}%`;
    const page = Math.max(1, parseInt(pagination.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(pagination.limit, 10) || 20));
    const offset = (page - 1) * limit;

    const [[{ total }]] = await db.query(
      `SELECT COUNT(*) AS total FROM users
       WHERE full_name LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR company_name LIKE ? OR email LIKE ?`,
      [pattern, pattern, pattern, pattern, pattern]
    );
    const [rows] = await db.query(
      `SELECT * FROM users
       WHERE full_name LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR company_name LIKE ? OR email LIKE ?
       ORDER BY full_name, email
       LIMIT ? OFFSET ?`,
      [pattern, pattern, pattern, pattern, pattern, limit, offset]
    );
    return { rows, total, page, limit };
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
