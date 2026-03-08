const TreasuryRules = require('../models/TreasuryRules');
const { broadcastCrud } = require('../wsServer');

exports.list = async (req, res) => {
  try {
    const row = await TreasuryRules.findByUser(req.userId);
    res.json(row ? [row] : []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch treasury rules' });
  }
};

exports.upsert = async (req, res) => {
  try {
    const row = await TreasuryRules.upsert(req.userId, req.body);
    broadcastCrud('treasury-rules', 'update');
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to save treasury rules' });
  }
};

exports.update = async (req, res) => {
  try {
    const existing = await TreasuryRules.findByUser(req.userId);
    if (!existing || existing.id !== parseInt(req.params.id)) {
      return res.status(404).json({ error: 'Treasury rules not found' });
    }
    const row = await TreasuryRules.update(req.params.id, req.userId, req.body);
    broadcastCrud('treasury-rules', 'update');
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update treasury rules' });
  }
};
