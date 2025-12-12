/* 
View 3: Customer Analysis
It is used to find the top 10 customers who spend the most (VIPs).
*/

USE [Auto Business]
GO

CREATE VIEW view_CustomerAnalysis AS
SELECT TOP 10
    C.CustomerID,
    C.CustomerName,
    C.Address,
    COUNT(SO.SaleOrderID) AS TotalOrders,
    ISNULL(SUM(SD.Quantity * SD.UnitPrice), 0.00) AS TotalSpent
FROM Customer C
    LEFT JOIN SaleOrder SO 
    ON C.CustomerID = SO.CustomerID
    LEFT JOIN SaleDetail SD 
    ON SO.SaleOrderID = SD.SaleOrderID
GROUP BY C.CustomerID, C.CustomerName, C.Address

GO


SELECT * FROM view_CustomerAnalysis ORDER BY TotalSpent DESC, CustomerID ASC