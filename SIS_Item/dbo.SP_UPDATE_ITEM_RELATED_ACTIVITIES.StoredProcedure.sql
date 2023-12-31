USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_RELATED_ACTIVITIES]    Script Date: 7/26/2023 4:39:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_RELATED_ACTIVITIES] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Description] [nvarchar](max) NULL,
		[Type] [nvarchar](max) NULL
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
		[AIC] [bigint] '$.aic',
		[Description] [nvarchar](max) '$.description',
		[Type] [nvarchar](max) '$.type'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[RelatedActivity] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC AND ORI.[AIC] = TEMP.[AIC])
	WHEN MATCHED THEN
		UPDATE SET
		ORI.[Description] = TEMP.[Description],
		ORI.[Type] = TEMP.[Type]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[AIC],[Description],[Type])
		VALUES(TEMP.[IIC],TEMP.[AIC],TEMP.[Description],TEMP.[Type])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;
	-----
	DELETE FROM SIS_Activity.dbo.ItemsUsed
	WHERE IsInferred = 1
	AND IIC = (SELECT TOP 1 [IIC] FROM @TEMP)

	INSERT INTO SIS_Activity.dbo.ItemsUsed( AIC,IIC,Description,IsInferred, InferredTable)
	SELECT AIC,IIC,(select [DescriptionOfItem] from [dbo].[ItemInformation] where IIC=(SELECT TOP 1 [IIC] FROM @TEMP)),1,'SIS_Item.RelatedActivity' FROM [SIS_Item].[dbo].[RelatedActivity]
	wHERE IIC = (SELECT TOP 1 [IIC] FROM @TEMP)


	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
