const router = require('express').Router();
const ctrl = require('../controllers/subscriptionController');
const auth = require('../middleware/auth');

// GET /api/subscription - current user's subscription (used by Layout / getSubscription())
router.get('/', auth, ctrl.getCurrent);

module.exports = router;
