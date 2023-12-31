USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_PHOTOGRAPHS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_PHOTOGRAPHS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Path] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[Path] [nvarchar](max) '$.path'
	) A;

	--merge temp with original table
	MERGE [dbo].[Photographs] ORI
	USING @TEMP TEMP
	ON (ORI.[AIC] = TEMP.[AIC] AND ORI.[AIC] = TEMP.[AIC])
	WHEN MATCHED THEN
	UPDATE SET
		ORI.[Path] = TEMP.[Path]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC],[Path],[AddedDate])
		 VALUES (TEMP.[AIC],TEMP.[Path],GETDATE())
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
