require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const warehouseRoutes = require('./routes/warehouseRoutes');
const stockMoveRoutes = require('./routes/stockMoveRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// Temporary request logger — shows every incoming request in the terminal.
// Helps confirm whether requests from the phone are actually reaching this server.
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl} — from ${req.ip}`);
  next();
});

app.get('/', (req, res) => res.send('StockSense API is running'));

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/warehouses', warehouseRoutes);
app.use('/api/stock-moves', stockMoveRoutes);
app.use('/api/dashboard', dashboardRoutes);

// 404 handler
app.use((req, res) => res.status(404).json({ success: false, message: 'Route not found' }));

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`StockSense API running on 0.0.0.0:${PORT}`));