USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ACTIVITIES]    Script Date: 20/07/2023 15:06:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ACTIVITIES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[AIC] [bigint] NULL,
		[ID] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[AIC] [bigint] '$.relatedAIC',
		[ID] [bigint] '$.id'
	) A;


	--merge temp with original table
	MERGE [dbo].[RelatedActivities] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[AIC] = TEMP.[AIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [AIC])
		 VALUES(TEMP.[OIC],TEMP.[AIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	DELETE FROM SIS_Activity.dbo.RelatedOrganization
	WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	INSERT INTO SIS_Activity.dbo.RelatedOrganization(OIC,AIC,IsInferred,InferredTable)
    SELECT OIC,AIC,1,'SIS_Organization.dbo.RelatedActivities' FROM SIS_Organization.dbo.RelatedActivities
    WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
