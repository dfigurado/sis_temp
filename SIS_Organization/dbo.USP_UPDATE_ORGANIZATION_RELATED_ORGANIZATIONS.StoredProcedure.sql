USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ORGANIZATIONS]    Script Date: 8/15/2023 10:57:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ORGANIZATIONS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[RelatedOrganizations(OIC)] [bigint] NULL,
        [OrganizationCatagory] [nvarchar](max) null
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[RelatedOrganizations(OIC)] [bigint] '$.relatedOIC',
		[OrganizationCatagory] [nvarchar](max) '$.organizationCatagory'
	) A;


	--merge temp with original table
	MERGE [dbo].[RelatedOrganizations] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[RelatedOrganizations(OIC)] = TEMP.[RelatedOrganizations(OIC)])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [RelatedOrganizations(OIC)],[OrganizationCatagory])
		 VALUES(TEMP.[OIC],TEMP.[RelatedOrganizations(OIC)],TEMP.[OrganizationCatagory])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
