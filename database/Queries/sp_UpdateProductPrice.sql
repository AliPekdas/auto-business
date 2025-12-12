/* 
Stored Procedure 2: Update Product Price
Applies a specific percentage increase or decrease.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_UpdateProductPrice
    @ProductID INT,
    @Percentage DECIMAL(5, 2),
    @IsIncrease BIT
AS
BEGIN
    UPDATE Product
    SET ItemPrice = CASE 
                        WHEN @IsIncrease = 1 THEN ItemPrice * (1 + (@Percentage / 100))
                        ELSE ItemPrice * (1 - (@Percentage / 100))
                    END
    WHERE ProductID = @ProductID
END

GO


EXEC sp_UpdateProductPrice 
    @ProductID = 1, 
    @Percentage = 10, 
    @IsIncrease = 1


EXEC sp_UpdateProductPrice 
    @ProductID = 5, 
    @Percentage = 20, 
    @IsIncrease = 0