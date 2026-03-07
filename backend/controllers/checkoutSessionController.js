const CheckoutSession = require('../models/CheckoutSession');

/** GET /api/checkout-sessions - list sessions for current user */
exports.list = async (req, res) => {
  try {
    const filters = {};
    if (req.query.plan) filters.plan = req.query.plan;
    if (req.query.status) filters.status = req.query.status;
    const rows = await CheckoutSession.findAllByUser(req.userId, filters);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch checkout sessions' });
  }
};

/** GET /api/checkout-sessions/:id */
exports.getById = async (req, res) => {
  try {
    const row = await CheckoutSession.findById(req.params.id, req.userId);
    if (!row) return res.status(404).json({ error: 'Checkout session not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch checkout session' });
  }
};

/** POST /api/checkout-sessions - create session */
exports.create = async (req, res) => {
  try {
    const row = await CheckoutSession.create(req.userId, req.body);
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create checkout session' });
  }
};

/** PUT /api/checkout-sessions/:id */
exports.update = async (req, res) => {
  try {
    const row = await CheckoutSession.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Checkout session not found' });
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update checkout session' });
  }
};

/** DELETE /api/checkout-sessions/:id */
exports.delete = async (req, res) => {
  try {
    const ok = await CheckoutSession.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Checkout session not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete checkout session' });
  }
};
