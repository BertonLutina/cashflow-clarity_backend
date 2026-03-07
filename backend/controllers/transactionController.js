const Transaction = require('../models/Transaction');

exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.year) filters.year = parseInt(req.query.year);
    if (req.query.month) filters.month = req.query.month;
    if (req.query.type) filters.type = req.query.type;
    const rows = await Transaction.findAllByUser(req.userId, filters, req.query.sort);
    const keysToConvert = ["amount_excl_vat", "vat_rate", "vat_amount", "amount_incl_vat"];

// Convert strings to numbers (decimals)
    const rijen = rows.map((row) => {
      keysToConvert.forEach((key) => {
        if (row[key] !== undefined) {
          row[key] = parseFloat(row[key]);
        }
      });
      return row;
    });

    console.log("rows => ",rijen)

    res.json(rijen);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
};

exports.create = async (req, res) => {
  try {
    const row = await Transaction.create(req.userId, req.body);
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create transaction' });
  }
};

exports.update = async (req, res) => {
  try {
    const row = await Transaction.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Transaction not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update transaction' });
  }
};

exports.delete = async (req, res) => {
  try {
    const ok = await Transaction.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Transaction not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete transaction' });
  }
};

exports.bulkCreate = async (req, res) => {
  try {
    const items = Array.isArray(req.body) ? req.body : [];
    const results = [];
    for (const item of items) {
      const row = await Transaction.create(req.userId, item);
      results.push(row);
    }
    res.status(201).json(results);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to bulk create transactions' });
  }
};
