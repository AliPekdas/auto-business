/* 
View 2: Stock Alert
Lists products whose stock falls below 20 and supplier information.
*/

USE [Auto Business]
GO

CREATE VIEW view_StockAlert AS
SELECT 
    P.ProductID,
    P.ProductName,
    P.StockQuantity,
    P.ItemPrice,
    CASE 
        WHEN P.StockQuantity = 0 THEN 'STOK TÜKENDÝ'
        WHEN P.StockQuantity < 10 THEN 'KRÝTÝK SEVÝYE'
        ELSE 'AZALIYOR'
    END AS StockStatus
FROM Product P
WHERE P.StockQuantity < 20

GO


SELECT * FROM view_StockAlert