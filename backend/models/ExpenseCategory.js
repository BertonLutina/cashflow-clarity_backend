const db = require('../config/db');

const ExpenseCategory = {
  async findAllByUser(userId, filters = {}, sort = null) {
    let sql = 'SELECT * FROM expense_categories WHERE user_id = ?';
    const params = [userId];

    if (filters.is_active !== undefined) {
      sql += ' AND is_active = ?';
      params.push(filters.is_active ? 1 : 0);
    }
    if (filters.flow_type !== undefined) {
      sql += ' AND flow_type = ?';
      params.push(filters.flow_type);
    }

    const colMap = { created_date: 'created_at', created_at: 'created_at', name: 'name', flow_type: 'flow_type', is_active: 'is_active' };
    const dir = sort && sort.startsWith('-') ? 'DESC' : 'ASC';
    const rawCol = sort ? sort.replace(/^-/, '') : 'name';
    const col = colMap[rawCol] || 'name';
    sql += ` ORDER BY ${col} ${dir}`;

    const [rows] = await db.query(sql, params);
    return rows.map(r => ({ ...r, is_active: !!r.is_active }));
  },

  async findById(id, userId) {
    const [rows] = await db.query(
      'SELECT * FROM expense_categories WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    if (!rows[0]) return null;
    return { ...rows[0], is_active: !!rows[0].is_active };
  },

  async create(userId, data) {
    const { name, description = null, is_active = true, flow_type = 'Cash Out', type_name = null } = data;
    const [result] = await db.query(
      `INSERT INTO expense_categories (user_id, name, description, is_active, flow_type, type_name)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, name, description, is_active ? 1 : 0, flow_type, type_name]
    );
    return this.findById(result.insertId, userId);
  },

  async update(id, userId, data) {
    const fields = [];
    const params = [];
    const allowed = ['name', 'description', 'is_active', 'flow_type', 'type_name'];

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = ?`);
        params.push(key === 'is_active' ? (data[key] ? 1 : 0) : data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id, userId);

    params.push(id, userId);
    await db.query(
      `UPDATE expense_categories SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      params
    );
    return this.findById(id, userId);
  },

  async delete(id, userId) {
    const [result] = await db.query(
      'DELETE FROM expense_categories WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    return result.affectedRows > 0;
  },

  async seedDefaults(userId) {
    const defaults = [
      { name: 'Sales', flow_type: 'Cash In', type_name: 'Revenu (Hors Taxe)' },
      { name: 'Consulting', flow_type: 'Cash In', type_name: 'Revenu (Hors Taxe)' },
      { name: 'Revenu', flow_type: 'Cash In', type_name: 'Revenu (Hors Taxe)' },
      { name: 'Administration et bureau', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Charges (électricité, gaz, eau)', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Déplacements et frais', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Dons', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Formation et conférences', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'IT', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Loyer', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Marketing', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Marchandises', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Consommables', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Mobilier et matériel', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Téléphone et Internet', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Autres dépenses', flow_type: 'Cash Out', type_name: 'Dépenses' },
      { name: 'Frais bancaires', flow_type: 'Cash Out', type_name: 'Frais bancaires' },
      { name: 'Cotisations sociales', flow_type: 'Cash Out', type_name: 'Cotisations' },
      { name: 'Investissement', flow_type: 'Adjustment', type_name: 'Investissement' },
      { name: 'Cas de force majeure', flow_type: 'Adjustment', type_name: 'Cas de force majeure' },
      { name: 'Top up RUN', flow_type: 'Adjustment', type_name: 'Dépenses' },
      { name: 'Top up GROW', flow_type: 'Adjustment', type_name: 'Dépenses' },
      { name: 'Décompte TVA', flow_type: 'Adjustment', type_name: 'Dépenses' },
    ];

    for (const cat of defaults) {
      await db.query(
        `INSERT IGNORE INTO expense_categories (user_id, name, description, is_active, flow_type, type_name)
         VALUES (?, ?, NULL, 1, ?, ?)`,
        [userId, cat.name, cat.flow_type, cat.type_name]
      );
    }
  },
};

module.exports = ExpenseCategory;
