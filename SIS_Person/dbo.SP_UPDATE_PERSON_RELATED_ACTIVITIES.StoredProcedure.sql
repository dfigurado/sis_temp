USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_RELATED_ACTIVITIES]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_RELATED_ACTIVITIES]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Category] [nvarchar](max) NULL,
		[IdentifyingFeature] [nvarchar](max) NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[AIC] [bigint] '$.aic',
		[Category] [nvarchar](max) '$.category',
		[IdentifyingFeature] [nvarchar](max) '$.identifyingFeature'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT PIC  FROM @TEMP WHERE [Category] IS NULL))
		BEGIN
			DELETE FROM [dbo].[RelatedActivities] WHERE PIC = (SELECT TOP 1 PIC FROM @TEMP)
		END
	ELSE
		BEGIN
			--merge temp with original table
			MERGE [dbo].[RelatedActivities] ORI
			USING @TEMP TEMP
			ON (ORI.ID = TEMP.ID)
			WHEN MATCHED 
				 THEN UPDATE
				 SET
				 ORI.PIC = TEMP.PIC,
				 ORI.[AIC] = TEMP.[AIC],
				 ORI.[Category] = TEMP.[Category],
				 ORI.[IdentifyingFeature] = TEMP.[IdentifyingFeature]
			WHEN NOT MATCHED BY TARGET
				 THEN INSERT ([PIC], [AIC],[Category],[IdentifyingFeature])
				 VALUES(TEMP.PIC,TEMP.[AIC],TEMP.[Category],TEMP.[IdentifyingFeature])
			WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
			THEN DELETE;
		END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
