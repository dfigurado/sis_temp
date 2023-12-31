USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_ROLEWISE_ACCESS_RESTRICTIONS]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ITEM_ROLEWISE_ACCESS_RESTRICTIONS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[IIC] [bigint] NULL,
		[DirectorOnly] [bit] NULL,
		[DeskOfficerOnly] [bit] NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT * FROM OPENJSON(@JSON) WITH(
		[IIC] [bigint] '$.iic',
		[DirectorOnly] [bit] '$.directorOnly',
		[DeskOfficerOnly] [bit] '$.deskOfficerOnly'
	);

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[DirectAndRoleWiseAccessRestrictions] ORI
	USING @TEMP TEMP
	ON (ORI.IIC = TEMP.IIC)
	WHEN MATCHED THEN UPDATE
		SET 
		ORI.[DirectorOnly] = TEMP.[DirectorOnly],
		ORI.[DeskOfficerOnly] = TEMP.[DeskOfficerOnly]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[DirectorOnly],[DeskOfficerOnly])
		VALUES(TEMP.[IIC],TEMP.[DirectorOnly],TEMP.[DeskOfficerOnly])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
