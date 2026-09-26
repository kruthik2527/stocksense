const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/auth');
const {
  createWarehouse,
  getWarehouses,
  updateWarehouse,
  deleteWarehouse,
} = require('../controllers/warehouseController');

router.use(protect);

router.post('/', authorize('inventory_manager'), createWarehouse);
router.get('/', getWarehouses);
router.put('/:id', authorize('inventory_manager'), updateWarehouse);
router.delete('/:id', authorize('inventory_manager'), deleteWarehouse);

module.exports = router;
