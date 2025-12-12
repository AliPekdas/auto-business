/* 
Stored Procedure 8: Add Accounting Entry
It is used to enter income or expense manually.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_AddAccountingEntry
    @Amount DECIMAL(12,2),
    @Type NVARCHAR(20)
AS
BEGIN
    IF @Type NOT IN ('Gelir', 'Gider')
    BEGIN
        PRINT 'Hata: Type sadece Gelir veya Gider olabilir.'
        RETURN
    END

    INSERT INTO Accounting (TransactionDate, Amount, TransactionType, PurchaseOrderID, SaleOrderID)
    VALUES (GETDATE(), @Amount, @Type, NULL, NULL)
    
    PRINT 'Muhasebe kaydý eklendi.'
END

GO


EXEC sp_AddAccountingEntry
    @Amount = 1000.00,
    @Type = 'Gelir'