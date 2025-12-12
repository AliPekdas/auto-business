const express = require('express');
const cors = require('cors');
const path = require('path');
// Import db.js file
const { poolPromise, sql } = require('./db'); 

const app = express();

// --- Middleware ---
app.use(express.json()); 
app.use(cors());        

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));


// ==========================================
// PART 1: CORE BUSINESS LOGIC ROUTES
// ==========================================

/* 1. PROCESS SALE (POST) */
app.post('/api/sale', async (req, res) => {
    try {
        const { customerId, productId, quantity } = req.body;
        const pool = await poolPromise;
        const request = pool.request();

        // Capture SQL PRINT messages (Errors or Info)
        let sqlMessages = '';
        request.on('info', (info) => { sqlMessages += info.message; });

        request.input('CustomerID', sql.Int, customerId);
        request.input('ProductID', sql.Int, productId);
        request.input('Quantity', sql.Int, quantity);

        await request.execute('sp_SaleTransaction');

        // Check for specific Turkish error messages from Triggers
        if (sqlMessages.includes('Hata') || sqlMessages.includes('Yetersiz Stok')) {
            throw new Error(sqlMessages);
        }

        res.json({ success: true, message: 'Satış işlemi başarıyla tamamlandı.' });

    } catch (err) {
        if (err.message.includes('Yetersiz Stok')) {
            res.status(400).json({ success: false, error: 'HATA: Yetersiz Stok! Satış işlemi gerçekleştirilemedi. Stok miktarını kontrol ediniz.' });
        } else {
            res.status(500).json({ success: false, error: err.message });
        }
    }
});

/* 2. GET CUSTOMER VEHICLES (GET) */
app.get('/api/garage', async (req, res) => {
    try {
        const { customerName } = req.query; 
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CustomerName', sql.NVarChar(100), customerName)
            .execute('sp_GetCustomerGarage');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

/* 3. FINANCIAL REPORT (GET) */
app.get('/api/revenue', async (req, res) => {
    try {
        const { startDate, endDate } = req.query;
        const pool = await poolPromise;
        const result = await pool.request()
            .input('StartDate', sql.DateTime, startDate)
            .input('EndDate', sql.DateTime, endDate)
            .execute('sp_GetTotalRevenue');
        
        const total = result.recordset[0]?.TotalRevenue || 0;
        res.json({ totalRevenue: total });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

/* 4. MANUAL RESTOCK (POST) */
app.post('/api/restock', async (req, res) => {
    try {
        const { productId, quantity } = req.body;
        const pool = await poolPromise;
        const request = pool.request();

        // Capture "Stok güncellendi" message
        let sqlMessages = '';
        request.on('info', (info) => { sqlMessages += info.message; });

        request.input('ProductID', sql.Int, productId);
        request.input('AddedQuantity', sql.Int, quantity);

        await request.execute('sp_ManualRestock');

        res.json({ success: true, message: sqlMessages || 'Stok güncellendi.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

/* 5. UPDATE PRODUCT PRICE (POST) */
app.post('/api/update-price', async (req, res) => {
    try {
        const { productId, percentage, isIncrease } = req.body;
        const pool = await poolPromise;
        
        await pool.request()
            .input('ProductID', sql.Int, productId)
            .input('Percentage', sql.Decimal(5, 2), percentage)
            .input('IsIncrease', sql.Bit, isIncrease ? 1 : 0) // Convert JS boolean to SQL Bit
            .execute('sp_UpdateProductPrice');

        res.json({ success: true, message: 'Fiyat başarıyla güncellendi.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

/* 6. DELETE OLD VEHICLES (POST) */
app.post('/api/delete-vehicles', async (req, res) => {
    try {
        const { cutoffYear } = req.body;
        const pool = await poolPromise;
        const request = pool.request();

        // Capture "X adet eski araç silindi" message from SP
        let sqlMessages = '';
        request.on('info', (info) => { sqlMessages += info.message; });

        await request
            .input('CutoffYear', sql.Int, cutoffYear)
            .execute('sp_DeleteOldVehicles');

        res.json({ success: true, message: sqlMessages || 'İşlem tamamlandı.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});


// ==========================================
// PART 2: GENERIC CRUD ROUTES
// ==========================================
const tableConfig = {
    'Customer': 'CustomerID',
    'Supplier': 'SupplierID',
    'Employee': 'EmployeeID',
    'Product':  'ProductID',
    'Vehicle':  'VehicleID',
    'Company':  'CompanyID'
};

app.get('/api/data/:tableName', async (req, res) => {
    const { tableName } = req.params;
    if (!tableConfig[tableName]) return res.status(400).send("Geçersiz Tablo");
    try {
        const pool = await poolPromise;
        const result = await pool.request().query(`SELECT * FROM ${tableName}`);
        res.json(result.recordset);
    } catch (err) { res.status(500).send(err.message); }
});

app.delete('/api/data/:tableName/:id', async (req, res) => {
    const { tableName, id } = req.params;
    const pkColumn = tableConfig[tableName];
    if (!pkColumn) return res.status(400).send("Geçersiz Tablo");
    try {
        const pool = await poolPromise;
        await pool.request().input('id', sql.Int, id).query(`DELETE FROM ${tableName} WHERE ${pkColumn} = @id`);
        res.json({ success: true, message: 'Kayıt silindi.' });
    } catch (err) { res.status(500).send(err.message); }
});

app.post('/api/data/:tableName', async (req, res) => {
    const { tableName } = req.params;
    const data = req.body;
    if (!tableConfig[tableName]) return res.status(400).send("Geçersiz Tablo");
    try {
        const pool = await poolPromise;
        const request = pool.request();
        const columns = Object.keys(data).join(', ');
        const values = Object.keys(data).map(key => `@${key}`).join(', ');
        Object.keys(data).forEach(key => request.input(key, data[key]));
        await request.query(`INSERT INTO ${tableName} (${columns}) VALUES (${values})`);
        res.json({ success: true, message: 'Kayıt eklendi.' });
    } catch (err) { res.status(500).send(err.message); }
});

app.put('/api/data/:tableName/:id', async (req, res) => {
    const { tableName, id } = req.params;
    const data = req.body;
    const pkColumn = tableConfig[tableName];
    if (!pkColumn) return res.status(400).send("Geçersiz Tablo");
    try {
        const pool = await poolPromise;
        const request = pool.request();
        const setClause = Object.keys(data).map(key => `${key} = @${key}`).join(', ');
        request.input('id', sql.Int, id);
        Object.keys(data).forEach(key => request.input(key, data[key]));
        await request.query(`UPDATE ${tableName} SET ${setClause} WHERE ${pkColumn} = @id`);
        res.json({ success: true, message: 'Kayıt güncellendi.' });
    } catch (err) { res.status(500).send(err.message); }
});

const PORT = 3000;
app.listen(PORT, () => { console.log(`✅ Server running: http://localhost:${PORT}`); });