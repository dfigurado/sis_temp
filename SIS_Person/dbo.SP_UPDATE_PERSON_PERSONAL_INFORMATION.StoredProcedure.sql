USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_PERSONAL_INFORMATION]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_PERSON_PERSONAL_INFORMATION]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
--	DECLARE @TEMP TABLE(
--		[PIC] [bigint] NOT NULL,
--		[Initials] [nvarchar](max) NULL,
--		[Surname] [nvarchar](max) NULL,
--		[FirstName] [nvarchar](max) NULL,
--		[SecondName] [nvarchar](max) NULL,
--		[DateOfBirth] [datetime] NULL,
--		[PlaceOfBirth] [nvarchar](max) NULL,
--		[ResidenceCountry] [nvarchar](max) NULL,
--		[Race] [nvarchar](max) NULL,
--		[Religion] [nvarchar](max) NULL,
--		[CivilStatus] [nvarchar](max) NULL,
--		[Sex] [nvarchar](max) NULL,
--		[IdentifyingFeatures] [nvarchar](max) NULL,
--		[FieldOfOperation] [nvarchar](max) NULL,
--		[Weight] [nvarchar](max) NULL,
--		[Height] [nvarchar](max) NULL,
--		[Complexion] [nvarchar](max) NULL,
--		[FingerPrintLocation] [nvarchar](max) NULL,
--		[FingerPrintRefNo] [nvarchar](max) NULL
--	);

--	INSERT INTO @TEMP
--	SELECT * 
--FROM OPENJSON(@JSON)
--WITH  (
--        [PIC] [bigint] '$.pic',
--		[Initials] [nvarchar](max)'$.initials',
--		[Surname] [nvarchar](max)'$.surname',
--		[FirstName] [nvarchar](max)'$.firstName',
--		[SecondName] [nvarchar](max)'$.secondName',
--		[DateOfBirth] [datetime] '$.dateOfBirth',
--		[PlaceOfBirth] [nvarchar](max) '$.placeOfBirth',
--		[ResidenceCountry] [nvarchar](max) '$.residenceCountry',
--		[Race] [nvarchar](max) '$.race',
--		[Religion] [nvarchar](max) '$.religion',
--		[CivilStatus] [nvarchar](max) '$.civilStatus',
--		[Sex] [nvarchar](max) '$.sex',
--		[IdentifyingFeatures] [nvarchar](max) '$.identifyingFeatures',
--		[FieldOfOperation] [nvarchar](max) '$.fieldOfOperation',
--		[Weight] [nvarchar](max) '$.weight',
--		[Height] [nvarchar](max) '$.height',
--		[Complexion] [nvarchar](max) '$.complexion',
--		[FingerPrintLocation] [nvarchar](max) '$.fingerPrintLocation',
--		[FingerPrintRefNo] [nvarchar](max) '$.fingerPrintRefNo'
--    );

--	UPDATE [PersonInformation]
--	SET
--	  Surname = TEMP.Surname,
--	   Initials = TEMP.Initials,
--	  FirstName = TEMP.FirstName,
--	  SecondName = TEMP.SecondName,
--	  DateOfBirth=TEMP.DateOfBirth,
--	  PlaceOfBirth=TEMP.PlaceOfBirth,
--	  ResidenceCountry=TEMP.ResidenceCountry,
--	  Race=TEMP.Race,
--	  Religion=TEMP.Religion,
--	  CivilStatus=TEMP.CivilStatus,
--	  Sex = TEMP.Sex,
--	  IdentifyingFeatures = TEMP.IdentifyingFeatures,
--	  FieldOfOperation=TEMP.FieldOfOperation,
--	  [Weight]=TEMP.[Weight],
--	  [Height]=TEMP.[Height],
--	  Complexion=TEMP.Complexion,
--	  FingerPrintLocation=TEMP.FingerPrintLocation,
--	  FingerPrintRefNo=TEMP.FingerPrintRefNo

--	FROM [dbo].[PersonInformation] ORI
--		 INNER JOIN
--	@TEMP TEMP
--	ON ORI.PIC = TEMP.PIC
--	WHERE  ORI.PIC = TEMP.PIC

--	DELETE FROM @TEMP


	DECLARE @TR_UPDATE_PERSON NVARCHAR(MAX);
DECLARE @PERSONINFORMATION NVARCHAR(MAX);
DECLARE @PHOTOGRAPHS NVARCHAR(MAX);
DECLARE @PHOTOGRAPHSOTHERDETAILS NVARCHAR(MAX);
DECLARE @ALIASES NVARCHAR(MAX);
DECLARE @AKA NVARCHAR(MAX);
DECLARE @NATIONALITY NVARCHAR(MAX);

BEGIN TRANSACTION @TR_UPDATE_PERSON
	SET NOCOUNT ON
	--INSERTING JSON ARRAY TO TEMP TABLE
	IF OBJECT_ID('tempdb..#PARSED') IS NOT NULL
		DROP TABLE #PARSED

	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	--GET THE DATA FROM TEMP TABLE & UPDATING PERSONINFORMATION TABLE
	SET @PERSONINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'personInformation')
	DECLARE @PIC BIGINT = (SELECT PIC FROM OPENJSON(@PERSONINFORMATION) WITH(PIC BIGINT '$.pic'))
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

	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')

	DECLARE @TEMP_Photo TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Path] [nvarchar](max) NULL,
		[AddedDate] [datetime] NULL
	);

	INSERT INTO @TEMP_Photo
	SELECT A.*
	FROM OPENJSON(@PHOTOGRAPHS) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Path] [nvarchar](max) '$.path',
		[AddedDate] [datetime] '$.addedDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT([PIC]) FROM @TEMP_Photo);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_Photo WHERE [Path] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Photographs] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_Photo)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Photographs] ORI
		USING @TEMP_Photo TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[Path] = TEMP.[Path]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([PIC], [Path], [AddedDate])
			 VALUES(TEMP.[PIC],TEMP.[Path],GETDATE())
		WHEN NOT MATCHED BY SOURCE AND ORI.[PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_Photo)
		THEN DELETE;
	END

	--delete temp data
	DELETE FROM @TEMP_Photo;

	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHSOTHERDETAILS TABLE
	SET @PHOTOGRAPHSOTHERDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographsOtherDetails')
	
	DECLARE @TEMP_PhotoDetails TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Place] [nvarchar](max) NULL,
		[ReferenceNumber] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP_PhotoDetails
	SELECT A.*
	FROM OPENJSON(@PHOTOGRAPHSOTHERDETAILS) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Place] [nvarchar](max) '$.place',
		[ReferenceNumber] [nvarchar](max) '$.referenceNumber'
	) A;

	SET @RcowCount = (SELECT COUNT([PIC]) FROM @TEMP_PhotoDetails);

	IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_PhotoDetails WHERE [Place] IS NULL))
    BEGIN
        DELETE FROM [dbo].[PhotographsOtherDetails] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_PhotoDetails)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[PhotographsOtherDetails] ORI
		USING @TEMP_PhotoDetails TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[Place] = TEMP.[Place],
			 ORI.[ReferenceNumber] = TEMP.[ReferenceNumber]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([PIC], [Place], [ReferenceNumber])
			 VALUES(TEMP.[PIC],TEMP.[Place],TEMP.[ReferenceNumber])
		WHEN NOT MATCHED BY SOURCE AND ORI.[PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_PhotoDetails)
		THEN DELETE;
	END
	
	--delete temp data
	DELETE FROM @TEMP_PhotoDetails;

	--GET THE DATA FROM TEMP TABLE & UPDATING ALIASES TABLE
	SET @ALIASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aliases')

	DECLARE @TEMP_ALliases TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Alias] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP_ALliases
	SELECT A.*
	FROM OPENJSON(@ALIASES) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Alias] [nvarchar](max) '$.alias'
	) A;

	SET @RcowCount = (SELECT COUNT([PIC]) FROM @TEMP_ALliases);

	IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_ALliases WHERE [Alias] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Aliases] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_ALliases)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Aliases] ORI
		USING @TEMP_ALliases TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[Alias] = TEMP.[Alias]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([PIC], [Alias],[AddedDate])
			 VALUES(TEMP.[PIC],TEMP.[Alias],GETDATE())
		WHEN NOT MATCHED BY SOURCE AND ORI.[PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_ALliases)
		THEN DELETE;
	END

	--delete temp data
	DELETE FROM @TEMP_ALliases;

	--IHTHI 
	--GET THE DATA FROM TEMP TABLE & UPDATING AKA TABLE
	SET @AKA = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aka')

	DECLARE @TEMP_aka TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[AKA] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP_aka
	SELECT A.*
	FROM OPENJSON(@AKA) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[AKA] [nvarchar](max) '$.aka'
	) A;

	SET @RcowCount = (SELECT COUNT([PIC]) FROM @TEMP_aka);

	IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_aka WHERE [AKA] IS NULL))
    BEGIN
        DELETE FROM [dbo].[AKA] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_aka)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[AKA] ORI
		USING @TEMP_aka TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[AKA] = TEMP.[AKA]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([PIC], [AKA],[AddedDate])
			 VALUES(TEMP.[PIC],TEMP.[AKA],GETDATE())
		WHEN NOT MATCHED BY SOURCE AND ORI.[PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_aka)
		THEN DELETE;
	END

	--delete temp data
	DELETE FROM @TEMP_aka;

	--GET THE DATA FROM TEMP TABLE & UPDATING NATIONALITY TABLE
	SET @NATIONALITY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'nationality')

	DECLARE @TEMP_Nationality TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Nation] [nvarchar](max) NULL,
		[AddedDate] DATE null
	);

	INSERT INTO @TEMP_Nationality
	SELECT A.*
	FROM OPENJSON(@NATIONALITY) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Nation] [nvarchar](max) '$.nation',
		[AddedDate] DATE '$.addedDate'
	) A;

	SET @RcowCount = (SELECT COUNT([PIC]) FROM @TEMP_Nationality);

	IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_Nationality WHERE [Nation] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Nationality] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_Nationality)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Nationality] ORI
		USING @TEMP_Nationality TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[Nation] = TEMP.[Nation],
			 ORI.[AddedDate] = getdate()
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([PIC], [Nation],[AddedDate])
			 VALUES(TEMP.[PIC],TEMP.[Nation],getdate())
		WHEN NOT MATCHED BY SOURCE AND ORI.[PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_Nationality)
		THEN DELETE;
	END
	
	--delete temp data
	DELETE FROM @TEMP_Nationality;

	-- EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @PIC;

	DROP TABLE #PARSED
COMMIT TRANSACTION @TR_UPDATE_PERSON
END

GO
