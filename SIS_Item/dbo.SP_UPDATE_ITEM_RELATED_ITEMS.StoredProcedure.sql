USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_RELATED_ITEMS]    Script Date: 26/07/2023 13:41:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_RELATED_ITEMS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[RelatedItems(IIC)] [bigint] NULL
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
		[RelatedItems(IIC)] [bigint] '$.relatedItemsIIC'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[RelatedItem] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC AND ORI.[RelatedItems(IIC)] = TEMP.[RelatedItems(IIC)])
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[RelatedItems(IIC)])
		VALUES(TEMP.[IIC],TEMP.[RelatedItems(IIC)])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

	DELETE FROM SIS_Item.dbo.RelatedItem
	WHERE [RelatedItems(IIC)] = (SELECT TOP(1) [IIC] FROM @TEMP)

	INSERT INTO SIS_Item.dbo.RelatedItem(IIC, [RelatedItems(IIC)], IsInferred, InferredTable)
	SELECT [RelatedItems(IIC)],IIC,1,'SIS_Item.dbo.RelatedItem' FROM SIS_Item.dbo.RelatedItem
	WHERE IIC=(SELECT TOP(1) [IIC] FROM @TEMP)

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END