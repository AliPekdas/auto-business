// db.js - Sabit Ayarlar
const sql = require('mssql');

const config = {
    user: 'sa',               
    password: '########',     
    server: 'localhost',       
    database: 'Auto Business',
    options: {
        encrypt: false, 
        trustServerCertificate: true,
        enableArithAbort: true
    }
};

const poolPromise = new sql.ConnectionPool(config)
    .connect()
    .then(pool => {
        console.log('SQL Server Connection Successfull!');
        return pool;
    })
    .catch(err => {
        console.error('Connection Error:', err);
    });

module.exports = {
    sql,
    poolPromise
};