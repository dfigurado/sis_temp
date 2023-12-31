USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_PERSON]    Script Date: 7/27/2023 1:21:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[CREATE_PERSON](@JSON NVARCHAR(MAX))
AS
BEGIN

	--START -> DECLARING VARIABLES
	DECLARE @TR_CREATE_PERSON NVARCHAR(MAX)
	DECLARE @ADDRESS NVARCHAR(MAX)
	DECLARE @ALIASES NVARCHAR(MAX)
	DECLARE @Aka NVARCHAR(MAX)
	DECLARE @ALLTRAVELPARTICULARS NVARCHAR(MAX)
	DECLARE @ASYLUMSEEKER NVARCHAR(MAX)
	DECLARE @CARDINGDETAILS NVARCHAR(MAX)
	DECLARE @CONVEYANCES NVARCHAR(MAX)
	DECLARE @COURTCASES NVARCHAR(MAX)
	DECLARE @CURRENTSTATUS NVARCHAR(MAX)
	DECLARE @DETENTIONPLACE NVARCHAR(MAX)
	DECLARE @EDUCATION NVARCHAR(MAX)
	DECLARE @FILEREFERENCES NVARCHAR(MAX)
	DECLARE @IDENTIFICATION NVARCHAR(MAX)
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)
	DECLARE @NATIONALITY NVARCHAR(MAX)
	DECLARE @OCCUPATIONS NVARCHAR(MAX)
	DECLARE @ORGANIZATIONS NVARCHAR(MAX)
	DECLARE @PERSONINFORMATION NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHSOTHERDETAILS NVARCHAR(MAX)
	DECLARE @RELATIVES NVARCHAR(MAX)
	DECLARE @REALTEDACTIVITIES NVARCHAR(MAX)
	DECLARE @RELATEDITEMS NVARCHAR(MAX)
	DECLARE @SECURITYCLASSIFICATIONS NVARCHAR(MAX)
	DECLARE @SOCIALMEDIA NVARCHAR(MAX)
	DECLARE @SPECIALPECULIARITIES NVARCHAR(MAX)
	DECLARE @SPECIALSKILLS NVARCHAR(MAX)
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
	DECLARE @TRAVELINFORMATION NVARCHAR(MAX)
	DECLARE @WEAKNESSES NVARCHAR(MAX)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	DECLARE @PIC BIGINT
	DECLARE @PERSON TABLE (ID BIGINT)
	--END -> DECLARING VARIABLES


BEGIN TRY  
    BEGIN TRANSACTION;  

	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO PERSONALINFORMATION TABLE
	SET @PERSONINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'personInformation')
	INSERT INTO [dbo].[PersonInformation](Surname,Initials, FirstName, SecondName, DateOfBirth, PlaceOfBirth, ResidenceCountry, Race, Religion, CivilStatus, Sex, IdentifyingFeatures, FieldOfOperation, Weight, Height, Complexion, FingerPrintLocation, FingerPrintRefNo)
	OUTPUT INSERTED.PIC INTO @PERSON
	SELECT * FROM OPENJSON(@PERSONINFORMATION)
	WITH(
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
		Weight NVARCHAR(MAX) '$.weight',
		Height NVARCHAR(MAX) '$.height',
		Complexion NVARCHAR(MAX) '$.complexion',
		FingerPrintLocation NVARCHAR(MAX) '$.fingerPrintLocation',
		FingerPrintRefNo NVARCHAR(MAX) '$.fingerPrintRefNo'
	)

	SET @PIC = (SELECT TOP 1 ID FROM @PERSON)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ADDRESS TABLE
	SET @ADDRESS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'addresses')
	INSERT INTO [dbo].[Addresses](PIC,AddedDate, [Address], [From], [To], [Type], Mobile, Telephone, Country, PoliceStation)
	SELECT @PIC,getdate(),* FROM OPENJSON(@ADDRESS)
	WITH(
		[Address] NVARCHAR(MAX) '$.address',
		[From] DATETIME '$.from',
		[To] DATETIME '$.to',
		[Type] NVARCHAR(MAX) '$.type',
		Mobile NVARCHAR(MAX) '$.mobile',
		Telephone NVARCHAR(MAX) '$.telephone',
		Country NVARCHAR(MAX) '$.country',
		PoliceStation NVARCHAR(MAX) '$.policeStation'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ALIASES TABLE
	SET @ALIASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aliases')
	INSERT INTO [dbo].[Aliases](PIC,AddedDate, Alias)
	SELECT @PIC,getdate(),* FROM OPENJSON(@ALIASES)
	WITH(
		Alias NVARCHAR(MAX) '$.alias'
	)

    --GET THE DATA FROM TEMP TABLE & INSERTING TO AKA TABLE
	SET @Aka = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aka')
	INSERT INTO [dbo].[AKA](PIC,AddedDate, AKA)
	SELECT @PIC,getdate(),* FROM OPENJSON(@aka)
	WITH(
		aka NVARCHAR(MAX) '$.aka'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ALLTRAVELPARTICULARS TABLE
	SET @ALLTRAVELPARTICULARS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'allTravelParticulars')
	INSERT INTO [dbo].[AllTravelParticulars](PIC, [FlightNo],CountryOfOrigin, PortOfOrigin, CountryOfDestination, PortOfDestination, PurposeOfVisit, [PurposeInDetails], ArrivalDate, DepartureDate)
	SELECT @PIC,* FROM OPENJSON(@ALLTRAVELPARTICULARS)
	WITH(
		[FlightNo] NVARCHAR(MAX) '$.flightNo',
		CountryOfOrigin NVARCHAR(MAX) '$.countryOfOrigin',
		PortOfOrigin NVARCHAR(MAX) '$.portOfOrigin',
		CountryOfDestination NVARCHAR(MAX) '$.countryOfDestination',
		PortOfDestination NVARCHAR(MAX) '$.portOfDestination',
		PurposeOfVisit NVARCHAR(MAX) '$.purposeOfVisit',
		[PurposeInDetails] NVARCHAR(MAX) '$.purposeInDetails',
		ArrivalDate DATETIME '$.arrivalDate',
		DepartureDate DATETIME '$.departureDate'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ASYLUMSEEKER TABLE
	SET @ASYLUMSEEKER = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'asylumSeeker')
	INSERT INTO [dbo].[AsylumSeeker](PIC, [SeekingCountry], DateOfSeekingFrom,DateOfSeekingTo)
	SELECT @PIC,* FROM OPENJSON(@ASYLUMSEEKER)
	WITH(
		[SeekingCountry] NVARCHAR(MAX) '$.seekingCountry',
		DateOfSeekingFrom DATETIME '$.dateOfSeekingFrom',
		DateOfSeekingTo DATETIME '$.dateOfSeekingTo'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO CARDINGDETAILS TABLE
	SET @CARDINGDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'cardingDetails')
	INSERT INTO [dbo].[CardingDetails](PIC, [AddedDate], Reason, CardingDate)
	SELECT @PIC,getdate(),* FROM OPENJSON(@CARDINGDETAILS)
	WITH(
		Reason NVARCHAR(MAX) '$.reason',
		CardingDate DATETIME '$.cardingDate'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO CONVEYANCES TABLE
	SET @CONVEYANCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'conveyances')
	INSERT INTO [dbo].[Conveyances](PIC, IIC, IdentifyingFeature)
	SELECT @PIC,* FROM OPENJSON(@CONVEYANCES)
	WITH(
		IIC NVARCHAR(MAX) '$.iic',
		IdentifyingFeature NVARCHAR(MAX) '$.identifyingFeature'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO COURTCASES TABLE
	SET @COURTCASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'courtCases')
	INSERT INTO [dbo].[CourtCases](PIC, Charge, [Date],[VerdictDate],PlaceOfDetention, Absconded, GazetteReference, AIC,CourtCaseNo, Court, Verdict,DescriptionOfOffence,CourtType,NextHearingDate,FileReferenceNo)
	SELECT @PIC,* FROM OPENJSON(@COURTCASES)
	WITH(
		Charge NVARCHAR(MAX) '$.charge',
		[Date] DATETIME '$.date',
		[VerdictDate] DATETIME '$.verdictDate',
		PlaceOfDetention NVARCHAR(MAX) '$.placeOfDetention',
		Absconded NVARCHAR(MAX) '$.absconded',
		GazetteReference NVARCHAR(MAX) '$.gazetteReference',
		AIC BIGINT '$.aic',
		CourtCaseNo NVARCHAR(MAX) '$.courtCaseNo',
		Court NVARCHAR(MAX) '$.court',
		Verdict NVARCHAR(MAX) '$.verdict',
		DescriptionOfOffence NVARCHAR(MAX) '$.descriptionOfOffence',
		CourtType NVARCHAR(MAX) '$.courtType',
		NextHearingDate DATETIME '$.nextHearingDate',
		FileReferenceNo NVARCHAR(MAX) '$.fileReferenceNo'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO CURRENTSTATUS TABLE
	SET @CURRENTSTATUS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'currentStatus')
	INSERT INTO [dbo].[CurrentStatus](PIC, [Status], [FromDate], [ToDate])
	SELECT @PIC,* FROM OPENJSON(@CURRENTSTATUS)
	WITH(
		[Status] NVARCHAR(MAX) '$.status',
		[FromDate] DATETIME '$.fromDate',
		[ToDate] DATETIME '$.toDate'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO DETENTIONPLACE TABLE
	SET @DETENTIONPLACE = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detentionPlace')
	INSERT INTO [dbo].[DetentionPlace]([PIC], [DetentionPlaceCode], [Country], [DateFrom], [DateTo])
	SELECT @PIC,* FROM OPENJSON(@DETENTIONPLACE)
	WITH(
		[DetentionPlaceCode] NVARCHAR(MAX) '$.detentionPlaceCode',
		[Country] nvarchar(max) '$.country',
		[DateFrom] DATETIME '$.dateFrom',
		[DateTo] DATETIME '$.dateTo'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO EDUCATION TABLE
	SET @EDUCATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'education')
	INSERT INTO [dbo].[Education](PIC, CollageName, CollageType, Course, Country, [From], [To], EducationLevel,Place)
	SELECT @PIC,* FROM OPENJSON(@EDUCATION)
	WITH(
		CollageName NVARCHAR(MAX) '$.collageName',
		CollageType NVARCHAR(MAX) '$.collageType',
		Course NVARCHAR(MAX) '$.course',
		Country NVARCHAR(MAX) '$.country',
		[From] DATETIME '$.from',
		[To] DATETIME '$.to',
		EducationLevel NVARCHAR(MAX) '$.educationLevel',
		Place NVARCHAR(MAX) '$.place'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO FILEREFERENCES TABLE
	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')
	INSERT INTO [dbo].[FileReferences](PIC, FileReference, FileType)
	SELECT @PIC,* FROM OPENJSON(@FILEREFERENCES)
	WITH(
		FileReference NVARCHAR(MAX) '$.fileReference',
		FileType NVARCHAR(MAX) '$.fileType'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO IDENTIFICATION TABLE
	SET @IDENTIFICATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'identification')
	INSERT INTO [dbo].[Identification](PIC,AddedDate, [Type], IdNumber, DateOfIssue, DateOfExpiry, PlaceOfIssue, CountryOfIssue, Authenticity, Validity)
	SELECT @PIC,GETDATE(),* FROM OPENJSON(@IDENTIFICATION)
	WITH(
		[Type] NVARCHAR(MAX) '$.type',
		IdNumber NVARCHAR(MAX) '$.idNumber',
		DateOfIssue DATETIME '$.dateOfIssue',
		DateOfExpiry DATETIME '$.dateOfExpiry',
		PlaceOfIssue NVARCHAR(MAX) '$.placeOfIssue',
		CountryOfIssue NVARCHAR(MAX) '$.countryOfIssue',
		Authenticity NVARCHAR(MAX) '$.authenticity',
		Validity NVARCHAR(MAX) '$.validity'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO NARRATIVEINFORMATION TABLE
	SET @NARRATIVEINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformation')
	INSERT INTO [dbo].[NarrativeInformation](PIC, Information, FileReferenceNumber, [Date])
	SELECT @PIC,* FROM OPENJSON(@NARRATIVEINFORMATION)
	WITH(
		Information NVARCHAR(MAX) '$.information',
		FileReferenceNumber NVARCHAR(MAX) '$.fileReferenceNumber',
		[Date] DATETIME '$.date'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO NATIONALITY TABLE
	SET @NATIONALITY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'nationality')
	INSERT INTO [dbo].[Nationality](PIC, [AddedDate], Nation)
	SELECT @PIC,GETDATE(),* FROM OPENJSON(@NATIONALITY)
	WITH(
		Nation NVARCHAR(MAX) '$.nation'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO OCCUPATIONS TABLE
	SET @OCCUPATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'occupations')
	INSERT INTO [dbo].[Occupations](PIC, Occupation, [Type], PostOrJob, [Category], [Rank], RegimentalNo, PlaceOfWork, [Address], Telephone, [Mobile], Country, PoliceStation, [From], [To],[Status])
	SELECT @PIC,* FROM OPENJSON(@OCCUPATIONS)
	WITH(
		Occupation NVARCHAR(MAX) '$.occupation',
		Type NVARCHAR(MAX) '$.type',
		PostOrJob NVARCHAR(MAX) '$.postOrJob',
		[Category] NVARCHAR(MAX) '$.category',
		[Rank] NVARCHAR(MAX) '$.rank',
		RegimentalNo NVARCHAR(MAX) '$.regimentalNo',
		PlaceOfWork NVARCHAR(MAX) '$.placeOfWork',
		[Address] NVARCHAR(MAX) '$.address',
		Telephone NVARCHAR(MAX) '$.telephone',
		Mobile NVARCHAR(MAX) '$.mobile',
		Country NVARCHAR(MAX) '$.country',
		PoliceStation NVARCHAR(MAX) '$.policeStation',
		[From] DATETIME '$.from',
		[To] DATETIME '$.to',
		[Status] NVARCHAR(MAX) '$.status'

	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ORGANIZATIONS TABLE
	SET @ORGANIZATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'organizations')
	INSERT INTO [dbo].[Organizations](PIC, OIC, [Type], Position, Place, [From], [To])
	SELECT @PIC,* FROM OPENJSON(@ORGANIZATIONS)
	WITH(
		OIC BIGINT '$.oic',
		[Type] NVARCHAR(MAX) '$.type',
		Position NVARCHAR(MAX) '$.position',
		Place NVARCHAR(MAX) '$.place',
		[From] DATETIME '$.from',
		[To] DATETIME '$.to'
	)
 --   --ihthi 21/06/2023
	--INSERT INTO [SIS_Organization].[dbo].[RelatedPersons](PIC,OIC)
	--SELECT @PIC,OIC FROM OPENJSON(@ORGANIZATIONS)
	--WITH(
	--	OIC BIGINT '$.oic',
	--	[Type] NVARCHAR(MAX) '$.type',
	--	Position NVARCHAR(MAX) '$.position',
	--	Place NVARCHAR(MAX) '$.place',
	--	[From] DATETIME '$.from',
	--	[To] DATETIME '$.to'
	--)


	--GET THE DATA FROM TEMP TABLE & INSERTING TO PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')
	INSERT INTO [dbo].[Photographs](PIC,AddedDate, [Path])
	SELECT @PIC,getdate(),* FROM OPENJSON(@PHOTOGRAPHS)
	WITH(
		[Path] NVARCHAR(MAX) '$.path'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO PHOTOGRAPHSOTHERDETAILS TABLE
	SET @PHOTOGRAPHSOTHERDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographsOtherDetails')
	INSERT INTO [dbo].[PhotographsOtherDetails](PIC, Place, ReferenceNumber)
	SELECT @PIC,* FROM OPENJSON(@PHOTOGRAPHSOTHERDETAILS)
	WITH(
		Place NVARCHAR(MAX) '$.place',
		ReferenceNumber NVARCHAR(MAX) '$.referenceNumber'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATIVES TABLE
	SET @RELATIVES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatives')
	INSERT INTO [dbo].[Realtives](PIC,[RelativesPIC], Name, Relationship, IdentifyingFeatures)
	SELECT @PIC,* FROM OPENJSON(@RELATIVES)
	WITH(
		[RelativesPIC] BIGINT '$.relativesPIC',
		Name NVARCHAR(MAX) '$.name',
		Relationship NVARCHAR(MAX) '$.relationship',
		IdentifyingFeatures NVARCHAR(MAX) '$.identifyingFeatures'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO REALTEDACTIVITIES TABLE
	SET @REALTEDACTIVITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities')
	INSERT INTO [dbo].[RelatedActivities](PIC, AIC, [IdentifyingFeature], [Category])
	SELECT @PIC,* FROM OPENJSON(@REALTEDACTIVITIES)
	WITH(
		AIC BIGINT '$.aic',
		[IdentifyingFeature] NVARCHAR(MAX) '$.identifyingFeature',
		[Category] NVARCHAR(MAX) '$.category'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATEDITEMS TABLE
	SET @RELATEDITEMS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedItems')
	INSERT INTO [dbo].[RelatedItems](PIC, IIC, [IdentifyingFeature])
	SELECT @PIC,* FROM OPENJSON(@RELATEDITEMS)
	WITH(
		IIC BIGINT '$.iic',
		[IdentifyingFeature] NVARCHAR(MAX) '$.identifyingFeature'
	);


	--GET THE DATA FROM TEMP TABLE & INSERTING TO SECURITYCLASSIFICATIONS TABLE
	SET @SECURITYCLASSIFICATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'securityClassifications')
	INSERT INTO [dbo].[SecurityClassifications]([PIC], [SecurityClassification], [RelatedCountry], [DateFrom], [DateTo])
	SELECT @PIC,* FROM OPENJSON(@SECURITYCLASSIFICATIONS)
	WITH(
		[SecurityClassification] NVARCHAR(MAX) '$.securityClassification',
		[RelatedCountry] NVARCHAR(MAX) '$.relatedCountry',
		[DateFrom] DATETIME '$.dateFrom',
		[DateTo] DATETIME '$.dateTo'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO SOCIALMEDIA TABLE
	SET @SOCIALMEDIA = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'socialMediaDetails')
	INSERT INTO [dbo].[SocialMediaDetails]([PIC], [SocialMedia], [URL])
	SELECT @PIC,* FROM OPENJSON(@SOCIALMEDIA)
	WITH(
		[SocialMedia] NVARCHAR(MAX) '$.socialMedia',
		[URL] NVARCHAR(MAX) '$.url'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO SPECIALPECULIARITIES TABLE
	SET @SPECIALPECULIARITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'specialPeculiarities')
	INSERT INTO [dbo].[SpecialPeculiarities](PIC, SpecialPeculiarity)
	SELECT @PIC,* FROM OPENJSON(@SPECIALPECULIARITIES)
	WITH(
		SpecialPeculiarity NVARCHAR(MAX) '$.specialPeculiarity'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO SPECIALSKILLS TABLE
	SET @SPECIALSKILLS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'specialSkills')
	INSERT INTO [dbo].[SpecialSkills](PIC, SpecialSkill)
	SELECT @PIC,* FROM OPENJSON(@SPECIALSKILLS)
	WITH(
		SpecialSkill NVARCHAR(MAX) '$.specialSkill'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	INSERT INTO [dbo].[SystemDetails](PIC, EnteredUserName, LastModifiedUserName, Desk, [Subject],EnteredDate)
	SELECT @PIC,*,GETDATE() AS 'EnteredDate' FROM OPENJSON(@SYSTEMDETAILS)
	WITH(
		EnteredUserName NVARCHAR(MAX) '$.enteredUserName',
		LastModifiedUserName NVARCHAR(MAX) '$.lastModifiedUserName',
		Desk NVARCHAR(MAX) '$.deskId',
		[Subject] NVARCHAR(MAX) '$.subjectId'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO TRAVELINFORMATION TABLE
	SET @TRAVELINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'travelInformation')
	INSERT INTO [dbo].[TravelInformation]([PIC], [ActionToBeTakenOnArrival], [ActionToBeTakenOnDeparture], [From], [To], [AddedDate],AuthorizedPerson,Reason,FileReferenceNo)
	SELECT @PIC,* FROM OPENJSON(@TRAVELINFORMATION)
	WITH(
		[ActionToBeTakenOnArrival] NVARCHAR(MAX) '$.actionToBeTakenOnArrival',
		[ActionToBeTakenOnDeparture] NVARCHAR(MAX) '$.actionToBeTakenOnDeparture',
		[From] DATETIME '$.from',
		[To] DATETIME '$.to',
		[AddedDate] DATETIME '$.addedDate',
		AuthorizedPerson NVARCHAR(MAX) '$.authorizedPerson',
		Reason NVARCHAR(MAX) '$.reason',
		FileReferenceNo NVARCHAR(MAX) '$.fileReferenceNo'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO WEAKNESSES TABLE
	SET @WEAKNESSES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'weaknesses')
	INSERT INTO [dbo].[Weaknesses](PIC, Weakness)
	SELECT @PIC,* FROM OPENJSON(@WEAKNESSES)
	WITH(
		Weakness NVARCHAR(MAX) '$.weakness'
	)


	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')
	INSERT INTO [dbo].[DirectAndRoleWiseAccessRestrictions](PIC,DirectorOnly,DeskOfficerOnly)
	SELECT @PIC,* FROM OPENJSON(@ACCESSRESTRICTIONS)
	WITH(
		DirectorOnly bit '$.directorOnly',
		DeskOfficerOnly bit '$.deskOfficerOnly'
	)


	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @PIC

	SELECT @PIC AS 'PIC'

    COMMIT TRANSACTION;  
END TRY  

BEGIN CATCH  
     INSERT INTO SIS_Log.dbo.PERSON_ERROR_MESSAGE([Error_Message],[Type],[DateTime])
     SELECT ERROR_MESSAGE(),'Person INSERT',GETDATE()
    --XACT_STATE:  
        -- If 1, the transaction is committable.  
        -- If -1, the transaction is uncommittable and should   
        --     be rolled back.  
        -- XACT_STATE = 0 means that there is no transaction and  
        --     a commit or rollback operation would generate an error.  

    -- Test whether the transaction is uncommittable.  
	SELECT XACT_STATE()
    IF (XACT_STATE()) = -1  
    BEGIN  
        PRINT N'The transaction is in an uncommittable state.Rolling back transaction.'  
        ROLLBACK TRANSACTION;  
    END;  

    -- Test whether the transaction is committable.  
    IF (XACT_STATE()) = 1  
    BEGIN  
        PRINT N'The transaction is committable.Committing transaction.'  
        COMMIT TRANSACTION;     
    END;  
END CATCH;

END



