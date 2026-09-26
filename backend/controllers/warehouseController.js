const Warehouse = require('../models/Warehouse');

const createWarehouse = async (req, res) => {
  try {
    const { name, location } = req.body;
    const warehouse = await Warehouse.create({ name, location });
    res.status(201).json({ success: true, warehouse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const getWarehouses = async (req, res) => {
  try {
    const warehouses = await Warehouse.find({ isActive: true });
    res.json({ success: true, count: warehouses.length, warehouses });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const updateWarehouse = async (req, res) => {
  try {
    const warehouse = await Warehouse.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!warehouse) return res.status(404).json({ success: false, message: 'Warehouse not found' });
    res.json({ success: true, warehouse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const deleteWarehouse = async (req, res) => {
  try {
    const warehouse = await Warehouse.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true });
    if (!warehouse) return res.status(404).json({ success: false, message: 'Warehouse not found' });
    res.json({ success: true, message: 'Warehouse deactivated' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { createWarehouse, getWarehouses, updateWarehouse, deleteWarehouse };
