/* 
Stored Procedure 4: Sale Transaction
It records entries in both the SaleOrder and SaleDetail tables and creates the invoice.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_SaleTransaction
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

            DECLARE @CurrentPrice DECIMAL(10,2)
            SELECT @CurrentPrice = ItemPrice FROM Product WHERE ProductID = @ProductID

            INSERT INTO SaleOrder (CustomerID, SaleDate) VALUES (@CustomerID, GETDATE())
            DECLARE @NewSaleID INT = SCOPE_IDENTITY()

            INSERT INTO SaleDetail (SaleOrderID, ProductID, UnitPrice, Quantity)
            VALUES (@NewSaleID, @ProductID, @CurrentPrice, @Quantity)

            INSERT INTO Invoice (SaleOrderID, IssueDate)
            VALUES (@NewSaleID, GETDATE())

        COMMIT TRANSACTION
        PRINT 'Satýþ, Fatura ve Muhasebe kaydý baþarýyla oluþturuldu.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Hata oluþtu! Ýþlem geri alýndý.'
        PRINT ERROR_MESSAGE()
    END CATCH
END

GO


EXEC sp_SaleTransaction
    @CustomerID = 11,
    @ProductID = 8,
    @Quantity = 2