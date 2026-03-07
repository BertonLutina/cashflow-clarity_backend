const CashflowAdjustment = require('../models/CashflowAdjustment');

exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.year) filters.year = parseInt(req.query.year);
    const rows = await CashflowAdjustment.findAllByUser(req.userId, filters, req.query.sort);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch adjustments' });
  }
};

exports.create = async (req, res) => {
  try {
    const row = await CashflowAdjustment.create(req.userId, req.body);
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create adjustment' });
  }
};

exports.update = async (req, res) => {
  try {
    const row = await CashflowAdjustment.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Adjustment not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update adjustment' });
  }
};

exports.delete = async (req, res) => {
  try {
    const ok = await CashflowAdjustment.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Adjustment not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete adjustment' });
  }
};
