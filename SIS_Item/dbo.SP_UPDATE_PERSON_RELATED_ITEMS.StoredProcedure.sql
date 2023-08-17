USE [SIS_Item]
GO

/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_RELATED_PERSONS]    Script Date: 23/06/2023 13:58:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_RELATED_PERSONS] @JSON NVARCHAR(MAX)

AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[PIC] [bigint] NULL
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
		[PIC] [bigint] '$.pic'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[RelatedPersons] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC AND ORI.[PIC] = TEMP.[PIC])
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[PIC])
		VALUES(TEMP.[IIC],TEMP.[PIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

   --REMOVING THIS ITEM TO PERSON PERSON.ITEMRELATED
    DELETE FROM [SIS_Person].[dbo].[RelatedItems]
	WHERE IsInferred=1
	AND IIC=(SELECT TOP 1 IIC FROM @TEMP)

	-- MAKE RELATIONS FROM RELATED ITEMS
	INSERT INTO [SIS_Person].[dbo].[RelatedItems](IIC,PIC,IsInferred, InferredTable)
	SELECT IIC, PIC, 1, 'SIS_Item.dbo.RelatedPersons' AS IsInferred FROM [SIS_Item].[dbo].[RelatedPersons] WHERE IIC=(SELECT TOP 1 IIC FROM @TEMP)

	--DELETE TEMP DATA
	DELETE FROM @TEMP;

	



END
GO


