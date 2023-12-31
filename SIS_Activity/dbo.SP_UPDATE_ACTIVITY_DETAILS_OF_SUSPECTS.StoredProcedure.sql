USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_SUSPECTS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_SUSPECTS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[PIC] [bigint]  NULL,
		[Status] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[PIC] [bigint] '$.pic',
		[Status] [nvarchar](max) '$.status'
	) A;

	--merge temp with original table
	MERGE [dbo].[DetailOfSuspect] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.AIC = TEMP.AIC)
	WHEN MATCHED 
		 THEN UPDATE SET 
		 ORI.[Status] = TEMP.[Status]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [PIC],[Status])
		 VALUES (TEMP.[AIC],TEMP.[PIC],TEMP.[Status])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
