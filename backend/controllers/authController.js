const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ExpenseCategory = require('../models/ExpenseCategory');
const TreasuryRules = require('../models/TreasuryRules');
const TreasurySettings = require('../models/TreasurySettings');

function signToken(userId, options = {}) {
  const payload = { userId };
  if (options.impersonatedBy != null) {
    payload.impersonatedBy = options.impersonatedBy;
  }
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}

exports.register = async (req, res) => {
  try {
    const { email, password, full_name } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existing = await User.findByEmail(email);
    if (existing) {
      return res.status(409).json({ error: 'Email already in use' });
    }

    const user = await User.create({ email, password, full_name });

    // Seed default categories (the trigger creates treasury_rules & treasury_settings)
    await ExpenseCategory.seedDefaults(user.id);

    const token = signToken(user.id);
    res.status(201).json({ token, user: User.sanitize(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Registration failed' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findByEmail(email);
    if (!user || !(await User.verifyPassword(user, password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = signToken(user.id);
    res.json({ token, user: User.sanitize(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(User.sanitize(user));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
};

exports.updateMe = async (req, res) => {
  try {
    const user = await User.update(req.userId, req.body);
    res.json(User.sanitize(user));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

exports.logout = (req, res) => {
  res.json({ message: 'Logged out' });
};

/**
 * GET /auth/users
 * Admin only. Query: ?page=1&limit=20
 */
exports.getUsers = async (req, res) => {
  try {
    const pagination = { page: req.query.page, limit: req.query.limit };
    const result = await User.getAll(pagination);
    res.json({
      users: result.rows.map((u) => User.sanitize(u)),
      total: result.total,
      page: result.page,
      limit: result.limit,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

/**
 * GET /auth/users/search
 * Admin only. Query: ?q=...&page=1&limit=20
 */
exports.getUsersSearchByName = async (req, res) => {
  try {
    const search = req.query.q;
    const pagination = { page: req.query.page, limit: req.query.limit };
    const result = await User.getUsersSearchByName(search, pagination);
    res.json({
      users: result.rows.map((u) => User.sanitize(u)),
      total: result.total,
      page: result.page,
      limit: result.limit,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to search users' });
  }
};

/**
 * POST /auth/impersonate
 * Admin only. Body: { user_id: number }.
 * Returns { token, user } for the target user (JWT encodes impersonatedBy for restore).
 */
exports.impersonate = async (req, res) => {
  try {
    const targetUserId = req.body.user_id != null ? parseInt(req.body.user_id, 10) : null;
    if (!targetUserId || !Number.isInteger(targetUserId)) {
      return res.status(400).json({ error: 'user_id (number) is required' });
    }

    const targetUser = await User.findById(targetUserId);
    if (!targetUser) return res.status(404).json({ error: 'User not found' });

    const token = signToken(targetUserId, { impersonatedBy: req.userId });
    res.json({ token, user: User.sanitize(targetUser) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Impersonation failed' });
  }
};

/**
 * POST /auth/impersonate/stop
 * Only valid when current token is an impersonation session (has impersonatedBy).
 * Returns { token, user } for the original admin.
 */
exports.stopImpersonate = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    const token = authHeader.slice(7);
    let payload;
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET);
    } catch {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }

    const adminId = payload.impersonatedBy;
    if (adminId == null) {
      return res.status(400).json({ error: 'Not in impersonation session' });
    }

    const adminUser = await User.findById(adminId);
    if (!adminUser) return res.status(404).json({ error: 'Original admin not found' });

    const newToken = signToken(adminId);
    res.json({ token: newToken, user: User.sanitize(adminUser) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Stop impersonation failed' });
  }
};
