const ExpenseCategory = require('../models/ExpenseCategory');

exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.is_active !== undefined) filters.is_active = req.query.is_active === 'true';
    if (req.query.flow_type) filters.flow_type = req.query.flow_type;
    const rows = await ExpenseCategory.findAllByUser(req.userId, filters, req.query.sort);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
};

exports.create = async (req, res) => {
  try {
    const row = await ExpenseCategory.create(req.userId, req.body);
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create category' });
  }
};

exports.update = async (req, res) => {
  try {
    const row = await ExpenseCategory.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Category not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update category' });
  }
};

exports.delete = async (req, res) => {
  try {
    const ok = await ExpenseCategory.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Category not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete category' });
  }
};
