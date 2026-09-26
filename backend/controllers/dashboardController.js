const Product = require('../models/Product');
const StockMove = require('../models/StockMove');

// @route GET /api/dashboard
const getDashboard = async (req, res) => {
  try {
    const products = await Product.find();
    const totalProducts = products.length;
    const lowStockItems = products.filter((p) => p.totalStock > 0 && p.totalStock <= p.reorderLevel).length;
    const outOfStockItems = products.filter((p) => p.totalStock === 0).length;

    const pendingReceipts = await StockMove.countDocuments({
      type: 'receipt',
      status: { $in: ['draft', 'waiting', 'ready'] },
    });
    const pendingDeliveries = await StockMove.countDocuments({
      type: 'delivery',
      status: { $in: ['draft', 'waiting', 'ready'] },
    });
    const scheduledTransfers = await StockMove.countDocuments({
      type: 'transfer',
      status: { $in: ['draft', 'waiting', 'ready'] },
    });

    res.json({
      success: true,
      kpis: {
        totalProducts,
        lowStockItems,
        outOfStockItems,
        pendingReceipts,
        pendingDeliveries,
        scheduledTransfers,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getDashboard };
