USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_VICTIMS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_DETAILS_OF_VICTIMS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Name] [nvarchar](max) NULL,
		[Category] [nvarchar](max) NULL,
		[Race] [nvarchar](max) NULL,
		[Rank] [nvarchar](max) NULL,
		[NativePlace] [nvarchar](max) NULL,
		[Status] [nvarchar](max) NULL,
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
		[PIC] [bigint] '$.pic',
		[Name] [nvarchar](max) '$.name',
		[Category] [nvarchar](max) '$.category',
		[Race] [nvarchar](max) '$.race',
		[Rank] [nvarchar](max) '$.rank',
		[NativePlace] [nvarchar](max) '$.nativePlace',
		[Status] [nvarchar](max) '$.status',
		[Organization] [nvarchar](max) '$.organization'
	) A;

	--merge temp with original table
	MERGE [dbo].[DetailsOfVictims] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.AIC = TEMP.AIC AND ORI.[PIC] = TEMP.[PIC])
	WHEN MATCHED 
		 THEN UPDATE SET 
		 ORI.[AIC] = TEMP.[AIC],
		 ORI.[PIC] = TEMP.[PIC],
		 ORI.[Name] = TEMP.[Name],
		 ORI.[Category] = TEMP.[Category],
		 ORI.[Race] = TEMP.[Race],
		 ORI.[Rank] = TEMP.[Rank],
		 ORI.[NativePlace] = TEMP.[NativePlace],
		 ORI.[Status] = TEMP.[Status],
		 ORI.[Organization] = TEMP.[Organization]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [PIC],[Name],[Category],[Race],[Rank],[NativePlace],[Status],[Organization])
		 VALUES (TEMP.[AIC],TEMP.[PIC],TEMP.[Name],TEMP.[Category],TEMP.[Race],TEMP.[Rank],TEMP.[NativePlace],TEMP.[Status],TEMP.[Organization])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
