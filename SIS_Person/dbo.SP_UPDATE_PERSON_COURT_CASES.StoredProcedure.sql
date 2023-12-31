USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_COURT_CASES]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_COURT_CASES]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_CC TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[CourtType] [nvarchar](max) NULL,
		[CourtCaseNo] [nvarchar](max) NULL,
		[Court] [nvarchar](max) NULL,
		[Charge] [nvarchar](max) NULL,
		[Date] [datetime] NULL,
		[PlaceOfDetention] [nvarchar](max) NULL,
		[PrisonNumber] [nvarchar](max) NULL,
		[Absconded] [nvarchar](max) NULL,
		[GazetteReference] [nvarchar](max) NULL,
		[AIC] [bigint] NULL,
		[Verdict] [nvarchar](max) NULL,
		[DescriptionOfOffence] [nvarchar](max) NULL,
		[VerdictDate] [datetime] NULL,
		[NextHearingDate] [datetime] NULL,
		[FileReferenceNo] [nvarchar](max) NULL,
		[CourtCaseNumber] [nvarchar](max) NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CC
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[CourtType] [nvarchar](max) '$.courtType',
		[CourtCaseNo] [nvarchar](max) '$.courtCaseNo',
		[Court] [nvarchar](max) '$.court',
		[Charge] [nvarchar](max) '$.charge',
		[Date] [datetime] '$.date',
		[PlaceOfDetention] [nvarchar](max) '$.placeOfDetention',
		[PrisonNumber] [nvarchar](max) '$.prisonNumber',
		[Absconded] [nvarchar](max) '$.absconded',
		[GazetteReference] [nvarchar](max) '$.gazetteReference',
		[AIC] [bigint] '$.aic',
		[Verdict] [nvarchar](max) '$.verdict',
		[DescriptionOfOffence] [nvarchar](max) '$.descriptionOfOffence',
		[VerdictDate] [datetime] '$.verdictDate',
		[NextHearingDate] [datetime] '$.nextHearingDate',
		[FileReferenceNo] [nvarchar](max) '$.fileReferenceNo',
		[CourtCaseNumber] [nvarchar](max) '$.courtCaseNo'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_CC);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_CC WHERE [CourtType] IS NULL))
    BEGIN
        DELETE FROM [dbo].[CourtCases] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_CC)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[CourtCases] ORI
	USING @TEMP_CC TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[CourtType] = TEMP.[CourtType],
		 ORI.[CourtCaseNo] = TEMP.[CourtCaseNo],
		 ORI.[Court] = TEMP.[Court],
		 ORI.[Charge] = TEMP.[Charge],
		 ORI.[Date] = TEMP.[Date],
		 ORI.[PlaceOfDetention] = TEMP.[PlaceOfDetention],
		 ORI.[PrisonNumber] = TEMP.[PrisonNumber],
		 ORI.[Absconded] = TEMP.[Absconded],
		 ORI.[GazetteReference] = TEMP.[GazetteReference],
		 ORI.[AIC] = TEMP.[AIC],
		 ORI.[Verdict] = TEMP.[Verdict],
		 ORI.[DescriptionOfOffence] = TEMP.[DescriptionOfOffence],
		 ORI.[VerdictDate] = TEMP.[VerdictDate],
		 ORI.[NextHearingDate] = TEMP.[NextHearingDate],
		 ORI.[FileReferenceNo] = TEMP.[FileReferenceNo],
		 ORI.[CourtCaseNumber] = TEMP.[CourtCaseNumber]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [CourtType], [CourtCaseNo], [Court], [Charge], [Date], [PlaceOfDetention], [PrisonNumber], [Absconded], [GazetteReference], [AIC], [Verdict], [DescriptionOfOffence], [VerdictDate], [NextHearingDate], [FileReferenceNo], [CourtCaseNumber])
		 VALUES(TEMP.PIC,TEMP.[CourtType],TEMP.[CourtCaseNo],TEMP.[Court],TEMP.[Charge],TEMP.[Date],TEMP.[PlaceOfDetention],TEMP.[PrisonNumber],TEMP.[Absconded],TEMP.[GazetteReference],TEMP.[AIC],TEMP.[Verdict],TEMP.[DescriptionOfOffence],TEMP.[VerdictDate],TEMP.[NextHearingDate],TEMP.[FileReferenceNo],TEMP.[CourtCaseNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CC)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_CC
END
GO
