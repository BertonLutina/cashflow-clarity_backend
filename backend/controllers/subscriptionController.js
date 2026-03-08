const Subscription = require('../models/Subscription');
const User = require('../models/User');
const { broadcastCrud } = require('../wsServer');

/** GET /api/subscription - current user's subscription (single endpoint used by Layout/frontend) */
exports.getCurrent = async (req, res) => {
  try {
    const sub = await Subscription.findByUser(req.userId);
    if (!sub) return res.json({ subscription: null });

    // Compute status from dates (grace_period / blocked) like Stripe flow
    let status = sub.status;
    if (status !== 'cancelled') {
      const now = new Date();
      const periodEnd = sub.current_period_end ? new Date(sub.current_period_end) : null;
      const gracePeriodEnd = sub.grace_period_end ? new Date(sub.grace_period_end) : null;

      if (periodEnd && now > periodEnd) {
        if (gracePeriodEnd && now > gracePeriodEnd) {
          status = 'blocked';
        } else {
          status = 'grace_period';
        }
      }
    }

    res.json({ subscription: { ...sub, status } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch subscription' });
  }
};

/** GET /api/subscriptions - list (at most one per user) */
exports.list = async (req, res) => {
  try {
    const sub = await Subscription.findByUser(req.userId);
    res.json(sub ? [sub] : []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch subscriptions' });
  }
};

/** POST /api/subscriptions - create subscription for current user */
exports.create = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(401).json({ error: 'User not found' });
    const existing = await Subscription.findByUser(req.userId);
    if (existing) {
      return res.status(409).json({ error: 'User already has a subscription. Use PUT to update.' });
    }
    const data = {
      ...req.body,
      user_email: req.body.user_email || user.email,
    };
    const row = await Subscription.create(req.userId, data);
    broadcastCrud('subscription', 'create');
    res.status(201).json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create subscription' });
  }
};

/** PUT /api/subscriptions/:id */
exports.update = async (req, res) => {
  try {
    const row = await Subscription.update(req.params.id, req.userId, req.body);
    if (!row) return res.status(404).json({ error: 'Subscription not found' });
    broadcastCrud('subscription', 'update');
    res.json(row);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update subscription' });
  }
};

/** DELETE /api/subscriptions/:id */
exports.delete = async (req, res) => {
  try {
    const ok = await Subscription.delete(req.params.id, req.userId);
    if (!ok) return res.status(404).json({ error: 'Subscription not found' });
    broadcastCrud('subscription', 'delete');
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete subscription' });
  }
};
