USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_PERMISION_RELATION]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_PERMISION_RELATION](@JSON NVARCHAR(MAX))
AS
BEGIN

	DECLARE @RID INT
	SET @RID = (SELECT ID FROM OPENJSON(@JSON) WITH(ID int '$.id'))
	SELECT * INTO #JSON FROM OPENJSON(@JSON)

	UPDATE ORI
	SET ORI.[Level] = X.[Level],
	ORI.[Add] = X.[Add],
	ORI.[Edit] = X.[Edit],
	ORI.[Delete] = X.[Delete],
	ORI.[View] = X.[View],
	ORI.[Print] = X.[Print],
	ORI.[Email] = X.[Email],
	ORI.[Download] = X.[Download]

	FROM [dbo].[PermissionRelations] ORI
	INNER JOIN 	(SELECT * FROM OPENJSON(@JSON)
					 WITH(
							ID int '$.id',
							[Level] nvarchar(max) '$.level',
							[View] bit '$.view',
							[Add] bit '$.add',
							[Edit] bit '$.edit',
							[Delete] bit '$.delete',
							[Print] bit '$.print',
							[Email] bit '$.email',
							[Download] bit '$.download'
						 )) X
	ON ORI.ID = X.ID

	DELETE FROM [dbo].[RelationshipLevels] WHERE RelationshipID = @RID

	CREATE TABLE #levelID (ID int)
	DECLARE @levels nVARCHAR(MAX) = (SELECT [value] FROM #JSON WHERE [key] = 'levels')
	DECLARE @i int = 0
	WHILE((SELECT MAX(CAST([key]AS int)) FROM OPENJSON(@levels)) >= @i)
	BEGIN

		DECLARE @levelJson nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@levels) WHERE [key] = @i)
		INSERT INTO #levelID
		SELECT ID FROM OPENJSON(@levelJson)WITH(ID int '$.id')

	SET @i = @i + 1
	END

	--IRelationshipID & LevelID Insert to RelationShipLevels table
	INSERT INTO RelationShipLevels (RelationshipID,LevelID)
	SELECT @RID AS 'RelationshipID', ID AS 'LevelID' FROM #levelID

	exec [dbo].[UPDATE_DESK_USER_PERMISSION]

END
GO
