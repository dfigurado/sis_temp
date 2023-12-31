USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_ALIASES]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_ALIASES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[AliasName] [nvarchar](max) NOT NULL,
		[AddedDate] [datetime] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[OIC] [bigint] '$.oic',
		[AliasName] [nvarchar](max) '$.aliasName',
		[AddedDate] [datetime] '$.addedDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT([OIC]) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [OIC]  FROM @TEMP WHERE [AliasName] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Aliases] WHERE [OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Aliases] ORI
		USING @TEMP TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[OIC] = TEMP.[OIC],
			 ORI.[AliasName] = TEMP.[AliasName]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([OIC], [AliasName], [AddedDate])
			 VALUES(TEMP.[OIC],TEMP.[AliasName],GETDATE())
		WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
		THEN DELETE;
	END
	
	--delete temp data
	DELETE FROM @TEMP;
END
GO
