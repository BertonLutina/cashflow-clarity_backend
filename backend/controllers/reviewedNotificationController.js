const ReviewedNotification = require('../models/ReviewedNotification');
const { broadcastCrud } = require('../wsServer');

exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.year) filters.year = parseInt(req.query.year);
    const rows = await ReviewedNotification.findAllByUser(req.userId, filters);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
};

exports.create = async (req, res) => {
  try {
    const row = await ReviewedNotification.create(req.userId, req.body);
    broadcastCrud('reviewed-notifications', 'create');
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create notification' });
  }
};
