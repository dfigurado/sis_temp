USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_EXTERNAL_LINKS]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_EXTERNAL_LINKS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NOT NULL,
		[ExternalLinksOIC] [bigint] NOT NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[ExternalLinksOIC] [bigint] '$.relatedOIC'
	) A;


	--merge temp with original table
	MERGE [dbo].[ExternalLinks] ORI
	USING @TEMP TEMP
	ON (ORI.OIC = TEMP.[OIC] AND ORI.[ExternalLinksOIC] = TEMP.[ExternalLinksOIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [ExternalLinksOIC])
		 VALUES(TEMP.[OIC],TEMP.[ExternalLinksOIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
