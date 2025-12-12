/* 
Trigger 1: Increase Stock
When products arrive from the supplier, it automatically increases the product's inventory.
*/

USE [Auto Business]
GO

CREATE TRIGGER trg_IncreaseStock
ON PurchaseDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE P
    SET P.StockQuantity = P.StockQuantity + i.Quantity
    FROM Product P
    INNER JOIN inserted i 
    ON P.ProductID = i.ProductID
END

GO