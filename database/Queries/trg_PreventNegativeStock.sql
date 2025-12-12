/* 
Trigger 3: Prevent Negative Stock
If (Current Stock - Quantity to be Sold) < 0, return error
*/

USE [Auto Business]
GO

CREATE TRIGGER trg_PreventNegativeStock
ON SaleDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 
        FROM Product P
        INNER JOIN inserted i ON P.ProductID = i.ProductID
        WHERE (P.StockQuantity - i.Quantity) < 0
    )
    BEGIN
        RAISERROR ('HATA: Yetersiz Stok! Satýþ iþlemi gerçekleþtirilemedi. Stok miktarýný kontrol ediniz.', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        INSERT INTO SaleDetail (SaleOrderID, ProductID, UnitPrice, Quantity)
        SELECT SaleOrderID, ProductID, UnitPrice, Quantity FROM inserted
    END
END

GO