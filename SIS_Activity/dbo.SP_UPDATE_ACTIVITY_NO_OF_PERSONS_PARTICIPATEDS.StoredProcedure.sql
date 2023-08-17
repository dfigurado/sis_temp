USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_NO_OF_PERSONS_PARTICIPATEDS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_NO_OF_PERSONS_PARTICIPATEDS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Category] [nvarchar](max) NULL,
		[Date] [datetime] NULL,
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
		[Category] [nvarchar](max) '$.category',
		[Date] [datetime] '$.date',
		[Number] [nvarchar](max) '$.number'
	) A;

	--merge temp with original table
	MERGE [dbo].[NoOfPersonsParticipated] ORI
	USING @TEMP TEMP
	ON (ORI.[AIC] = TEMP.[AIC] AND ORI.[ID] = TEMP.[ID])
	WHEN MATCHED 
		 THEN UPDATE SET    
		 ORI.[Category] = TEMP.[Category],
		 ORI.[Date] = TEMP.[Date],
		 ORI.[Number] = TEMP.[Number]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC],[Category],[Date],[Number])
		 VALUES (TEMP.[AIC],TEMP.[Category],TEMP.[Date],TEMP.[Number])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
