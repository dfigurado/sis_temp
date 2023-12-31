USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_BRANCHES]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_BRANCHES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[Id] [bigint] NULL,
		[Year] [int] NULL,
		[Count] [int] NULL,
		[OIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[Year] [int] '$.year',
		[Count] [int] '$.count',
		[OIC] [bigint] '$.oic'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(OIC) FROM @TEMP);
	IF(@RcowCount = 1 AND EXISTS(SELECT [OIC]  FROM @TEMP WHERE [Count] IS NULL))
	BEGIN
		DELETE FROM [dbo].[Branches] WHERE [OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Branches] ORI
		USING @TEMP TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[OIC] = TEMP.[OIC],
			 ORI.[Year] = TEMP.[Year],
			 ORI.[Count] = TEMP.[Count]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([OIC], [Year], [Count])
			 VALUES(TEMP.[OIC],TEMP.[Year],TEMP.[Count])
		WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
		THEN DELETE;
	END

	--delete temp data
	DELETE FROM @TEMP;
END
GO
