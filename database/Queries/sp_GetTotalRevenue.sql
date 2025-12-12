/* 
Stored Procedure 5: Get Total Revenue
Get the total revenue for a specific date range
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_GetTotalRevenue
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT 
        SUM(Amount) AS TotalRevenue
    FROM Accounting
    WHERE TransactionType = 'Gelir' 
      AND TransactionDate BETWEEN @StartDate AND @EndDate
END

GO


EXEC sp_GetTotalRevenue
    @StartDate = '2025-10-01',
    @EndDate = '2025-11-30'