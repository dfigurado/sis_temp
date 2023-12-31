USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_ORGANIZATION_INFO]    Script Date: 26/07/2023 16:07:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_ORGANIZATION_INFO] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[OIC] [bigint] NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[IIC] [bigint] '$.iic',
		[OIC] [bigint] '$.oic'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[RelatedOrganizations] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC AND ORI.[OIC] = TEMP.[OIC])
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[OIC])
		VALUES(TEMP.[IIC],TEMP.[OIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

    DELETE FROM SIS_Organization.dbo.RelatedItems
	WHERE [IIC] = (SELECT TOP(1) [IIC] FROM @TEMP)

	INSERT INTO SIS_Organization.dbo.RelatedItems(OIC,IIC,IsInferred, InferredTable)
	SELECT OIC,IIC,1,'SIS_Item.dbo.RelatedItem' FROM SIS_Item.[dbo].[RelatedOrganizations]
	WHERE IIC=(SELECT TOP(1) [IIC] FROM @TEMP)

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END