USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_PUBLICATIONS]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_PUBLICATIONS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[PublicationsOIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[PublicationsOIC] [bigint] '$.relatedOIC'
	) A;


	--merge temp with original table
	MERGE [dbo].[Publications] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[PublicationsOIC] = TEMP.[PublicationsOIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [PublicationsOIC])
		 VALUES(TEMP.[OIC],TEMP.[PublicationsOIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
