/* 
View 1: Sales Report
Which customer purchased how many of which product on which date and what was the total amount paid?
*/

USE [Auto Business]
GO

CREATE VIEW view_SalesReport AS
SELECT 
    SO.SaleOrderID,
    C.CustomerName,
    SO.SaleDate,
    P.ProductName,
    P.Type AS ProductType,
    SD.Quantity,
    SD.UnitPrice,
    (SD.Quantity * SD.UnitPrice) AS TotalAmount
FROM SaleOrder SO
    INNER JOIN Customer C 
    ON SO.CustomerID = C.CustomerID
    INNER JOIN SaleDetail SD 
    ON SO.SaleOrderID = SD.SaleOrderID
    INNER JOIN Product P 
    ON SD.ProductID = P.ProductID

GO


SELECT * FROM view_SalesReport