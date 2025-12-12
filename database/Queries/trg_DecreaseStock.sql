/* 
Trigger 2: Decrease Stock
When a product is sold to a customer, it automatically reduces the product's inventory.
*/

USE [Auto Business]
GO

CREATE TRIGGER trg_DecreaseStock
ON SaleDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE P
    SET P.StockQuantity = P.StockQuantity - i.Quantity
    FROM Product P
    INNER JOIN inserted i 
    ON P.ProductID = i.ProductID
END

GO