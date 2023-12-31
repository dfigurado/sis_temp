USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_PRESIDED_OVER_BYS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_PRESIDED_OVER_BYS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[PIC] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[AIC] [bigint] '$.aic',
		[PIC] [bigint] '$.pic'
	) A;

	--merge temp with original table
	MERGE [dbo].[PresidedOverBy] ORI
	USING @TEMP TEMP
	ON (ORI.[AIC] = TEMP.[AIC] AND ORI.[PIC] = TEMP.[PIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [PIC])
		 VALUES (TEMP.[AIC],TEMP.[PIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
