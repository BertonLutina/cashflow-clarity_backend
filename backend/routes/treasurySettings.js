const router = require('express').Router();
const ctrl = require('../controllers/treasurySettingsController');
const auth = require('../middleware/auth');

router.use(auth);
router.get('/', ctrl.list);
router.post('/', ctrl.upsert);
router.put('/:id', ctrl.update);

module.exports = router;
