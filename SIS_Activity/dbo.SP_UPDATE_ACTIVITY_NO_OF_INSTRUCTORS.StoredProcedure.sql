USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_NO_OF_INSTRUCTORS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_NO_OF_INSTRUCTORS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Country] [nvarchar](max) NULL,
		[Number] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[Country] [nvarchar](max) '$.country',
		[Number] [nvarchar](max) '$.number'
	) A;

	--merge temp with original table
	MERGE [dbo].[NoOfInstructors] ORI
	USING @TEMP TEMP
	ON (ORI.[ID] = TEMP.[ID] AND ORI.[AIC] = TEMP.[AIC])
	WHEN MATCHED 
		 THEN UPDATE
		 SET    ORI.[Country] = TEMP.[Country],
		        ORI.[Number] = TEMP.[Number]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [Country],[Number])
		 VALUES (TEMP.[AIC],TEMP.[Country],TEMP.[Number])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
