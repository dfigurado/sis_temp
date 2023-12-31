USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_IDENTIFICATION]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_IDENTIFICATION]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Type] [nvarchar](max) NULL,
		[IdNumber] [nvarchar](max) NULL,
		[DateOfIssue] [nvarchar](max) NULL,
		[DateOfExpiry] [nvarchar](max) NULL,
		[PlaceOfIssue] [nvarchar](max) NULL,
		[CountryOfIssue] [nvarchar](max) NULL,
		[Authenticity] [nvarchar](max) NULL,
		[Validity] [nvarchar](max) NULL
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
		[Type] [nvarchar](max) '$.type',
		[IdNumber] [nvarchar](max) '$.idNumber',
		[DateOfIssue] [nvarchar](max) '$.dateOfIssue',
		[DateOfExpiry] [nvarchar](max) '$.dateOfExpiry',
		[PlaceOfIssue] [nvarchar](max) '$.placeOfIssue',
		[CountryOfIssue] [nvarchar](max) '$.countryOfIssue',
		[Authenticity] [nvarchar](max) '$.authenticity',
		[Validity] [nvarchar](max) '$.validity'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [Type] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Identification] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN

	--merge temp with original table
	MERGE [dbo].[Identification] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Type] = TEMP.[Type],
		 ORI.[IdNumber] = TEMP.[IdNumber],
		 ORI.[DateOfIssue] = TEMP.[DateOfIssue],
		 ORI.[DateOfExpiry] = TEMP.[DateOfExpiry],
		 ORI.[PlaceOfIssue] = TEMP.[PlaceOfIssue],
		 ORI.[CountryOfIssue] = TEMP.[CountryOfIssue],
		 ORI.[Authenticity] = TEMP.[Authenticity],
		 ORI.[Validity] = TEMP.[Validity]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Type], [IdNumber], [DateOfIssue], [DateOfExpiry], [PlaceOfIssue], [CountryOfIssue], [Authenticity], [Validity], [AddedDate])
		 VALUES(TEMP.PIC,TEMP.[Type],TEMP.[IdNumber],TEMP.[DateOfIssue],TEMP.[DateOfExpiry],TEMP.[PlaceOfIssue],TEMP.[CountryOfIssue],TEMP.[Authenticity],TEMP.[Validity],GETDATE())
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
