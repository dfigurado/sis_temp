USE [SIS_Organization]
GO

/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_SPLINTER_GROUPS]    Script Date: 18/07/2023 13:02:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_SPLINTER_GROUPS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[SplinterGroupOIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[SplinterGroupOIC] [bigint] '$.relatedOIC'
	) A;


	--merge temp with original table
	MERGE [dbo].[SplinterGroups] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[SplinterGroupOIC] = TEMP.[SplinterGroupOIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [SplinterGroupOIC])
		 VALUES(TEMP.[OIC],TEMP.[SplinterGroupOIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--DELETE ALL RELATED ORGANIZATION 
	DELETE FROM SIS_Organization.dbo.RelatedOrganizations
	WHERE InferredTable='SIS_Organization.dbo.SplinterGroups'
	AND [RelatedOrganizations(OIC)] = (SELECT TOP 1 [OIC] FROM @TEMP)

	--INSERT BACK 
	INSERT INTO SIS_Organization.dbo.RelatedOrganizations(OIC,[RelatedOrganizations(OIC)],IsInferred, InferredTable)
    SELECT SplinterGroupOIC,OIC, 1,'SIS_Organization.dbo.SplinterGroups' FROM SIS_Organization.dbo.SplinterGroups
    WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
GO


