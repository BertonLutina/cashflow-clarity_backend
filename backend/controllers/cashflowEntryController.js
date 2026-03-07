const CashflowEntry = require('../models/CashflowEntry');

exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.year) filters.year = parseInt(req.query.year);
    const rows = await CashflowEntry.findAllByUser(req.userId, filters, req.query.sort);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch entries' });
  }
};

exports.create = async (req, res) => {
  try {
    const row = await CashflowEntry.upsert(req.userId, req.body);
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create entry' });
  }
};

exports.update = async (req, res) => {
  try {
    const row = await CashflowEntry.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Entry not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update entry' });
  }
};

exports.delete = async (req, res) => {
  try {
    const ok = await CashflowEntry.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Entry not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete entry' });
  }
};
