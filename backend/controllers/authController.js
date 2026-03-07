const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ExpenseCategory = require('../models/ExpenseCategory');
const TreasuryRules = require('../models/TreasuryRules');
const TreasurySettings = require('../models/TreasurySettings');

function signToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
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
