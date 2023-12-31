USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_PHOTOGRAPHS]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_PHOTOGRAPHS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[Path] [nvarchar](max) NULL,
		[Description] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[OIC] [bigint] '$.oic',
		[Path] [nvarchar](max) '$.path',
		[Description] [nvarchar](max) '$.description'
	) A;


	--merge temp with original table
	MERGE [dbo].[Photographs] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[Path] = TEMP.[Path],
		 ORI.[Description] = TEMP.[Description]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [Path], [Description], [AddedDate])
		 VALUES(TEMP.[OIC],TEMP.[Path],TEMP.[Description],GETDATE())
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
