const mongoose = require('mongoose');

const stockEntrySchema = new mongoose.Schema(
  {
    warehouse: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse', required: true },
    quantity: { type: Number, default: 0 },
  },
  { _id: false }
);

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    sku: { type: String, required: true, unique: true, uppercase: true, trim: true },
    category: { type: String, trim: true },
    unitOfMeasure: { type: String, default: 'pcs' },
    reorderLevel: { type: Number, default: 10 },
    stock: [stockEntrySchema],
  },
  { timestamps: true }
);

// Virtual: total stock across all warehouses
productSchema.virtual('totalStock').get(function () {
  return this.stock.reduce((sum, s) => sum + s.quantity, 0);
});

productSchema.set('toJSON', { virtuals: true });
productSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Product', productSchema);
