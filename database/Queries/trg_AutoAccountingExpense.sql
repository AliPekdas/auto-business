/* 
Trigger 5: Auto Accounting Expense
When products are purchased from a supplier, the amount paid is automatically recorded as an "Gider" in the Accounting table.
*/

USE [Auto Business]
GO

CREATE TRIGGER trg_AutoAccountingExpense
ON PurchaseDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO Accounting (TransactionDate, Amount, TransactionType, SaleOrderID, PurchaseOrderID)
    SELECT 
        GETDATE(),         
        (i.UnitPrice * i.Quantity),
        'Gider',              
        NULL,                  
        i.PurchaseOrderID      
    FROM inserted i
END

GO