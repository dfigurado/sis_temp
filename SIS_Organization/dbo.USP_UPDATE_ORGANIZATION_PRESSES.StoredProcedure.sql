USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_PRESSES]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_PRESSES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[PressesOIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[PressesOIC] [bigint] '$.relatedOIC'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(OIC) FROM @TEMP);
	IF(@RcowCount = 1 AND EXISTS(SELECT [OIC]  FROM @TEMP WHERE [PressesOIC] IS NULL))
	BEGIN
		DELETE FROM [dbo].[Presses] WHERE [OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Presses] ORI
		USING @TEMP TEMP
		ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[PressesOIC] = TEMP.[PressesOIC])
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([OIC], [PressesOIC])
			 VALUES(TEMP.[OIC],TEMP.[PressesOIC])
		WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
		THEN DELETE;

	END
	
	--delete temp data
	DELETE FROM @TEMP;
END
GO
