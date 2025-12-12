/* 
Stored Procedure 7: Get Customer Garage
It brings the vehicles owned by a customer.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_GetCustomerGarage
    @CustomerName NVARCHAR(100)
AS
BEGIN
    SELECT 
        C.CustomerName,
        V.LicensePlate,
        V.Brand,
        V.ModelYear
    FROM Vehicle V
    INNER JOIN Customer C 
    ON V.CustomerID = C.CustomerID
    WHERE C.CustomerName LIKE '%' + @CustomerName + '%'
END

GO


EXEC sp_GetCustomerGarage
    @CustomerName = 'Ahmet Yýlmaz'