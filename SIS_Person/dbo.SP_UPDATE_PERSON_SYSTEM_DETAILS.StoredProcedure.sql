USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_SYSTEM_DETAILS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_SYSTEM_DETAILS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	----declared a temp table
	--DECLARE @TEMP TABLE(
	--	[PIC] [bigint] NULL,
	--	[LastModifiedUserName] [nvarchar](max) NULL,
	--	[Desk] [bigint] NULL,
	--	[Subject] [nvarchar](max) NULL
	--);

	----insert to the temp table
	--INSERT INTO @TEMP
	--SELECT A.*
	--FROM OPENJSON(@JSON) WITH (
	--   CC nvarchar(max) '$' AS JSON
	--) AS i
	--CROSS APPLY OPENJSON(i.CC) WITH (
	--	[PIC] [bigint] '$.pic',
	--	[LastModifiedUserName] [nvarchar](max) '$.lastModifiedUserName',
	--	[Desk] [bigint] '$.deskId',
	--	[Subject] [nvarchar](max) '$.subjectId'
	--) A;

	----Update target date
	--UPDATE [SystemDetails]
	--SET
	--  [LastModifiedUserName] = TEMP.[LastModifiedUserName],
	--  [LastModifiedDate] = GETDATE(),
	--  [Desk] = TEMP.[Desk],
	--  [Subject] = TEMP.[Subject]

	--FROM [dbo].[SystemDetails] ORI
	--	 INNER JOIN
	--@TEMP TEMP
	--ON ORI.PIC = TEMP.PIC
	--WHERE  ORI.PIC = TEMP.PIC

	----delete temp data
	--DELETE FROM @TEMP;

	DECLARE @TR_UPDATE_PERSON NVARCHAR(MAX)
DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
DECLARE @SECURITYCLASSIFICATIONS NVARCHAR(MAX)
DECLARE @CARDINGDETAILS NVARCHAR(MAX)
DECLARE @CURRENTSTATUS NVARCHAR(MAX)
DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
DECLARE @PERSONINFORMATION NVARCHAR(MAX);
BEGIN TRANSACTION @TR_UPDATE_PERSON
	SET NOCOUNT ON
	--INSERTING JSON ARRAY TO TEMP TABLE
	IF OBJECT_ID('tempdb..#PARSED') IS NOT NULL
		DROP TABLE #PARSED

	SELECT * INTO #PARSED FROM OPENJSON(@JSON)


--GET THE DATA FROM TEMP TABLE & UPDATING SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	DECLARE @PIC BIGINT = (SELECT [value] FROM OPENJSON(@SYSTEMDETAILS) where [key] = 'pic')
	
	UPDATE ORI
	SET 
		ORI.LastModifiedUserName = TEMP.LastModifiedUserName,
		ORI.LastModifiedDate = getdate(),
		ORI.Desk = TEMP.Desk,
		ORI.[Subject]= TEMP.[Subject]
		
	FROM [dbo].[SystemDetails] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@SYSTEMDETAILS)
	WITH(
		PIC BIGINT '$.pic',
		LastModifiedUserName NVARCHAR(MAX) '$.lastModifiedUserName',
		LastModifiedDate DATE '$.lastModifiedDate',
		Desk BIGINT '$.deskId',
		[Subject] NVARCHAR(MAX) '$.subjectId'
	)) TEMP
	ON ORI.PIC = @PIC
	WHERE ORI.PIC = @PIC

--GET THE DATA FROM TEMP TABLE & UPDATING SECURITYCLASSIFICATIONS TABLE
	SET @SECURITYCLASSIFICATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'securityClassifications')

	DECLARE @TEMP_SC TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[SecurityClassification] [nvarchar](max) NULL,
		[RelatedCountry] [nvarchar](max) NULL,
		[DateFrom] [date] NULL,
		[DateTo] [date] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_SC
	SELECT A.*
	FROM OPENJSON(@SECURITYCLASSIFICATIONS) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[SecurityClassification] [nvarchar](max) '$.securityClassification',
		[RelatedCountry] [nvarchar](max) '$.relatedCountry',
		[DateFrom] [date] '$.dateFrom',
		[DateTo] [date] '$.dateTo'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_SC);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_SC WHERE [SecurityClassification] IS NULL))
    BEGIN
        DELETE FROM [dbo].[SecurityClassifications] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_SC)
    END
	ELSE
	BEGIN

		MERGE [dbo].[SecurityClassifications] ORI
		USING @TEMP_SC TEMP
		ON ORI.ID = TEMP.ID

		WHEN MATCHED
		THEN UPDATE
			SET
			 ORI.SecurityClassification=TEMP.SecurityClassification,
			 ORI.RelatedCountry = TEMP.RelatedCountry,
			 ORI.DateFrom = TEMP.DateFrom,
			 ORI.DateTo = TEMP.DateTo

		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([PIC], [SecurityClassification], [RelatedCountry], [DateFrom], [DateTo])
			 VALUES(@PIC,TEMP.SecurityClassification,TEMP.RelatedCountry,TEMP.DateFrom,TEMP.DateTo)
		WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_SC)
		THEN DELETE;
	END

	DELETE FROM @TEMP_SC

	--GET THE DATA FROM TEMP TABLE & UPDATING CARDINGDETAILS TABLE
	SET @CARDINGDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'cardingDetails')

	DECLARE @TEMP_CD TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Reason] [nvarchar](max) NULL,
		[CardingDate] [date] NULL,
		[AddedDate] [date] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CD
	SELECT A.*
	FROM OPENJSON(@CARDINGDETAILS) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Reason] [nvarchar](max) '$.reason',
		[CardingDate] [date] '$.cardingDate',
		[AddedDate] [date] '$.addedDate'
	) A;

	SET @RcowCount = (SELECT COUNT(PIC) FROM @TEMP_CD);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_CD WHERE [Reason] IS NULL))
    BEGIN
        DELETE FROM [dbo].[CardingDetails] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_CD)
    END
	ELSE
	BEGIN

		MERGE [dbo].[CardingDetails] ORI
		USING @TEMP_CD TEMP
		ON ORI.ID = TEMP.ID

		WHEN MATCHED
		THEN UPDATE
			SET
			 ORI.PIC = TEMP.PIC,
			 ORI.Reason = TEMP.Reason,
			 ORI.CardingDate = TEMP.CardingDate,
			 ORI.AddedDate = TEMP.AddedDate
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([PIC], [Reason], [CardingDate], [AddedDate]) VALUES(@PIC,TEMP.Reason,TEMP.CardingDate,GETDATE())
		WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CD)
		THEN DELETE;

	END

	DELETE FROM @TEMP_CD;

	--GET THE DATA FROM TEMP TABLE & UPDATING ASYLUMSEEKER TABLE
	SET @CURRENTSTATUS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'currentStatus')

	DECLARE @TEMP_CS TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Status] [nvarchar](max) NULL,
		[FromDate] [date] NULL,
		[ToDate] [date] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CS
	SELECT A.*
	FROM OPENJSON(@CURRENTSTATUS) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Status] [nvarchar](max) '$.status',
		[FromDate] [date] '$.fromDate',
		[ToDate] [date] '$.toDate'
	) A;

	SET @RcowCount = (SELECT COUNT(PIC) FROM @TEMP_CS);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_CS WHERE [Status] IS NULL))
    BEGIN
        DELETE FROM [dbo].[CurrentStatus] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_CS)
    END
	ELSE
	BEGIN

		MERGE [dbo].[CurrentStatus] ORI
		USING @TEMP_CS TEMP
		ON ORI.ID = TEMP.ID AND ORI.[Status] = TEMP.[Status] AND ORI.FromDate  = TEMP.FromDate AND ORI.ToDate = TEMP.ToDate

		WHEN MATCHED
		THEN UPDATE
			SET
			 ORI.PIC = TEMP.PIC,
			 ORI.[Status] = TEMP.[Status],
			 ORI.FromDate = TEMP.FromDate,
			 ORI.ToDate = TEMP.ToDate
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([PIC], [Status], [FromDate], [ToDate]) VALUES(@PIC,TEMP.[Status],TEMP.FromDate,TEMP.ToDate)
		WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CS)
		THEN DELETE;

	END

	DELETE FROM @TEMP_CS;


	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')


	MERGE [DirectAndRoleWiseAccessRestrictions] T
	USING (SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
					WITH(
								PIC BIGINT '$.pic',
								DirectorOnly bit '$.directorOnly',
								DeskOfficerOnly bit '$.deskOfficerOnly')
		 )  S
	ON   (S.PIC = T.PIC)
	

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.DirectorOnly = S.DirectorOnly,
				T.DeskOfficerOnly = S.DeskOfficerOnly
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (PIC,DirectorOnly,DeskOfficerOnly)
		 VALUES (@PIC,S.DirectorOnly,S.DeskOfficerOnly)
	WHEN NOT MATCHED BY SOURCE  AND PIC = @PIC
	THEN DELETE;

	--PERSONAL INFORMATION
	SET @PERSONINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'personInformation')
	UPDATE ORI
	SET
	  ORI.Surname = TEMP.Surname,
	  ORI. Initials = TEMP.Initials,
	  ORI.FirstName = TEMP.FirstName,
	  ORI.SecondName = TEMP.SecondName,
	  ORI.DateOfBirth=TEMP.DateOfBirth,
	  ORI.PlaceOfBirth=TEMP.PlaceOfBirth,
	  ORI.ResidenceCountry=TEMP.ResidenceCountry,
	  ORI.Race=TEMP.Race,
	  ORI.Religion=TEMP.Religion,
	  ORI.CivilStatus=TEMP.CivilStatus,
	  ORI.Sex = TEMP.Sex,
	  ORI.IdentifyingFeatures = TEMP.IdentifyingFeatures,
	  ORI.FieldOfOperation=TEMP.FieldOfOperation,
	  ORI.[Weight]=TEMP.[Weight],
	  ORI.[Height]=TEMP.[Height],
	  ORI.Complexion=TEMP.Complexion,
	  ORI.FingerPrintLocation=TEMP.FingerPrintLocation,
	  ORI.FingerPrintRefNo=TEMP.FingerPrintRefNo

	FROM [dbo].[PersonInformation] ORI
		 INNER JOIN

	(SELECT * FROM OPENJSON(@PERSONINFORMATION)
	WITH(
		PIC BIGINT '$.pic',
		Surname NVARCHAR(MAX) '$.surname',
		Initials NVARCHAR(MAX) '$.initials',
		FirstName NVARCHAR(MAX) '$.firstName',
		SecondName NVARCHAR(MAX) '$.secondName',
		DateOfBirth DATETIME '$.dateOfBirth',
		PlaceOfBirth NVARCHAR(MAX) '$.placeOfBirth',
		ResidenceCountry NVARCHAR(MAX) '$.residenceCountry',
		Race NVARCHAR(MAX) '$.race',
		Religion NVARCHAR(MAX) '$.religion',
		CivilStatus NVARCHAR(MAX) '$.civilStatus',
		Sex NVARCHAR(MAX) '$.sex',
		IdentifyingFeatures NVARCHAR(MAX) '$.identifyingFeatures',
		FieldOfOperation NVARCHAR(MAX) '$.fieldOfOperation',
		[Weight] NVARCHAR(MAX) '$.weight',
		[Height] NVARCHAR(MAX) '$.height',
		Complexion NVARCHAR(MAX) '$.complexion',
		FingerPrintLocation NVARCHAR(MAX) '$.fingerPrintLocation',
		FingerPrintRefNo NVARCHAR(MAX) '$.fingerPrintRefNo'
		
	)) TEMP
	ON ORI.PIC = TEMP.PIC
	WHERE  ORI.PIC = TEMP.PIC;

	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @PIC

	DROP TABLE #PARSED
COMMIT TRANSACTION @TR_UPDATE_PERSON


END

GO
