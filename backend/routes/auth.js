const router = require('express').Router();
const ctrl = require('../controllers/authController');
const auth = require('../middleware/auth');
const requireAdmin = require('../middleware/requireAdmin');

router.post('/register', ctrl.register);
router.post('/login', ctrl.login);
router.get('/me', auth, ctrl.me);
router.put('/me', auth, ctrl.updateMe);
router.post('/logout', auth, ctrl.logout);
router.get('/users', auth, requireAdmin, ctrl.getUsers);
router.get('/users/search', auth, requireAdmin, ctrl.getUsersSearchByName);
router.post('/impersonate', auth, requireAdmin, ctrl.impersonate);
router.post('/impersonate/stop', auth, ctrl.stopImpersonate);

module.exports = router;
