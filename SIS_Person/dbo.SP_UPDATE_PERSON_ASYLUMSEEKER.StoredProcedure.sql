USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_ASYLUMSEEKER]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_ASYLUMSEEKER]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_AS TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[SeekingCountry] [nvarchar](max) NULL,
		[DateOfSeekingFrom] [datetime] NULL,
		[DateOfSeekingTo] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_AS
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   ASK nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.ASK) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[SeekingCountry] [nvarchar](max) '$.seekingCountry',
		[DateOfSeekingFrom] [datetime] '$.dateOfSeekingFrom',
		[DateOfSeekingTo] [datetime] '$.dateOfSeekingTo'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_AS);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_AS WHERE [SeekingCountry] IS NULL))
    BEGIN
        DELETE FROM [dbo].[AsylumSeeker] WHERE PIC = (SELECT TOP 1 [PIC] FROM @TEMP_AS)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[AsylumSeeker] ORI
	USING @TEMP_AS TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[SeekingCountry] = TEMP.[SeekingCountry],
		 ORI.[DateOfSeekingFrom] = TEMP.[DateOfSeekingFrom],
		 ORI.[DateOfSeekingTo] = TEMP.[DateOfSeekingTo]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [SeekingCountry], [DateOfSeekingFrom], [DateOfSeekingTo])
		 VALUES(TEMP.PIC,TEMP.[SeekingCountry],TEMP.[DateOfSeekingFrom],TEMP.[DateOfSeekingTo])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_AS)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_AS
END
GO
