const mongoose = require('mongoose');

const stockMoveSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ['receipt', 'delivery', 'transfer', 'adjustment'],
      required: true,
    },
    product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    quantity: { type: Number, required: true },
    fromWarehouse: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse', default: null },
    toWarehouse: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse', default: null },
    status: {
      type: String,
      enum: ['draft', 'waiting', 'ready', 'done', 'cancelled'],
      default: 'draft',
    },
    reference: { type: String, trim: true }, // e.g. supplier name, sales order id
    notes: { type: String, trim: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('StockMove', stockMoveSchema);
