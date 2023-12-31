USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_ORGANIZATION]    Script Date: 8/15/2023 9:44:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CREATE_ORGANIZATION](@ORGJSON VARCHAR(MAX))
AS
BEGIN 
	SET NOCOUNT ON;


	
BEGIN TRANSACTION T1

--CREATING AN TEMPORARY TABLE FROM JSON
SELECT * INTO #TEMP FROM OPENJSON(@ORGJSON)

	--VARIABLE DECLARATIONS
	--VARIABLE DECLARATIONS
	DECLARE @ADDRESSES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='addresses')
	DECLARE @ALIASES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='aliases')
	DECLARE @BRANCHES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='branches')
	DECLARE @MEMBERSHIPS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='memberships')
	DECLARE @COURIERS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='couriers')
	DECLARE @DISTRICTLEADERS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='districtLeaders')
	DECLARE @EMPLOYEES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='employees')
	DECLARE @EXTERNALLINKS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='externalLinks')
	DECLARE @FILEREFERENCES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='fileReferences')
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='narrativeInformation')
	DECLARE @ORGANIZATIONINFORMATION NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='organizationInformation')
	DECLARE @POLITICALLINKS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='politicalLinks')
	DECLARE @PRESSES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='presses')
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='photographs')
	DECLARE @PUBLICATIONS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='publications')
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='relatedActivities')
	DECLARE @RELATEDORGANIZATIONS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='relatedOrganizations')
	DECLARE @SAFEHOUSES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='safeHouses')
	DECLARE @SPLINTERGROUPS NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='splinterGroups')
	DECLARE @SYSTEMDETAIL NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='systemDetails')
	DECLARE @VEHICLESOWNED NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='vehiclesOwned')
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX) = (SELECT [VALUE] FROM #TEMP WHERE [KEY] = 'rolewiseAccessRestrictions')

	--DECLARE @MEMBERSHIP NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='membership')
	--DECLARE @NUMBEROFBRANCHES NVARCHAR(MAX) = (SELECT VALUE FROM #TEMP WHERE [KEY]='numberOfBranches')

	DECLARE @OIC BIGINT --= (SELECT * FROM OPENJSON(@ORGINFO) WITH (OIC BIGINT '$.oic'))



	DECLARE @X TABLE (OIC BIGINT)

	-- SAVING ORGANIZATION INFORMATION
	INSERT INTO OrganizationInformation( TypeOfOrganization, SubClassificationI, SubClassificationII, OrganizationName, RegistrationNumber, OrganizationCountry)
	OUTPUT INSERTED.OIC INTO @X
	SELECT * FROM OPENJSON((SELECT VALUE FROM #TEMP where [KEY]='organizationInformation')) 
	WITH(
		TypeOfOrganization VARCHAR(MAX) '$.typeOfOrganization',
		SubClassificationI VARCHAR(MAX) '$.subClassificationI',
		SubClassificationII VARCHAR(MAX) '$.subClassificationII',
		OrganizationName VARCHAR(MAX) '$.organizationName',
		RegistrationNumber VARCHAR(MAX) '$.registrationNumber',
		OrganizationCountry VARCHAR(MAX) '$.organizationCountry'
		)
	SET @OIC = (SELECT OIC FROM @X)
	

	--GET THE DATA FROM TEMP TABLE & INSERTING TO BRANCHES
	INSERT INTO [dbo].[BRANCHES](OIC, [Count], [Year])
	SELECT @OIC,* FROM OPENJSON(@BRANCHES)
	WITH(
		[Count] INT '$.count',
		[Year] INT '$.year'
		)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO MEMBERSHIPS
	INSERT INTO [dbo].[MEMBERSHIPS](OIC,[Count], [Year])
	SELECT @OIC,* FROM OPENJSON(@MEMBERSHIPS)
	WITH(
		[Count] INT '$.count',
		[Year] INT '$.year'
		)
	


	-- SAVING ALIASES
	INSERT INTO ALIASES(OIC, AliasName, AddedDate)
	SELECT @OIC AS OIC,*,GETDATE() FROM OPENJSON(@ALIASES)
	WITH(
		Aliases NVARCHAR(MAX) '$.aliasName'
		)

	-- SAVING ADDRESSES
	INSERT INTO ADDRESSES(OIC,  AddressType, OrganizationAddress, TelephoneNo, DateFrom, DateTo)
	SELECT @OIC AS OIC,* FROM OPENJSON(@ADDRESSES)
	WITH(
		AddressType NVARCHAR(MAX) '$.addressType',
		OrganizationAddress NVARCHAR(MAX) '$.organizationAddress',
		TelephoneNo NVARCHAR(MAX) '$.telephoneNo',
		DateFrom Date '$.dateFrom',
		DateTo Date '$.dateTo'
		)


	-- SAVING COURIERS
	INSERT INTO COURIERS(OIC,PIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@COURIERS)
	WITH(
		PIC BIGINT '$.pic'
		)

	-- SAVING DISTRICT LEADERS
	INSERT INTO DistrictLeaders(OIC, PIC, District, DateFrom, DateTo)
	SELECT @OIC AS OIC,* FROM OPENJSON(@DISTRICTLEADERS)
	WITH(
		PIC BIGINT '$.pic',
		District NVARCHAR(MAX) '$.district',
		DateFrom DATE '$.dateFrom',
		DateTo DATE '$.dateTo'
		) 

	-- SAVING EMPLOYEES
	INSERT INTO EMPLOYEES(OIC, PIC, [Type] ,Country)
	SELECT @OIC AS OIC,* FROM OPENJSON(@EMPLOYEES)
	WITH(
		PIC BIGINT '$.pic',
		[Type] NVARCHAR(MAX) '$.type',
		Country NVARCHAR(MAX) '$.country'
		)

	-- SAVING ETERNAL LINKS
	INSERT INTO ExternalLinks(OIC, ExternalLinksOIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@EXTERNALLINKS)
	WITH(
		ExternalLinkOIC NVARCHAR(MAX) '$.oic'
		)


	-- SAVING FILE REFERENCES
	INSERT INTO FileReferences(OIC, FileReference)
	SELECT @OIC AS OIC,* FROM OPENJSON(@FILEREFERENCES)
	WITH(
		FileReference NVARCHAR(MAX) '$.fileReference'
		)


	-- SAVING NARRATIVE INFORMATION
	INSERT INTO [NarrativeInformation](OIC, Date,Information, FileReferenceNumber)
	SELECT @OIC AS OIC,* FROM OPENJSON(@NARRATIVEINFORMATION)
	WITH(
	Date Date '$.date',
		Information NVARCHAR(MAX) '$.information',
		FileReferenceNumber NVARCHAR(MAX) '$.fileReferenceNumber'	
		)
	

	-- SAVING PHOTOGRAPHS
	INSERT INTO PHOTOGRAPHS(OIC, Path, Description, AddedDate)
	SELECT @OIC AS OIC,* FROM OPENJSON(@PHOTOGRAPHS)
	WITH(
		Path NVARCHAR(MAX) '$.path',
		Description NVARCHAR(MAX) '$.description',
		AddedDate Date '$.addedDate'
		)

	-- SAVING PoliticalLinks
	INSERT INTO POLITICALLINKS(OIC,LinkOIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@POLITICALLINKS)
	WITH(
		LinkOIC BIGINT '$.linkOIC'
		)


	-- SAVING PRESSES
	INSERT INTO PRESSES(OIC,PressesOIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@PRESSES)
	WITH(
		PressesOIC BIGINT '$.oic'
		)


	-- SAVING PUBLICATIONS
	INSERT INTO PUBLICATIONS(OIC,PublicationsOIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@PUBLICATIONS)
	WITH(
		PublicationsOIC BIGINT '$.oic'
		)

	-- SAVING RelatedActivities
	INSERT INTO RelatedActivities(OIC, AIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@RELATEDACTIVITIES)
	WITH(
		AIC BIGINT '$.aic'
		)

	-- SAVING RELATEDORGANIZATIONS
	INSERT INTO RelatedOrganizations(OIC, [RelatedOrganizations(OIC)],[OrganizationCatagory])
	SELECT @OIC AS OIC,* FROM OPENJSON(@RELATEDORGANIZATIONS)
	WITH(
		[RelatedOrganizations(OIC)] BIGINT '$.relatedOIC',
		[OrganizationCatagory] nvarchar(max) '$.organizationCatagory'
		)

	-- SAVING SAFE HOUSES
	INSERT INTO SafeHouses(OIC, SafeHousesOIC,[FromDate],[ToDate])
	SELECT @OIC AS OIC,* FROM OPENJSON(@SAFEHOUSES)
	WITH(
		SafeHousesOIC BIGINT '$.oic',
		[FromDate] DATE '$.fromDate',
		[ToDate] DATE '$.toDate'
		)

	-- SAVING SPLINTER GROUPS
	INSERT INTO SplinterGroups(OIC, SplinterGroupOIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@SPLINTERGROUPS)
	WITH(
		SplinterGroupOIC BIGINT '$.oic'
		)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO SYSTEMDETAILS TABLE
	INSERT INTO [dbo].[SystemDetails](OIC, EnteredUserName, LastModifieduserName, LastModifiedDate, DeskTarget,[Subject],EnteredDate)
	SELECT @OIC,*,GETDATE() FROM OPENJSON(@SYSTEMDETAIL)
	WITH(
		EnteredUserName NVARCHAR(MAX) '$.enteredUser',
		LastModifieduserName NVARCHAR(MAX) '$.modifiedUser',
		LastModifiedDate DATE '$.lastModifiedDate',
		DeskTarget NVARCHAR(MAX) '$.deskTarget',
		Subject NVARCHAR(MAX) '$.subject'
		)


	-- SAVING VEHICLES OWNED
	INSERT INTO VehiclesOwned(OIC, IIC)
	SELECT @OIC AS OIC,* FROM OPENJSON(@VEHICLESOWNED)
	WITH(
		IIC BIGINT '$.iic'
		)


	INSERT INTO dbo.DirectAndRoleWiseAccessRestrictions(OIC,DirectorOnly,DeskOfficerOnly)
	SELECT * FROM DirectAndRoleWiseAccessRestrictions
	SELECT @OIC,* FROM OPENJSON(@ACCESSRESTRICTIONS)
	WITH(
		DirectorOnly bit '$.directorOnly',
		DeskOfficerOnly bit '$.deskOfficerOnly'
	)	


	----GET THE DATA FROM TEMP TABLE & INSERTING TO BRANCHESORMEMBERSHIP TABLE
	--INSERT INTO [dbo].[BRANCHESORMEMBERSHIP](ID,OIC, Type, Number, Year)
	--SELECT @OIC,* FROM OPENJSON(@SYSTEMDETAIL)
	--WITH(
	--	OIC NVARCHAR(MAX) '$.oic',
	--	Type DATE '$.type',
	--	Number NVARCHAR(MAX) '$.number',
	--	Year DATE '$.year'
	--)

	

	---- SAVING MEMBERSHIP
	--INSERT INTO MEMBERSHIP(ID,OIC, Number, Year)
	--SELECT @OIC AS OIC,* FROM OPENJSON(@MEMBERSHIP)
	--WITH(
	--OIC INT '$.oic',
	--Number NVARCHAR(MAX) '$.number',
	--Year NVARCHAR(MAX) '$.year'
	--)


	---- SAVING NUMBEROFBRANCHES
	--INSERT INTO NUMBEROFBRANCHES(ID, OIC, Number, Year)
	--SELECT @OIC AS OIC,* FROM OPENJSON(@NUMBEROFBRANCHES)
	--WITH(
	--OIC INT '$.oic',
	--Number NVARCHAR(MAX) '$.number',
	--Year NVARCHAR(MAX) '$.year'
	--)

		---- SAVING ACTIVE MEMBERS
	--INSERT INTO ActiveMembers(OIC, PIC, Comment)
	--SELECT @OIC AS OIC,*,NULL AS Comment FROM OPENJSON ((SELECT VALUE FROM #TEMP WHERE [KEY]='activeMembers'))
	--WITH(
	--PIC BIGINT '$.activeMemberPIC'
	--)


	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @OIC
		COMMIT TRANSACTION T1
    -- Insert statements for procedure here

	SELECT @OIC
END
