/* 
View 4: Financial Summary
It shows the profit/loss situation on a monthly basis from the accounting table.
*/

USE [Auto Business]
GO

CREATE VIEW view_FinancialSummary AS
SELECT 
    YEAR(TransactionDate) AS [Year],
    MONTH(TransactionDate) AS [Month],
    SUM(CASE WHEN TransactionType = 'Gelir' THEN Amount ELSE 0 END) AS TotalIncome,
    SUM(CASE WHEN TransactionType = 'Gider' THEN Amount ELSE 0 END) AS TotalExpense,
    (SUM(CASE WHEN TransactionType = 'Gelir' THEN Amount ELSE 0 END) - 
     SUM(CASE WHEN TransactionType = 'Gider' THEN Amount ELSE 0 END)) AS NetProfit
FROM Accounting
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate)

GO


SELECT * FROM view_FinancialSummary


SELECT [Year], SUM(TotalIncome) AS AnnualTotalIncome, SUM(TotalExpense) AS AnnualTotalExpense, SUM(NetProfit) AS AnnualNetProfit
FROM view_FinancialSummary
GROUP BY [Year]