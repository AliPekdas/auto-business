/* 
Stored Procedure 6: Manual Restock
For manual stock adjustments without making a purchase transaction.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_ManualRestock
    @ProductID INT,
    @AddedQuantity INT
AS
BEGIN
    IF @AddedQuantity <= 0
    BEGIN
        PRINT 'Eklenecek miktar 0 dan büyük olmalýdýr.'
        RETURN
    END

    UPDATE Product
    SET StockQuantity = StockQuantity + @AddedQuantity
    WHERE ProductID = @ProductID;
    
    PRINT 'Stok güncellendi.'
END

GO


EXEC sp_ManualRestock
    @ProductID =  20,
    @AddedQuantity = 5