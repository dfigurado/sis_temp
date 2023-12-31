USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_DESK]    Script Date: 7/24/2023 4:39:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CREATE_DESK] (@JSON nVARCHAR(MAX), @deskId BIGINT = 0 OUTPUT)
AS
BEGIN
	DECLARE @subDivisionID INT
	DECLARE @name nVARCHAR(MAX)
	DECLARE @description nVARCHAR(MAX)
	DECLARE @TR_CREATE_DESK nVARCHAR(MAX)


BEGIN TRANSACTION @TR_CREATE_DESK
BEGIN TRY

	--INSERTING JSON ARRAY TO TEMP TABLE
SELECT * INTO #PARSED FROM OPENJSON(@JSON)
SELECT @name = [value] FROM #PARSED WHERE [key] = 'name'
SELECT @subDivisionID = [value] FROM #PARSED WHERE [key] = 'parentCategogyID'
SELECT @deskId = [value] FROM #PARSED WHERE [key] = 'deskID'
SELECT @description = [value] FROM #PARSED WHERE [key] = 'description'

    --CREATE DESK,IF @deskId = 0
    IF(@deskId = 0)
BEGIN

			DECLARE @mx_ID INT = (SELECT MAX(ID)+1 FROM SIS_General.dbo.Predefined_DeskTarget with(nolock) WHERE ID NOT IN (99,98))
			IF NOT EXISTS(SELECT ID FROM SIS_General.dbo.Predefined_DeskTarget with(nolock) WHERE ID = @mx_ID)
BEGIN

INSERT INTO SIS_General.dbo.Predefined_DeskTarget (ID,[Description]) VALUES (@mx_ID,@description)

END

			SET @deskId = @mx_ID

END


		--CREATE HIERARCHY IF @deskId <> 0
		IF (@deskId <> 0) AND NOT EXISTS (SELECT Desk FROM Hierarchy with(nolock) WHERE Desk = @deskId)
BEGIN

			IF EXISTS (SELECT * FROM Hierarchy with(nolock) WHERE SubDivisionID = @subDivisionID AND Desk IS NULL )
BEGIN

				DECLARE @divisionID AS INT = (SELECT DISTINCT ParentID
											    FROM SIS_General.dbo.Levels with(nolock)
											   WHERE ParentID IS NOT NULL
											     AND [Type] = 'SubDivision'
											     AND ID = @subDivisionID)

UPDATE Hierarchy
SET Desk = @deskId,
    CreatedDate = GETDATE()
WHERE SubDivisionID = @subDivisionID
  AND DivisionID = @divisionID
  AND Desk IS NULL

END

ELSE
BEGIN
INSERT INTO Hierarchy (DivisionID,SubDivisionID,Desk,CreatedDate)
    OUTPUT CAST(INSERTED.Desk AS bigint)
SELECT DISTINCT ParentID AS 'DivisionID',
        @subDivisionID AS 'SubDivisionID',
        @deskId AS 'Desk',
        GETDATE() 'CreatedDate'
FROM SIS_General.dbo.Levels with(nolock)
WHERE ParentID IS NOT NULL
  AND [Type] = 'SubDivision'
  AND ID = @subDivisionID

END
END
COMMIT TRANSACTION @TR_CREATE_DESK


END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION @TR_CREATE_DESK

SELECT CONCAT(ERROR_MESSAGE(),ERROR_SEVERITY(),ERROR_STATE())
END CATCH
return @deskId;
END
