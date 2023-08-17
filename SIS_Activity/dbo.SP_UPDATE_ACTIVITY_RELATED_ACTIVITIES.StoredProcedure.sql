USE [SIS_Activity]
GO

/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_RELATED_ACTIVITIES]    Script Date: 28/06/2023 14:42:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_RELATED_ACTIVITIES]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[RelatedActivity(AIC)] [bigint] NULL,
		[ID] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[AIC] [bigint] '$.aic',
		[RelatedActivity(AIC)] [bigint] '$.relatedActivityAIC',
		[ID] [bigint] '$.id'
	) A;

	--merge temp with original table
	MERGE [dbo].[RelatedActivities] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.AIC = TEMP.AIC AND ORI.[RelatedActivity(AIC)] = TEMP.[RelatedActivity(AIC)])
	WHEN MATCHED 
		 THEN UPDATE
		 SET ORI.[RelatedActivity(AIC)] = TEMP.[RelatedActivity(AIC)]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [RelatedActivity(AIC)])
		 VALUES (TEMP.[AIC],TEMP.[RelatedActivity(AIC)])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;


		-- REMOVING ACTIVITIES
	DELETE FROM SIS_Activity.dbo.RelatedActivities
	WHERE IsInferred = 1
	AND [RelatedActivity(AIC)] = (SELECT TOP 1 [AIC] FROM @TEMP)
	--INSERTING BACK
	INSERT INTO SIS_Activity.dbo.RelatedActivities([RelatedActivity(AIC)],AIC, IsInferred, InferredTable)
	SELECT AIC, [RelatedActivity(AIC)],1,'SIS_Activity.dbo.RelatedActivities' FROM SIS_Activity.dbo.RelatedActivities
	WHERE AIC=(SELECT TOP 1 [AIC] FROM @TEMP)


		--delete temp data
	DELETE FROM @TEMP


END
GO


