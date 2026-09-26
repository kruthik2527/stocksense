const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { createMove, validateMove, cancelMove, getMoves } = require('../controllers/stockMoveController');

router.use(protect);

router.post('/', createMove);
router.get('/', getMoves);
router.patch('/:id/validate', validateMove);
router.patch('/:id/cancel', cancelMove);

module.exports = router;
