/* 
Stored Procedure 3: Delete Old Vehicles
Deletes vehicles older than a specific model year.
*/

USE [Auto Business]
GO

CREATE PROCEDURE sp_DeleteOldVehicles
    @CutoffYear INT
AS
BEGIN
    DELETE FROM Vehicle 
    WHERE ModelYear < @CutoffYear
    
    PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' adet eski araç silindi.'
END

GO


EXEC sp_DeleteOldVehicles
    @CutoffYear = 2005