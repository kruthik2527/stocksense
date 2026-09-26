const StockMove = require('../models/StockMove');
const Product = require('../models/Product');

// Helper: find or create a stock entry for a product at a given warehouse, return it
const getStockEntry = (product, warehouseId) => {
  let entry = product.stock.find((s) => s.warehouse.toString() === warehouseId.toString());
  if (!entry) {
    entry = { warehouse: warehouseId, quantity: 0 };
    product.stock.push(entry);
  }
  return product.stock.find((s) => s.warehouse.toString() === warehouseId.toString());
};

// @route POST /api/stock-moves
// Creates a move in 'draft' status. No stock change happens until it's validated.
const createMove = async (req, res) => {
  try {
    const { type, product, quantity, fromWarehouse, toWarehouse, reference, notes } = req.body;

    if (!type || !product || !quantity) {
      return res.status(400).json({ success: false, message: 'type, product and quantity are required' });
    }

    if (type === 'receipt' && !toWarehouse) {
      return res.status(400).json({ success: false, message: 'toWarehouse is required for a receipt' });
    }
    if (type === 'delivery' && !fromWarehouse) {
      return res.status(400).json({ success: false, message: 'fromWarehouse is required for a delivery' });
    }
    if (type === 'transfer' && (!fromWarehouse || !toWarehouse)) {
      return res.status(400).json({ success: false, message: 'fromWarehouse and toWarehouse are required for a transfer' });
    }
    if (type === 'adjustment' && !fromWarehouse) {
      return res.status(400).json({ success: false, message: 'fromWarehouse (location being adjusted) is required' });
    }

    const move = await StockMove.create({
      type,
      product,
      quantity,
      fromWarehouse: fromWarehouse || null,
      toWarehouse: toWarehouse || null,
      reference,
      notes,
      status: 'draft',
      createdBy: req.user.id,
    });

    res.status(201).json({ success: true, move });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route PATCH /api/stock-moves/:id/validate
// Applies the stock change and marks the move 'done'. This is the only place stock actually changes.
const validateMove = async (req, res) => {
  try {
    const move = await StockMove.findById(req.params.id);
    if (!move) return res.status(404).json({ success: false, message: 'Move not found' });
    if (move.status === 'done') {
      return res.status(400).json({ success: false, message: 'Move already validated' });
    }
    if (move.status === 'cancelled') {
      return res.status(400).json({ success: false, message: 'Cannot validate a cancelled move' });
    }

    const product = await Product.findById(move.product);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    switch (move.type) {
      case 'receipt': {
        const entry = getStockEntry(product, move.toWarehouse);
        entry.quantity += move.quantity;
        break;
      }
      case 'delivery': {
        const entry = getStockEntry(product, move.fromWarehouse);
        if (entry.quantity < move.quantity) {
          return res.status(400).json({ success: false, message: 'Insufficient stock for delivery' });
        }
        entry.quantity -= move.quantity;
        break;
      }
      case 'transfer': {
        const fromEntry = getStockEntry(product, move.fromWarehouse);
        if (fromEntry.quantity < move.quantity) {
          return res.status(400).json({ success: false, message: 'Insufficient stock at source warehouse' });
        }
        fromEntry.quantity -= move.quantity;
        const toEntry = getStockEntry(product, move.toWarehouse);
        toEntry.quantity += move.quantity;
        break;
      }
      case 'adjustment': {
        // For adjustments, `quantity` on the move is the DELTA (+/-) already computed at creation time.
        const entry = getStockEntry(product, move.fromWarehouse);
        entry.quantity = Math.max(0, entry.quantity + move.quantity);
        break;
      }
      default:
        return res.status(400).json({ success: false, message: 'Unknown move type' });
    }

    await product.save();
    move.status = 'done';
    await move.save();

    res.json({ success: true, move, product });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route PATCH /api/stock-moves/:id/cancel
const cancelMove = async (req, res) => {
  try {
    const move = await StockMove.findById(req.params.id);
    if (!move) return res.status(404).json({ success: false, message: 'Move not found' });
    if (move.status === 'done') {
      return res.status(400).json({ success: false, message: 'Cannot cancel a move that is already done' });
    }
    move.status = 'cancelled';
    await move.save();
    res.json({ success: true, move });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route GET /api/stock-moves
// Supports ?type=&status=&warehouse=&product=
const getMoves = async (req, res) => {
  try {
    const { type, status, warehouse, product } = req.query;
    const filter = {};

    if (type) filter.type = type;
    if (status) filter.status = status;
    if (product) filter.product = product;
    if (warehouse) {
      filter.$or = [{ fromWarehouse: warehouse }, { toWarehouse: warehouse }];
    }

    const moves = await StockMove.find(filter)
      .populate('product', 'name sku')
      .populate('fromWarehouse', 'name')
      .populate('toWarehouse', 'name')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: moves.length, moves });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { createMove, validateMove, cancelMove, getMoves };
