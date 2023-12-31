USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_INSTRUCTORS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_INSTRUCTORS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Country] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[AIC] [bigint] '$.aic',
		[PIC] [bigint] '$.pic',
		[Country] [nvarchar](max) '$.country'
	) A;

	--merge temp with original table
	MERGE [dbo].[DetailsOfInstructors] ORI
	USING @TEMP TEMP
	ON (ORI.[PIC] = TEMP.[PIC] AND ORI.[AIC] = TEMP.[AIC])
	WHEN MATCHED 
		 THEN UPDATE
		 SET    ORI.[Country] = TEMP.[Country]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [PIC],[Country])
		 VALUES (TEMP.[AIC],TEMP.[PIC],TEMP.[Country])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
