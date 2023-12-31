USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_RELATED_ORGANIZATIONS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_RELATED_ORGANIZATIONS](@JSON NVARCHAR(MAX))
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[OIC] [bigint] NULL,
		[OrganizationCatagory] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[OIC] [bigint] '$.oic',
		[OrganizationCatagory] [nvarchar](max) '$.organizationCatagory'
	) A;

	DECLARE @AIC BIGINT = (SELECT TOP 1 [AIC] FROM @TEMP);

	--merge temp with original table
	MERGE [dbo].[RelatedOrganization] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC]= TEMP.[OIC] AND ORI.[AIC] = TEMP.[AIC] AND ORI.[ID] = TEMP.[ID])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [OIC], [OrganizationCatagory])
		 VALUES(TEMP.[AIC],TEMP.[OIC],TEMP.[OrganizationCatagory])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--execute sp for update inter relationships
    EXEC UPDATE_INFERENCE_RELATIONSHIPS @AIC;

	--delete temp data
	DELETE FROM @TEMP
END
GO
