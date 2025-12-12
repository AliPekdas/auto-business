/* 
Trigger 4: Auto Accounting Income
The payment for each item sold is automatically recorded as "Gelir" in the Accounting table.
*/

USE [Auto Business]
GO

CREATE TRIGGER trg_AutoAccountingIncome
ON SaleDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO Accounting (TransactionDate, Amount, TransactionType, SaleOrderID, PurchaseOrderID)
    SELECT 
        GETDATE(),              
        (i.UnitPrice * i.Quantity), 
        'Gelir',                
        i.SaleOrderID,          
        NULL                    
    FROM inserted i
END

GO