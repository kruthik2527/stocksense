const Product = require('../models/Product');

// @route POST /api/products
const createProduct = async (req, res) => {
  try {
    const { name, sku, category, unitOfMeasure, reorderLevel, initialStock, warehouse } = req.body;

    const existing = await Product.findOne({ sku: sku.toUpperCase() });
    if (existing) {
      return res.status(400).json({ success: false, message: 'SKU already exists' });
    }

    const stock = [];
    if (initialStock && warehouse) {
      stock.push({ warehouse, quantity: initialStock });
    }

    const product = await Product.create({
      name,
      sku,
      category,
      unitOfMeasure,
      reorderLevel,
      stock,
    });

    res.status(201).json({ success: true, product });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route GET /api/products
// Supports ?category=&search=&lowStock=true
const getProducts = async (req, res) => {
  try {
    const { category, search, lowStock } = req.query;
    const filter = {};

    if (category) filter.category = category;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { sku: { $regex: search, $options: 'i' } },
      ];
    }

    let products = await Product.find(filter).populate('stock.warehouse', 'name location');

    if (lowStock === 'true') {
      products = products.filter((p) => p.totalStock <= p.reorderLevel);
    }

    res.json({ success: true, count: products.length, products });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route GET /api/products/:id
const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('stock.warehouse', 'name location');
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    res.json({ success: true, product });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route PUT /api/products/:id
const updateProduct = async (req, res) => {
  try {
    const { name, category, unitOfMeasure, reorderLevel } = req.body;

    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    if (name) product.name = name;
    if (category) product.category = category;
    if (unitOfMeasure) product.unitOfMeasure = unitOfMeasure;
    if (reorderLevel !== undefined) product.reorderLevel = reorderLevel;

    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// @route DELETE /api/products/:id
const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    res.json({ success: true, message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { createProduct, getProducts, getProductById, updateProduct, deleteProduct };
