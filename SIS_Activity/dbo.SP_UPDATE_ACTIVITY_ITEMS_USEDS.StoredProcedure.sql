USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_ITEMS_USEDS]    Script Date: 7/19/2023 12:41:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_ITEMS_USEDS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[IIC] [bigint] NULL,
		[MajorType] [nvarchar](max) NULL,
		[MinorType] [nvarchar](max) NULL,
		[Number] [nvarchar](max) NULL,
		[Description] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[IIC] [bigint] '$.iic',
		[MajorType] [nvarchar](max) '$.majorType',
		[MinorType] [nvarchar](max) '$.minorType',
		[Number] [nvarchar](max) '$.number',
		[Description] [nvarchar](max) '$.description'
	) A;

	--merge temp with original table
	MERGE [dbo].[ItemsUsed] ORI
	USING @TEMP TEMP
	ON (ORI.[ID] = TEMP.[ID] AND ORI.[AIC] = TEMP.[AIC] AND ORI.[IIC] = TEMP.[IIC])
	WHEN MATCHED 
		 THEN UPDATE SET    
		 ORI.[MajorType] = TEMP.[MajorType],
		 ORI.[MinorType] = TEMP.[MinorType],
		 ORI.[Number] = TEMP.[Number],
		 ORI.[Description] = TEMP.[Description]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [IIC],[MajorType],[MinorType],[Number],[Description])
		 VALUES (TEMP.[AIC],TEMP.[IIC],TEMP.[MajorType],TEMP.[MinorType],TEMP.[Number],TEMP.[Description])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	DELETE FROM SIS_Item.dbo.RelatedActivity
	WHERE InferredTable='SIS_Activity.dbo.ItemsUsed'
	AND AIC=(SELECT TOP 1 [AIC] FROM @TEMP)
	-- INSERTING
	INSERT INTO SIS_ITEM.dbo.RelatedActivity(IIC,AIC,Description,IsInferred,InferredTable)
		-- ITEMS USED
		SELECT IIC,AIC,Description,1,'SIS_Activity.dbo.ItemsUsed' FROM SIS_Activity.dbo.ItemsUsed
		WHERE AIC=(SELECT TOP 1 [AIC] FROM @TEMP)
		

	--delete temp data
	DELETE FROM @TEMP

END
