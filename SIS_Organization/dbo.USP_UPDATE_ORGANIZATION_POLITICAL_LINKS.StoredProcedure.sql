USE [SIS_Organization]
GO

/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_POLITICAL_LINKS]    Script Date: 19/07/2023 16:13:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_POLITICAL_LINKS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[LinkOIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[LinkOIC] [bigint] '$.relatedOIC'
	) A;


	--merge temp with original table
	MERGE [dbo].[PoliticalLinks] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[LinkOIC] = TEMP.[LinkOIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [LinkOIC])
		 VALUES(TEMP.[OIC],TEMP.[LinkOIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--REMOVING POLITICAL LINK
	DELETE FROM [SIS_Organization].[dbo].[PoliticalLinks]
	WHERE [LinkOIC]=(SELECT TOP 1 [OIC] FROM @TEMP)

	--INSERT BACK
	INSERT INTO [SIS_Organization].[dbo].[PoliticalLinks]([LinkOIC],OIC,IsInferred,InferredTable)
	SELECT OIC,[LinkOIC],1,'SIS_Organization.dbo.PoliticalLinks' FROM [SIS_Organization].[dbo].[PoliticalLinks]
    WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
GO


