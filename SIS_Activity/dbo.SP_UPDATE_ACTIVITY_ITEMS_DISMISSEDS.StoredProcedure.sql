USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_ITEMS_DISMISSEDS]    Script Date: 7/19/2023 12:39:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_ITEMS_DISMISSEDS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[IIC] [bigint] NOT NULL,
		[Category] [nvarchar](max) NULL,
		[Description] [nvarchar](max) NULL,
		[Number] [nvarchar](max) NULL
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
		[Category] [nvarchar](max) '$.category',
		[Description] [nvarchar](max) '$.description',
		[Number] [nvarchar](max) '$.number'
	) A;

	--merge temp with original table
	MERGE [dbo].[ItemsDismiss] ORI
	USING @TEMP TEMP
	ON (ORI.[ID] = TEMP.[ID] AND ORI.[AIC] = TEMP.[AIC] AND ORI.[IIC] = TEMP.[IIC])
	WHEN MATCHED 
		 THEN UPDATE SET    
		 ORI.[Category] = TEMP.[Category],
		 ORI.[Description] = TEMP.[Description],
		 ORI.[Number] = TEMP.[Number]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [IIC],[Category],[Description],[Number])
		 VALUES (TEMP.[AIC],TEMP.[IIC],TEMP.[Category],TEMP.[Description],TEMP.[Number])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;


	
	DELETE FROM SIS_Item.dbo.RelatedActivity
	WHERE InferredTable='SIS_Activity.dbo.ItemsDismiss'
	AND AIC=(SELECT TOP 1 [AIC] FROM @TEMP)
	-- INSERTING
	INSERT INTO SIS_ITEM.dbo.RelatedActivity(IIC,AIC,Description,IsInferred,InferredTable)
		-- ITEMS USED
		SELECT IIC,AIC,Description,1,'SIS_Activity.dbo.ItemsDismiss' FROM SIS_Activity.dbo.ItemsDismiss
		WHERE AIC=(SELECT TOP 1 [AIC] FROM @TEMP)
		


	--delete temp data
	DELETE FROM @TEMP

END
