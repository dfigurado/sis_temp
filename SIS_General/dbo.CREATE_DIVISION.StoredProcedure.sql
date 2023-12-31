USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_DIVISION]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CREATE_DIVISION](@JSON NVARCHAR(MAX))
AS

BEGIN

	DECLARE @Type AS nVARCHAR(MAX)  = (SELECT [Value] FROM OPENJSON(@JSON)WHERE [Key] = 'hierarchyLevel')
	DECLARE @ParentCategogyID AS INT = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'parentCategogyID')
	DECLARE @Name AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'name')
	DECLARE @Description AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'description')


		INSERT INTO [Levels] (Name,[Type],ParentID,[Description]) 
		OUTPUT CAST(INSERTED.ID AS bigint) 
			 VALUES (@Name,@Type,@ParentCategogyID,@Description)

		EXEC UPDATE_DESK_USER_PERMISSION
END

GO
