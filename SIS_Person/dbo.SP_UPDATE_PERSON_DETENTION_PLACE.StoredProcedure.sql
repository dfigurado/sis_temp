USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_DETENTION_PLACE]    Script Date: 7/27/2023 1:22:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[SP_UPDATE_PERSON_DETENTION_PLACE]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[DetentionPlaceCode] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[DateFrom] [datetime] NULL,
		[DateTo] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[DetentionPlaceCode] [nvarchar](max) '$.detentionPlaceCode',
		[Country] [nvarchar](max) '$.country',
		[DateFrom] [datetime] '$.dateFrom',
		[DateTo] [datetime] '$.dateTo'
	) A;


	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [DetentionPlaceCode] IS NULL))
    BEGIN
        DELETE FROM [dbo].[DetentionPlace] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[DetentionPlace] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[DetentionPlaceCode] = TEMP.[DetentionPlaceCode],
		 ORI.[Country] = TEMP.[Country],
		 ORI.[DateFrom] = TEMP.[DateFrom],
		 ORI.[DateTo] = TEMP.[DateTo]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [DetentionPlaceCode], [Country], [DateFrom], [DateTo])
		 VALUES(TEMP.PIC,TEMP.[DetentionPlaceCode],TEMP.[Country],TEMP.[DateFrom],TEMP.[DateTo])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
