USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON]    Script Date: 25/06/2023 16:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_PERSON]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @TR_UPDATE_PERSON NVARCHAR(MAX)
	DECLARE @ADDRESS NVARCHAR(MAX)
	DECLARE @ALIASES NVARCHAR(MAX)
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
	DECLARE @REALTIVES NVARCHAR(MAX)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX)
	DECLARE @PIC BIGINT
	DECLARE @PERSON TABLE (ID BIGINT)
	--END -> DECLARING VARIABLES

	--BEGIN TRANSACTION @TR_UPDATE_PERSON
	SET NOCOUNT ON
	--INSERTING JSON ARRAY TO TEMP TABLE
	IF OBJECT_ID('tempdb..#PARSED') IS NOT NULL
		DROP TABLE #PARSED

	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	--GET THE DATA FROM TEMP TABLE & UPDATING PERSONINFORMATION TABLE
	SET @PERSONINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'personInformation')
	SET @PIC = (SELECT PIC FROM OPENJSON(@PERSONINFORMATION) WITH(PIC BIGINT '$.pic'))
	
	EXEC SP_UPDATE_PERSON_PERSONAL_INFORMATION @PERSONINFORMATION;
	

	--GET THE DATA FROM TEMP TABLE & UPDATING ADDRESS TABLE
	SET @ADDRESS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'addresses')

	EXEC SP_UPDATE_PERSON_ADDRESS @ADDRESS;

	--GET THE DATA FROM TEMP TABLE & UPDATING ALIASES TABLE
	SET @ALIASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aliases')

	EXEC SP_UPDATE_PERSON_ALIASES @ALIASES;
	
	--GET THE DATA FROM TEMP TABLE & UPDATING ALLTRAVELPARTICULARS TABLE
	SET @ALLTRAVELPARTICULARS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'allTravelParticulars')

	EXEC SP_UPDATE_PERSON_ALLTRAVELPARTICULARS @ALLTRAVELPARTICULARS;

	--GET THE DATA FROM TEMP TABLE & UPDATING ASYLUMSEEKER TABLE
	SET @ASYLUMSEEKER = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'asylumSeeker')

	EXEC SP_UPDATE_PERSON_ASYLUMSEEKER @ASYLUMSEEKER;

	--GET THE DATA FROM TEMP TABLE & UPDATING CARDINGDETAILS TABLE
	SET @CARDINGDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'cardingDetails')

	EXEC SP_UPDATE_PERSON_CRADING_DETAILS @CARDINGDETAILS;

	--GET THE DATA FROM TEMP TABLE & UPDATING CONVEYANCES TABLE
	SET @CONVEYANCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'conveyances')

	EXEC SP_UPDATE_PERSON_CONVETANCES @CONVEYANCES;

	--GET THE DATA FROM TEMP TABLE & UPDATING COURTCASES TABLE
	SET @COURTCASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'courtCases')

	EXEC SP_UPDATE_PERSON_COURT_CASES @COURTCASES;


	--GET THE DATA FROM TEMP TABLE & UPDATING ASYLUMSEEKER TABLE
	SET @CURRENTSTATUS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'currentStatus')

	EXEC SP_UPDATE_PERSON_CURRENT_STATUS @CURRENTSTATUS;
	
		--GET THE DATA FROM TEMP TABLE & UPDATING DETENTIONPLACE TABLE
	SET @DETENTIONPLACE = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detentionPlace')

	EXEC SP_UPDATE_PERSON_DETENTION_PLACE @DETENTIONPLACE;

	--GET THE DATA FROM TEMP TABLE & UPDATING EDUCATION TABLE
	SET @EDUCATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'education')

	EXEC SP_UPDATE_PERSON_EDUCATION @EDUCATION;

	--GET THE DATA FROM TEMP TABLE & UPDATING FILEREFERENCES TABLE
	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')
	
	EXEC SP_UPDATE_PERSON_FILE_REFERENCES @FILEREFERENCES;

	--GET THE DATA FROM TEMP TABLE & UPDATING IDENTIFICATION TABLE
	SET @IDENTIFICATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'identification')

	EXEC SP_UPDATE_PERSON_IDENTIFICATION @IDENTIFICATION;

	--GET THE DATA FROM TEMP TABLE & UPDATING NARRATIVEINFORMATION TABLE
	SET @NARRATIVEINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformation')
	
	EXEC SP_UPDATE_PERSON_NARRATIVE_INFORMATION @NARRATIVEINFORMATION;


	--GET THE DATA FROM TEMP TABLE & UPDATING NATIONALITY TABLE
	SET @NATIONALITY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'nationality')
	
	EXEC SP_UPDATE_PERSON_NATIONALITY @NATIONALITY;

	--GET THE DATA FROM TEMP TABLE & UPDATING OCCUPATION TABLE
	SET @OCCUPATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'occupations')

	EXEC SP_UPDATE_PERSON_OCCUPATIONS @OCCUPATIONS;

	--GET THE DATA FROM TEMP TABLE & UPDATING ORGANIZATIONS TABLE
	SET @ORGANIZATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'organizations')

	EXEC SP_UPDATE_PERSON_ORGANIZATIONS @ORGANIZATIONS;

	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')

    EXEC SP_UPDATE_PERSON_PHOTOGRAPHS @PHOTOGRAPHS;

	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHSOTHERDETAILS TABLE
	SET @PHOTOGRAPHSOTHERDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographsOtherDetails')
	
	EXEc SP_UPDATE_PERSON_PHOTOGRAPHS_OTHER_DETAILS @PHOTOGRAPHSOTHERDETAILS;

	--GET THE DATA FROM TEMP TABLE & UPDATING REALTIVES TABLE
	SET @REALTIVES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatives')

	EXEC SP_UPDATE_PERSON_RELATIVES @REALTIVES;

	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDACTIVITIES TABLE
	SET @RELATEDACTIVITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities')

	EXEC SP_UPDATE_PERSON_RELATED_ACTIVITIES @RELATEDACTIVITIES;
 
	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDITEMS TABLE
	SET @RELATEDITEMS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedItems')

	EXEC SP_UPDATE_PERSON_RELATED_ITEMS @RELATEDITEMS;

	--GET THE DATA FROM TEMP TABLE & UPDATING SECURITYCLASSIFICATIONS TABLE
	SET @SECURITYCLASSIFICATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'securityClassifications')

	EXEC SP_UPDATE_PERSON_SECURITY_CLASSIFICATIONS @SECURITYCLASSIFICATIONS;

	--GET THE DATA FROM TEMP TABLE & UPDATING SOCIALMEDIA TABLE
	SET @SOCIALMEDIA = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'socialMediaDetails')

	EXEC SP_UPDATE_PERSON_SOCIAL_MEDIA_DETAILS @SOCIALMEDIA;

	--GET THE DATA FROM TEMP TABLE & UPDATING SPECIALPECULIARITIES TABLE
	SET @SPECIALPECULIARITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'specialPeculiarities')

	EXEC SP_UPDATE_PERSON_SPECIAL_PECULIARITIES @SPECIALPECULIARITIES;

	--GET THE DATA FROM TEMP TABLE & UPDATING SPECIALSKILLS TABLE
	SET @SPECIALSKILLS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'specialSkills')

	EXEC SP_UPDATE_PERSON_SPECIAL_SKILLS @SPECIALSKILLS;

	--GET THE DATA FROM TEMP TABLE & UPDATING SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	
	EXEC SP_UPDATE_PERSON_SYSTEM_DETAILS @SYSTEMDETAILS;

	--GET THE DATA FROM TEMP TABLE & UPDATING TRAVELINFORMATION TABLE
	SET @TRAVELINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'travelInformation')

	EXEC SP_UPDATE_PERSON_TRAVEL_INFORMATION @TRAVELINFORMATION;

	--GET THE DATA FROM TEMP TABLE & UPDATING SPECIALSKILLS TABLE
	SET @WEAKNESSES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'weaknesses')

	EXEC SP_UPDATE_PERSON_WEAKNESSES @WEAKNESSES;

	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')

	EXEC SP_UPDATE_PERSON_ROLE_WISE_ACCESS_RESTRICTIONS @ACCESSRESTRICTIONS;

	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @PIC

	DROP TABLE #PARSED;
--COMMIT TRANSACTION @TR_UPDATE_PERSON

END
GO
