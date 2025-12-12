/* 
Stored Procedure 1: Add New Customer
Instead of a simple insert operation, it adds by checking emails.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_AddNewCustomer
    @CompanyID INT,
    @Name NVARCHAR(100),
    @Phone VARCHAR(20),
    @Email VARCHAR(100),
    @Address NVARCHAR(200)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Customer WHERE Email = @Email)
    BEGIN
        PRINT 'Bu email adresiyle kayýtlý bir müþteri zaten var.'
        RETURN
    END

    INSERT INTO Customer (CompanyID, CustomerName, PhoneNumber, Email, Address)
    VALUES (@CompanyID, @Name, @Phone, @Email, @Address)
    
    PRINT 'Müþteri baþarýyla eklendi.'
END

GO


EXEC sp_AddNewCustomer 
    @CompanyID = 1, 
    @Name = 'Ebru Gündeþ', 
    @Phone = '0555 123 4567', 
    @Email = 'ebru@gmail.com', 
    @Address = 'Ýstanbul, Türkiye'