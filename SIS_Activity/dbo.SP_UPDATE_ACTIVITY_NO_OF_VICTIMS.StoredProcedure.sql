USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_NO_OF_VICTIMS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_NO_OF_VICTIMS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[Category] [nvarchar](max) NULL,
		[Race] [nvarchar](max) NULL,
		[Status] [nvarchar](max) NULL,
		[Number] [nvarchar](max) NULL,
		[Organization] [nvarchar](max) NULL
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
		[Race] [nvarchar](max) '$.race',
		[Status] [nvarchar](max) '$.status',
		[Number] [nvarchar](max) '$.number',
		[Organization] [nvarchar](max) '$.organization'
	) A;

	--merge temp with original table
	MERGE [dbo].[NoOfVictims] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.AIC = TEMP.AIC)
	WHEN MATCHED 
		 THEN UPDATE SET 
		 ORI.[Category] = TEMP.[Category],
		 ORI.[Race] = TEMP.[Race],
		 ORI.[Status] = TEMP.[Status],
		 ORI.[Number] = TEMP.[Number],
		 ORI.[Organization] = TEMP.[Organization]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [Category],[Race],[Status],[Number],[Organization])
		 VALUES (TEMP.[AIC],TEMP.[Category],TEMP.[Race],TEMP.[Status],TEMP.[Number],TEMP.[Organization])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
