const TreasurySettings = require('../models/TreasurySettings');
const { broadcastCrud } = require('../wsServer');

exports.list = async (req, res) => {
  try {
    const row = await TreasurySettings.findByUser(req.userId);
    res.json(row ? [row] : []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch treasury settings' });
  }
};

exports.upsert = async (req, res) => {
  try {
    const row = await TreasurySettings.upsert(req.userId, req.body);
    broadcastCrud('treasury-settings', 'update');
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to save treasury settings' });
  }
};

exports.update = async (req, res) => {
  try {
    const existing = await TreasurySettings.findByUser(req.userId);
    if (!existing || existing.id !== parseInt(req.params.id)) {
      return res.status(404).json({ error: 'Treasury settings not found' });
    }
    const row = await TreasurySettings.update(req.params.id, req.userId, req.body);
    broadcastCrud('treasury-settings', 'update');
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update treasury settings' });
  }
};
