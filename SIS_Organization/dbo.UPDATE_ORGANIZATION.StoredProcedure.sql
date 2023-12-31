USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_ORGANIZATION]    Script Date: 7/14/2023 5:29:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UPDATE_ORGANIZATION](@JSON NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;

--START -> DECLARING VARIABLES
	DECLARE @ORGINFO NVARCHAR(MAX) 
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX) 
	DECLARE @ADDRESSES NVARCHAR(MAX) 
	DECLARE @EMPLOYEES NVARCHAR(MAX)
	DECLARE @NARRATIVEINFO NVARCHAR(MAX)
	DECLARE @FILEREFS NVARCHAR(MAX)
	DECLARE @EXTERNALLINKS NVARCHAR(MAX)
	DECLARE @DISTRICTLEADERS NVARCHAR(MAX)
	DECLARE @VEHICLES NVARCHAR(MAX)
	DECLARE @SPLINTERGROUPS NVARCHAR(MAX)
	DECLARE @ACTIVITIES NVARCHAR(MAX)
	DECLARE @OIC BIGINT
	DECLARE @TR_UPDATE_ORGANIZATION NVARCHAR(MAX)
	DECLARE @ACTIVEMEMBERS NVARCHAR(MAX)
	DECLARE @Address NVARCHAR(MAX)
	DECLARE @ALIASES NVARCHAR(MAX)
	DECLARE @COURIERS NVARCHAR(MAX)
	DECLARE @FILEREFERENCES NVARCHAR(MAX)
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)
	DECLARE @ORGANIZATIONINFORMATION NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX)
	DECLARE @POLITICALLINKS NVARCHAR(MAX)
	DECLARE @PRESSES NVARCHAR(MAX)
	DECLARE @PUBLICATIONS NVARCHAR(MAX)
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX)
	DECLARE @RELATEDORGANIZATIONS NVARCHAR(MAX)
	DECLARE @SAFEHOUSES NVARCHAR(MAX)
	DECLARE @VEHICLESOWNED NVARCHAR(MAX)
	DECLARE @NUMBEROFBRANCHES NVARCHAR(MAX)
	DECLARE @BRANCHES NVARCHAR(MAX)
	DECLARE @MEMBERSHIPS NVARCHAR(MAX)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	
	--END -> DECLARING VARIABLES
	

	BEGIN TRANSACTION @TR_UPDATE_ORGANIZATION


	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)
	
	--GET THE DATA FROM TEMP TABLE & UPDATING ORGANIZATIONINFORMATION TABLE
	SET @ORGANIZATIONINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'organizationInformation')
	SET @OIC = (SELECT [VALUE] FROM OPENJSON(@ORGANIZATIONINFORMATION) WHERE [KEY]='oic')

	--DECLARE @OIC NVARCHAR(MAX) = 2596
	IF NOT EXISTS (SELECT * FROM OrganizationInformation WHERE OIC = @OIC)
	BEGIN
		-- INSERTING ORGANIZATIONAL INFORMATION
		DECLARE @X TABLE (OIC BIGINT)
		INSERT INTO OrganizationInformation( [TypeOfOrganization], [SubClassificationI], [SubClassificationII], [OrganizationName], [RegistrationNumber], [OrganizationCountry])
		OUTPUT INSERTED.OIC INTO @X
		VALUES(NULL,NULL,NULL,NULL,NULL,NULL)
		SET @OIC = (SELECT OIC FROM @X)

		-- INSERTING SYSTEM DETAILS
		SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
		INSERT INTO [dbo].[SystemDetails](OIC, EnteredUserName, LastModifieduserName, LastModifiedDate, DeskTarget,[Subject],EnteredDate)
		SELECT @OIC,*,GETDATE() FROM OPENJSON(@SYSTEMDETAILS)
		WITH(
			EnteredUserName NVARCHAR(MAX) '$.enteredUser',
			LastModifieduserName NVARCHAR(MAX) '$.lastModifiedUserName',
			LastModifiedDate DATE '$.lastModifiedDate',
			DeskTarget NVARCHAR(MAX) '$.deskTarget',
			Subject NVARCHAR(MAX) '$.subject');

		-- INESERTING ROLE WISE ACCESS RESTRICTION INFORMATION
		SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')
		INSERT INTO dbo.DirectAndRoleWiseAccessRestrictions(OIC,DirectorOnly,DeskOfficerOnly)
		--SELECT * FROM DirectAndRoleWiseAccessRestrictions
		SELECT @OIC,* FROM OPENJSON(@ACCESSRESTRICTIONS)
		WITH(
			DirectorOnly bit '$.directorOnly',
			DeskOfficerOnly bit '$.deskOfficerOnly'
		)
	END 

	--GET THE DATA FROM TEMP TABLE & UPDATING SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')

	UPDATE A
	SET 
		A.EnteredUserName = JS.EnteredUserName,
		A.LastModifieduserName = JS.LastModifieduserName,
		A.LastModifiedDate = js.LastModifiedDate,
		A.DeskTarget = JS.DeskTarget,
		A.[Subject]= JS.[Subject]

	FROM [dbo].[SystemDetails] A
		 INNER JOIN
		(SELECT *,IIF(LastModifieduserName IS NULL,NULL,GETDATE())'LastModifiedDate' FROM OPENJSON(@SYSTEMDETAILS)
		WITH(
			EnteredUserName NVARCHAR(MAX) '$.enteredUserName',
			LastmodifiedUserName NVARCHAR(MAX) '$.lastModifiedUserName',
			DeskTarget NVARCHAR(MAX) '$.deskTarget',
			[Subject] NVARCHAR(MAX) '$.subject'
		)) JS
	ON A.OIC = @OIC
	WHERE A.OIC = @OIC
	
	--select * from SystemDetails 
	UPDATE ORI
	SET
	 ORI.TypeOfOrganization = TEMP.TypeOfOrganization,
	 ORI.SubClassificationI = TEMP.SubClassificationI,
	 ORI.SubClassificationII = TEMP.SubClassificationII,
	 ORI.OrganizationName = TEMP.OrganizationName,
	 ORI.RegistrationNumber = TEMP.RegistrationNumber,
	 ORI.OrganizationCountry = TEMP.OrganizationCountry
	
	FROM [dbo].[OrganizationInformation] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@ORGANIZATIONINFORMATION)
	WITH(
		OIC BIGINT '$.oic',
		TypeOfOrganization VARCHAR(MAX) '$.typeOfOrganization',
		SubClassificationI VARCHAR(MAX) '$.subClassificationI',
		SubClassificationII VARCHAR(MAX) '$.subClassificationII',
		OrganizationName VARCHAR(MAX) '$.organizationName',
		RegistrationNumber VARCHAR(MAX) '$.registrationNumber',
		OrganizationCountry VARCHAR(MAX) '$.organizationCountry'
	)) TEMP
	ON ORI.OIC = @OIC
	WHERE ORI.OIC = @OIC

	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')

	UPDATE T
	SET
		T.DirectorOnly = TEMP.DirectorOnly,
		T.DeskOfficerOnly = TEMP.DeskOfficerOnly
	
	FROM [dbo].DirectAndRoleWiseAccessRestrictions T
		 INNER JOIN
	(SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
	WITH(
			DirectorOnly bit '$.directorOnly',
			DeskOfficerOnly bit '$.deskOfficerOnly'
	)) TEMP
	ON T.OIC = @OIC
	WHERE T.OIC = @OIC

	
	--
	--UPDATE t
	--SET
	-- t.DirectorOnly = TEMP.DirectorOnly,
	-- t.DeskOfficerOnly = TEMP.DeskOfficerOnly, 
	
	--FROM [dbo].DirectAndRoleWiseAccessRestrictions t
	--	 INNER JOIN
	--(SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
	--	WITH(
	--		DirectorOnly bit '$.directorOnly',
	--		DeskOfficerOnly bit '$.deskOfficerOnly'
	--	)) TEMP
	--ON t.OIC = @OIC
	--WHERE t.OIC = @OIC

	
	
	----DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)= '{"directorOnly":true,"deskOfficerOnly":true}'
	--UPDATE t
	--SET
	-- t.DirectorOnly = TEMP.DirectorOnly,
	-- t.DeskOfficerOnly = TEMP.DeskOfficerOnly, 
	
	--FROM [dbo].DirectAndRoleWiseAccessRestrictions t
	--	 INNER JOIN
	--SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
	--	WITH(
	--		DirectorOnly bit '$.directorOnly',
	--		DeskOfficerOnly bit '$.deskOfficerOnly'
	--	) TEMP
	--ON t.OIC = @OIC
	--WHERE t.OIC = @OIC
	 

	----GET THE DATA FROM TEMP TABLE & UPDATING ADDRESS TABLE
	SET @ADDRESS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'addresses') 
	MERGE [dbo].Addresses A
	USING (SELECT * FROM OPENJSON(@ADDRESS)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		OrganizationAddress NVARCHAR(MAX) '$.organizationAddress',
		AddressType NVARCHAR(MAX) '$.addressType',
		TelephoneNo NVARCHAR(MAX) '$.telephoneNo',
		DateFrom Date '$.dateFrom',
		DateTo Date '$.dateTo')) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
		 A.OIC=TEMP.OIC,
		 A.OrganizationAddress = TEMP.OrganizationAddress,
		 A.AddressType = TEMP.AddressType,
		 A.TelephoneNo = TEMP.TelephoneNo,
		 A.DateFrom = TEMP.DateFrom,
		 A.DateTo = TEMP.DateTo
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [AddressType], [OrganizationAddress], [TelephoneNo], [DateFrom], [DateTo]) 
	VALUES(@OIC,TEMP.AddressType,TEMP.OrganizationAddress,TEMP.TelephoneNo,TEMP.DateFrom,TEMP.DateTo)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;

	
	----GET THE DATA FROM TEMP TABLE & UPDATING ALIASES
	SET @ALIASES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'aliases')
	MERGE [dbo].Aliases A
	USING (SELECT * FROM OPENJSON(@ALIASES)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		AliasName NVARCHAR(MAX) '$.aliasName',
		AddedDate datetime '$.addedDate'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			 A.AliasName = TEMP.AliasName
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ( [OIC], [AliasName], [AddedDate]) 
	VALUES(@OIC,TEMP.AliasName,TEMP.AddedDate )
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE; 

	
	----GET THE DATA FROM TEMP TABLE & UPDATING COURIERS
	SET @COURIERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'couriers')
	MERGE [dbo].Couriers A
	USING (SELECT * FROM OPENJSON(@COURIERS)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		PIC BIGINT '$.relatedPIC'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			A.PIC  = TEMP.PIC,
			A.OIC  = @OIC
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [PIC]) 
	VALUES(@OIC,TEMP.PIC)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE; 
	--SELECT * FROM Couriers
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING DISTRICT LEADERS
	SET @DISTRICTLEADERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'districtLeaders')
	MERGE [dbo].DistrictLeaders A
	USING (SELECT * FROM OPENJSON(@DISTRICTLEADERS)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		PIC BIGINT '$.pic',
		District NVARCHAR(MAX) '$.district',
		DateFrom Date '$.dateFrom',
		DateTo Date '$.dateTo'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			 A.OIC=TEMP.OIC,
			 A.PIC=TEMP.PIC,
			 A.District = TEMP.District,
			 A.DateFrom = TEMP.DateFrom,
			 A.DateTo = TEMP.DateTo
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [PIC], [District], [DateFrom], [DateTo]) 
	VALUES(@OIC, TEMP.PIC, TEMP.District, TEMP.DateFrom, TEMP.DateTo)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	

	----GET THE DATA FROM TEMP TABLE & UPDATING EMPLOYEES
	SET @EMPLOYEES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'employees')
	--DECLARE @EMPLOYEES NVARCHAR(MAX)='[{"oic":259,"relatedPIC":114,"country":0,"district":0,"name":" Eshan Jayasinghe K","employeeType":3,"id":0},{"oic":259,"relatedPIC":114,"country":0,"district":0,"name":"Eshan Jayasinghe","employeeType":0,"id":0}]'
	--DECLARE @OIC BIGINT = 259
	MERGE [dbo].Employees A
	USING (SELECT * FROM OPENJSON(@EMPLOYEES)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		PIC BIGINT '$.relatedPIC',
		Type  NVARCHAR(MAX) '$.type',
		Country NVARCHAR(MAX) '$.countryName',
		District NVARCHAR(MAX) '$.districtName'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			 A.OIC=TEMP.OIC,
			 A.PIC=TEMP.PIC,
			 A.Type = TEMP.Type,
			 A.Country=TEMP.Country,
			 A.District=TEMP.District
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [PIC], [Type], [Country], [District]) 
	VALUES(@OIC, TEMP.PIC, TEMP.[Type], TEMP.[Country], TEMP.[District])
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--select * from Employees
	--truncate table employees


	----GET THE DATA FROM TEMP TABLE & UPDATING EXTERNALLINKS
	SET @EXTERNALLINKS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'externalLinks')
	MERGE [dbo].ExternalLinks T
	USING (SELECT * FROM OPENJSON(@EXTERNALLINKS)
	WITH(
			Relation BIGINT '$.relatedOIC'
	)) S
	ON T.OIC = @OIC AND T.ExternalLinksOIC = S.Relation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [ExternalLinksOIC]) 
	VALUES(@OIC, S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--select * from ExternalLinks
	 

	 
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING FILE REFERENCES
	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')
	MERGE [dbo].FileReferences A
	USING (SELECT * FROM OPENJSON(@FILEREFERENCES)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		FileReference NVARCHAR(MAX) '$.fileReference'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
				A.OIC=TEMP.OIC,
				A.FileReference = TEMP.FileReference
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [FileReference]) 
	VALUES(@OIC, TEMP.FileReference)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--SELECT * FROM FileReferences
	
	----GET THE DATA FROM TEMP TABLE & UPDATING FILE BRANCHES
	SET @BRANCHES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'branches')
	MERGE [dbo].Branches A
	USING (SELECT * FROM OPENJSON(@BRANCHES)
	WITH(
		ID INT '$.id',
		Year INT '$.year',
		Count INT '$.count'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			A.Year = TEMP.Year,
			A.Count = TEMP.Count
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([Year], [Count], [OIC]) 
	VALUES(TEMP.Year,TEMP.Count,@OIC)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;

	----GET THE DATA FROM TEMP TABLE & UPDATING MEMBERSHIPS
	SET @MEMBERSHIPS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'memberships')
	MERGE [dbo].Memberships A
	USING (SELECT * FROM OPENJSON(@MEMBERSHIPS)
	WITH(
		ID INT '$.id',
		Year INT '$.year',
		Count INT '$.count'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			A.Year = TEMP.Year,
			A.Count = TEMP.Count
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([Year], [Count], [OIC]) 
	VALUES(TEMP.Year,TEMP.Count,@OIC)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;

	
	----GET THE DATA FROM TEMP TABLE & UPDATING NARRATIVE INFORMATION
	SET @NARRATIVEINFO = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformation')
	MERGE [dbo].NarrativeInformation A
	USING (SELECT * FROM OPENJSON(@NARRATIVEINFO)
	WITH(
		ID BIGINT '$.id',
		OIC BIGINT '$.oic',
		Date dATE '$.date',
		Information NVARCHAR(MAX) '$.information',
		FileReferenceNumber NVARCHAR(MAX) '$.fileReferenceNumber'
	)) TEMP
	ON A.ID = TEMP.ID
	WHEN MATCHED
	THEN UPDATE
		SET
			A.OIC=TEMP.OIC,
			A.[Date] = TEMP.[Date],
			A.Information = TEMP.Information,
			A.FileReferenceNumber = TEMP.FileReferenceNumber
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ( [OIC], [Date], [Information], [FileReferenceNumber]) 
	VALUES(@OIC,TEMP.[Date], TEMP.Information, TEMP.FileReferenceNumber)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	
	
	------GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS
	--SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')
	--MERGE [dbo].Photographs A
	--USING (SELECT * FROM OPENJSON(@PHOTOGRAPHS)
	--WITH(
	--	ID BIGINT '$.id',
	--	OIC BIGINT '$.oic',
	--	Path NVARCHAR(MAX) '$.path',
	--	Description NVARCHAR(MAX) '$.description',
	--	AddedDate DATE '$.addedDate'
	--)) TEMP
	--ON A.ID = TEMP.ID
	--WHEN MATCHED
	--THEN UPDATE
	--	SET
	--		A.[Path] = TEMP.[Path],
	--		A.Description = TEMP.Description,
	--		A.OIC = TEMP.OIC,
	--		A.AddedDate = TEMP.AddedDate
	--WHEN NOT MATCHED BY TARGET
	--THEN INSERT ([OIC], [Path], [Description], [AddedDate]) 
	--VALUES(@OIC,TEMP.[Path], TEMP.[Description], TEMP.[AddedDate])
	--WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	--THEN DELETE;
	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')

    MERGE [Photographs] p
	USING (SELECT OIC,[Path],AddedDate FROM OPENJSON(@PHOTOGRAPHS)
			 WITH(
					ID BIGINT '$.id',
					OIC BIGINT '$.aic',
					[Path] NVARCHAR(MAX) '$.path',
					AddedDate DATE '$.addedDate'
	             )
		  )PH
	   ON PH.[Path] = p.[Path]
	  AND (PH.OIC = p.OIC AND PH.[Path]=p.[Path])
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (OIC,[Path],AddedDate)
		 VALUES (@OIC,PH.[Path],getdate())
	WHEN NOT MATCHED BY SOURCE  AND OIC = @OIC 
	THEN DELETE;
	

	----GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS
	SET @POLITICALLINKS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'politicalLinks')
	MERGE [dbo].PoliticalLinks T
	USING (SELECT * FROM OPENJSON(@POLITICALLINKS)
	WITH(
		Relation BIGINT '$.relatedOIC'
	)) S
	ON T.OIC = @OIC AND T.LinkOIC = S.Relation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [LinkOIC]) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--select * from PoliticalLinks
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING PRESSES
	SET @PRESSES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'presses') 
	MERGE [dbo].Presses T
	USING (SELECT * FROM OPENJSON(@PRESSES)
	WITH(
			Relation BIGINT '$.relatedOIC'
		)) S
	ON T.OIC = @OIC AND T.PressesOIC = S.Relation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [PressesOIC] ) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE; 
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING PRESSES
	SET @PUBLICATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'publications')  

	MERGE [dbo].Publications T
	USING (SELECT * FROM OPENJSON(@PUBLICATIONS)
	WITH(
			Relation BIGINT '$.relatedOIC'
		)) S
	ON T.OIC = @OIC AND T.PublicationsOIC = S.Relation 
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [PublicationsOIC]) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--select * from Publications
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING RELATEDACTIVITIES
	SET @RELATEDACTIVITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities') 
	MERGE [dbo].RelatedActivities T
	USING (SELECT * FROM OPENJSON(@RELATEDACTIVITIES)
	WITH(
			Relation BIGINT '$.relatedAIC'
		)) S
	ON T.OIC = @OIC AND T.AIC = S.Relation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [AIC]) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--SELECT * FROM RelatedActivities
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING RELATEDORGANIZATIONS
	SET @RELATEDORGANIZATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedOrganizations') 
	MERGE [dbo].RelatedOrganizations T
	USING (SELECT * FROM OPENJSON(@RELATEDORGANIZATIONS)
	WITH( 
			Relation BIGINT '$.relatedOIC'
		)) S
	ON T.OIC = @OIC AND T.[RelatedOrganizations(OIC)] = S.Relation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [RelatedOrganizations(OIC)]) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--SELECT * FROM RelatedOrganizations
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING @SAFEHOUSES
	SET @SAFEHOUSES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'safeHouses') 
	MERGE [dbo].SafeHouses T
	USING (SELECT * FROM OPENJSON(@SAFEHOUSES)
	WITH( 
			SafeHousesOIC BIGINT '$.relatedOIC',
			FromDate DATETIME '$.fromDate',
			ToDate DATETIME '$.toDate'
		)) S
	ON T.OIC = @OIC AND T.SafeHousesOIC = S.SafeHousesOIC AND s.FromDate = T.FromDate AND s.ToDate = t.ToDate
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [SafeHousesOIC],FromDate,ToDate ) 
	VALUES(@OIC,S.SafeHousesOIC,S.FromDate,S.ToDate)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--SELECT * FROM SafeHouses
	
	
	
	----GET THE DATA FROM TEMP TABLE & UPDATING @SPLINTERGROUPS
	SET @SPLINTERGROUPS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'splinterGroups') 
	MERGE [dbo].SplinterGroups T
	USING (SELECT * FROM OPENJSON(@SPLINTERGROUPS)
	WITH(
			Relation BIGINT '$.relatedOIC'
		)) S
	ON T.OIC = @OIC AND T.SplinterGroupOIC = S.Relation 
	WHEN NOT MATCHED BY TARGET
	THEN INSERT ([OIC], [SplinterGroupOIC]) 
	VALUES(@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE AND OIC = @OIC
	THEN DELETE;
	--SELECT * FROM SplinterGroups
	
	
	--GET THE DATA FROM TEMP TABLE & UPDATING PRESIDEDOVERBY TABLE
	SET @VEHICLESOWNED = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'vehiclesOwned')

	MERGE [dbo].[VehiclesOwned] T
	USING (SELECT * FROM OPENJSON(@VEHICLESOWNED)
					WITH(
							Relation BIGINT '$.relatedIIC')
		 )  S
	ON  (@OIC = T.OIC)
	AND (S.Relation = T.IIC)

	WHEN NOT MATCHED BY TARGET
	THEN INSERT (OIC,IIC)
		 VALUES (@OIC,S.Relation)
	WHEN NOT MATCHED BY SOURCE  AND OIC = @OIC
	THEN DELETE;



	
	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')


	MERGE [DirectAndRoleWiseAccessRestrictions] T
	USING (SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
					WITH(
								OIC BIGINT '$.oic',
								DirectorOnly bit '$.directorOnly',
								DeskOfficerOnly bit '$.deskOfficerOnly')
		 )  S
	ON   (S.OIC = T.OIC)
	

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.DirectorOnly = S.DirectorOnly,
				T.DeskOfficerOnly = S.DeskOfficerOnly
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (OIC,DirectorOnly,DeskOfficerOnly)
		 VALUES (@OIC,S.DirectorOnly,S.DeskOfficerOnly)
	WHEN NOT MATCHED BY SOURCE  AND OIC = @OIC
	THEN DELETE;
	
	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @OIC

		SELECT @OIC
COMMIT TRANSACTION @TR_UPDATE_ORGANIZATION
END