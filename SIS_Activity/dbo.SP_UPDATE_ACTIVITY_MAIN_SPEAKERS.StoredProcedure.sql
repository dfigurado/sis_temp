USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_MAIN_SPEAKERS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_MAIN_SPEAKERS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Name] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[AIC] [bigint] '$.aic',
		[PIC] [bigint] '$.pic',
		[Name] [nvarchar](max) '$.name'
	) A;

	--merge temp with original table
	MERGE [dbo].[MainSpeakers] ORI
	USING @TEMP TEMP
	ON (ORI.[AIC] = TEMP.[AIC] AND ORI.[PIC] = TEMP.[PIC])
	WHEN MATCHED 
		 THEN UPDATE SET    
		 ORI.[Name] = TEMP.[Name]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [PIC],[Name])
		 VALUES (TEMP.[AIC],TEMP.[PIC],TEMP.[Name])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
