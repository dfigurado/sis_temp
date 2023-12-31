USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_SAFEHOUSES]    Script Date: 7/21/2023 11:30:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_SAFEHOUSES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[SafeHousesOIC] [bigint] NULL,
		[FromDate] [datetime] NULL,
		[ToDate] [datetime] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[SafeHousesOIC] [bigint] '$.relatedOIC',
		[FromDate] [datetime] '$.fromDate',
		[ToDate] [datetime] '$.toDate'
	) A;


	--merge temp with original table
	MERGE [dbo].[SafeHouses] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[SafeHousesOIC] = TEMP.[SafeHousesOIC] AND ORI.[FromDate] = TEMP.[FromDate] AND ORI.[ToDate] = TEMP.[ToDate])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [SafeHousesOIC], [FromDate], [ToDate])
		 VALUES(TEMP.[OIC],TEMP.[SafeHousesOIC],TEMP.[FromDate],TEMP.[ToDate])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--DELETE ALL SAFE HOUSE FROM RELATEDORGANIZATION
	DELETE FROM SIS_Organization.dbo.RelatedOrganizations
	WHERE InferredTable = 'SIS_Organization.dbo.SafeHouses'
	AND [RelatedOrganizations(OIC)] = (SELECT TOP 1 [OIC] FROM @TEMP)

	--INSERT BACK
	INSERT INTO SIS_Organization.dbo.RelatedOrganizations(OIC,[RelatedOrganizations(OIC)],IsInferred, InferredTable)
	SELECT SafeHousesOIC,OIC, 1,'SIS_Organization.dbo.SafeHouses' FROM SIS_Organization.dbo.SafeHouses
    WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
