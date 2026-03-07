const router = require('express').Router();
const ctrl = require('../controllers/transactionController');
const auth = require('../middleware/auth');

router.use(auth);
router.get('/', ctrl.list);
router.post('/', ctrl.create);
router.post('/bulk', ctrl.bulkCreate);
router.put('/:id', ctrl.update);
router.delete('/:id', ctrl.delete);

module.exports = router;
