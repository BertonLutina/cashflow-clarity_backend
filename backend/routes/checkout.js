const router = require('express').Router();
const auth = require('../middleware/auth');
const checkoutController = require('../controllers/checkoutController');

// POST /api/checkout - create Stripe Checkout Session (used by Subscribe/Landing)
router.post('/', auth, checkoutController.createSession);

module.exports = router;
