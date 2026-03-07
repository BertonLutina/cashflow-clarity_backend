const router = require('express').Router();
const ctrl = require('../controllers/reviewedNotificationController');
const auth = require('../middleware/auth');

router.use(auth);
router.get('/', ctrl.list);
router.post('/', ctrl.create);

module.exports = router;
