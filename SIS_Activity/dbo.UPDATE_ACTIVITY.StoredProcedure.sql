USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_ACTIVITY]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_ACTIVITY](@JSON NVARCHAR(MAX))
AS
BEGIN

	--START -> DECLARING VARIABLES
	DECLARE @TR_UPDATE_ACTIVITY NVARCHAR(MAX)
	DECLARE @ACTIVEORGANIZERS NVARCHAR(MAX)
	DECLARE @ACTIVITYINFORMATION NVARCHAR(MAX)
	DECLARE @AVAILABLECDS NVARCHAR(MAX)
	DECLARE @DETAILOFSUSPECT NVARCHAR(MAX)
	DECLARE @DETAILSOFINSTRUCTORS NVARCHAR(MAX)
	DECLARE @DETAILSOFLOCALCONTACTS NVARCHAR(MAX)
	DECLARE @DETAILSOFVICTIMS NVARCHAR(MAX)
	DECLARE @FILEREFERENCES NVARCHAR(MAX)
	DECLARE @INCIDENTS NVARCHAR(MAX)
	DECLARE @INSTITUTIONSAFFECTED NVARCHAR(MAX)
	DECLARE @ITEMSDISMISS NVARCHAR(MAX)
	DECLARE @ITEMSUSED NVARCHAR(MAX)
	DECLARE @MAINSPEAKERS NVARCHAR(MAX)
	DECLARE @MODUSOPERANDI NVARCHAR(MAX)
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)
	DECLARE @NOOFINSTRUCTORS NVARCHAR(MAX)
	DECLARE @NOOFPERSONSPARTICIPATED NVARCHAR(MAX)
	DECLARE @NOOFVICTIMS NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX)
	DECLARE @PRESIDEDOVERBY NVARCHAR(MAX)
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX)
	DECLARE @RELATEDITEMS NVARCHAR(MAX)
	DECLARE @RELATEDORGANIZATION NVARCHAR(MAX)
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
	DECLARE @AIC BIGINT
	DECLARE @ACTIVITY TABLE (ID BIGINT)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	
	
	
	--END -> DECLARING VARIABLES


	BEGIN TRANSACTION @TR_UPDATE_ACTIVITY

	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

		--GET THE DATA FROM TEMP TABLE & UPDATING ACTIVITYINFORMATION TABLE
	SET @ACTIVITYINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'activityInformation')
	SET @AIC = (SELECT AIC FROM OPENJSON(@ACTIVITYINFORMATION) WITH(AIC BIGINT '$.aic'))

	UPDATE ORI
	SET ORI.TypeOfActivity=TEMP.TypeOfActivity,
	  ORI.MajorClassification = TEMP.MajorClassification,
	  ORI.MinorClassification = TEMP.MinorClassification,
	  ORI.DescriptionOfTheActivity = TEMP.DescriptionOfTheActivity,
	  ORI.StartDateTime = TEMP.StartDateTime,
	  ORI.EndDateTime = TEMP.EndDateTime,
	  ORI.Place = TEMP.Place,
	  ORI.Country = TEMP.Country,
	  ORI.AdministrativeDistrict=TEMP.AdministrativeDistrict,
	  ORI.PoliceStation = TEMP.PoliceStation,
	  ORI.Attendance = TEMP.Attendance,
	  ORI.OutCome = TEMP.OutCome,
	  ORI.GridLocationCode=TEMP.GridLocationCode,
	  ORI.GridRefName=TEMP.GridRefName
	
	FROM [dbo].[ActivityInformation] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@ACTIVITYINFORMATION)
	WITH(
		AIC BIGINT '$.aic',
		TypeOfActivity NVARCHAR(MAX) '$.typeOfActivity',
		MajorClassification NVARCHAR(MAX) '$.majorClassification',
		MinorClassification NVARCHAR(MAX) '$.minorClassification',
		DescriptionOfTheActivity NVARCHAR(MAX) '$.descriptionOfTheActivity',
		StartDateTime DATETIME '$.startDateTime',
		EndDateTime DATETIME '$.endDateTime',
		Place NVARCHAR(MAX) '$.place',
		Country NVARCHAR(MAX) '$.country',
		AdministrativeDistrict NVARCHAR(MAX) '$.administrativeDistrict',
		PoliceStation NVARCHAR(MAX) '$.policeStation',
		Attendance NVARCHAR(MAX) '$.attendance',
	    OutCome NVARCHAR(MAX) '$.outCome',
		GridLocationCode NVARCHAR(MAX) '$.gridLocationCode',
		GridRefName NVARCHAR(MAX) '$.gridRefName'

	)) TEMP
	ON ORI.AIC = TEMP.AIC
	WHERE ORI.AIC = TEMP.AIC


	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDORGANIZATION TABLE
	SET @RELATEDORGANIZATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedOrganizations')

	MERGE [RelatedOrganization] T
	USING (SELECT * FROM OPENJSON(@RELATEDORGANIZATION)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.iic',
						OIC BIGINT '$.oic',
						OrganizationCatagory NVARCHAR(MAX) '$.organizationCatagory')
		 )  S
	ON  (S.OIC= T.OIC)
	AND (S.AIC = T.AIC)
	AND (S.ID = T.ID)

	
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,OIC,OrganizationCatagory)
		 VALUES (@AIC,S.OIC,S.OrganizationCatagory)
	WHEN NOT MATCHED BY SOURCE AND AIC = @AIC 
	THEN DELETE;



	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDACTIVITIES TABLE
	SET @RELATEDACTIVITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities')

	MERGE [RelatedActivities] T
	USING (SELECT * FROM OPENJSON(@RELATEDACTIVITIES)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						[RelatedActivity(AIC)] BIGINT '$.relatedActivityAIC')
		 )  S
	ON  (S.[RelatedActivity(AIC)] = T.[RelatedActivity(AIC)])
	AND (S.AIC = T.AIC)
	AND (S.ID = T.ID)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[RelatedActivity(AIC)] = S.[RelatedActivity(AIC)]
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,[RelatedActivity(AIC)])
		 VALUES (@AIC,S.[RelatedActivity(AIC)])
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING NOOFVICTIMS TABLE
    SET @NOOFVICTIMS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'noOfVictims')

	MERGE [NoOfVictims] T
	USING (SELECT * FROM OPENJSON(@NOOFVICTIMS)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						Category NVARCHAR(MAX) '$.category',
						Race NVARCHAR(MAX) '$.race',
						[Status] NVARCHAR(MAX) '$.status',
						Number NVARCHAR(MAX) '$.number',
						Organization NVARCHAR(MAX) '$.organization')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.Category = S.Category,
				T.Race = S.Race,
				T.[Status] = S.[Status],
				T.Number = S.Number,
				T.Organization = S.Organization
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,Category,Race,[Status],Number,Organization)
		 VALUES (@AIC,S.Category,S.Race,S.[Status],S.Number,S.Organization)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	----GET THE DATA FROM TEMP TABLE & UPDATING DETAILSOFVICTIMS TABLE
    SET @DETAILSOFVICTIMS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfVictims')

	MERGE [dbo].[DetailsOfVictims] T
	USING (SELECT * FROM OPENJSON(@DETAILSOFVICTIMS)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						PIC BIGINT '$.pic',
						Name NVARCHAR(MAX) '$.name',
						Category NVARCHAR(MAX) '$.category',
						Race NVARCHAR(MAX) '$.race',
						[Rank] NVARCHAR(MAX) '$.rank',
						Organization NVARCHAR(MAX) '$.organization',
						[Status] NVARCHAR(MAX) '$.status',
						NativePlace NVARCHAR(MAX) '$.nativePlace')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)
	AND (s.ID = T.ID)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.AIC = S.AIC,
				T.PIC = S.PIC,
				T.Name = S.Name,
				T.Category = S.Category,
				T.Race = S.Race,
				T.[Rank] =S.[Rank],
				T.Organization = S.Organization,
				T.[Status] = S.[Status],
				T.NativePlace = S.NativePlace

	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC,Name,Category,Race,[Rank],Organization,[Status],NativePlace)
		 VALUES (@AIC,S.PIC,S.Name,S.Category,S.Race,S.[Rank],S.Organization,S.[Status],S.NativePlace)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;



	--GET THE DATA FROM TEMP TABLE & UPDATING INSTITUTIONSAFFECTED TABLE
    SET @INSTITUTIONSAFFECTED = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'institutionsAffecteds')

	MERGE [dbo].[InstitutionsAffected] T
	USING (SELECT * FROM OPENJSON(@INSTITUTIONSAFFECTED)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						NameofInstitution NVARCHAR(MAX) '$.nameofInstitution',
						MajorType NVARCHAR(MAX) '$.majorType',
						MinorType NVARCHAR(MAX) '$.minorType',
						HowAffected NVARCHAR(MAX) '$.howAffected',
						Place NVARCHAR(MAX) '$.place')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET   
				T.NameofInstitution = S.NameofInstitution,
				T.MajorType = S.MajorType,
				T.MinorType = S.MinorType,
				T.HowAffected =S.HowAffected,
				T.Place = S.Place

	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,NameofInstitution,MajorType,MinorType,HowAffected,Place)
		 VALUES (@AIC,S.NameofInstitution,S.MajorType,S.MinorType,S.HowAffected,S.Place)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;



	--GET THE DATA FROM TEMP TABLE & UPDATING INSTITUTIONSAFFECTED TABLE
    SET @DETAILOFSUSPECT = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfSuspects')

	MERGE [dbo].[DetailOfSuspect] T
	USING (SELECT * FROM OPENJSON(@DETAILOFSUSPECT)
					WITH(
								AIC BIGINT '$.aic',
								PIC BIGINT '$.pic',
								[Status]  NVARCHAR(MAX) '$.status')
		 )  S
	ON  (S.PIC = T.PIC) AND (S.AIC = T.AIC) AND (S.[Status] = T.[Status])

	WHEN MATCHED 
		 THEN UPDATE
		 SET  
				T.[Status] = S.[Status]
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC,[Status])
		 VALUES (@AIC,S.PIC,S.[Status])
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING DETAILSOFLOCALCONTACTS TABLE
	SET @DETAILSOFLOCALCONTACTS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfLocalContacts')

	MERGE [DetailsOfLocalContacts] T
	USING (SELECT * FROM OPENJSON(@DETAILSOFLOCALCONTACTS)
					WITH(
								AIC BIGINT '$.aic',
								PIC BIGINT '$.pic')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)


	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC)
		 VALUES (@AIC,S.PIC)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING FILEREFERENCES TABLE

	SET @NOOFINSTRUCTORS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'noOfInstructors')

	MERGE [NoOfInstructors] T
	USING (SELECT * FROM OPENJSON(@NOOFINSTRUCTORS)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								Country NVARCHAR(MAX) '$.country',
								Number NVARCHAR(MAX) '$.number')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.Country = S.Country,
		        T.Number=S.Number
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,Country,Number)
		 VALUES (@AIC,S.Country,S.Number)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING DETAILSOFINSTRUCTORS TABLE
	SET @DETAILSOFINSTRUCTORS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfInstructors')

	MERGE [DetailsOfInstructors] T
	USING (SELECT * FROM OPENJSON(@DETAILSOFINSTRUCTORS)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								PIC BIGINT '$.pic',
								Country NVARCHAR(MAX) '$.country')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.Country = S.Country
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC,Country)
		 VALUES (@AIC,S.PIC,S.Country)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;




--GET THE DATA FROM TEMP TABLE & UPDATING ITEMSDISMISS TABLE
	SET @ITEMSDISMISS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'itemsDismisseds')

	MERGE [ItemsDismiss] T
	USING (SELECT * FROM OPENJSON(@ITEMSDISMISS)
					WITH(
									ID BIGINT '$.id',
									AIC BIGINT '$.aic',
									IIC BIGINT '$.iic',
									Category NVARCHAR(MAX) '$.category',
									[Description] NVARCHAR(MAX) '$.description',
									Number NVARCHAR(MAX) '$.number'
									)
									
		 )  S
	ON  (S.IIC = T.IIC)
	AND (S.AIC = T.AIC)
	AND (S.ID = T.ID)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.AIC = S.AIC,
				T.IIC = S.IIC,
				T.Category = S.Category,
				T.[Description] =S.[Description],
				t.Number = s.Number
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,IIC,Category,[Description],Number)
		 VALUES (@AIC,S.IIC,S.Category,S.[Description], S.Number)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING ITEMSUSED TABLE
	SET @ITEMSUSED = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'itemsUseds')
	MERGE [ItemsUsed] T
	USING (SELECT * FROM OPENJSON(@ITEMSUSED)
					WITH(
									AIC BIGINT '$.aic',
									IIC BIGINT '$.iic',
									MajorType NVARCHAR(MAX) '$.majorType',
									MinorType NVARCHAR(MAX) '$.minorType',
									Number NVARCHAR(MAX) '$.number',
									[Description] NVARCHAR(MAX) '$.description')
		 )  S
	ON  (S.IIC = T.IIC)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.AIC = S.AIC,
				T.IIC = S.IIC,
				T.MajorType = S.MajorType,
				T.MinorType = S.MinorType,
				T.Number = S.Number,
				T.[Description] =S.[Description]
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,IIC,MajorType,MinorType,Number,[Description])
		 VALUES (@AIC,S.IIC,S.MajorType,S.MinorType,S.Number,S.[Description])
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;

	


		--GET THE DATA FROM TEMP TABLE & UPDATING PRESIDEDOVERBY TABLE
	SET @PRESIDEDOVERBY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'presidedOverBys')

	MERGE [PresidedOverBy] T
	USING (SELECT * FROM OPENJSON(@PRESIDEDOVERBY)
					WITH(
							AIC BIGINT '$.aic',
							PIC BIGINT '$.pic')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)


	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC)
		 VALUES (@AIC,S.PIC)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;



   --GET THE DATA FROM TEMP TABLE & UPDATING MAINSPEAKERS TABLE
	SET @MAINSPEAKERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'mainSpeakers')

	MERGE [MainSpeakers] T
	USING (SELECT * FROM OPENJSON(@MAINSPEAKERS)
					WITH(
								AIC BIGINT '$.aic',
								PIC BIGINT '$.pic',
								[Name] NVARCHAR(MAX) '$.name')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)


	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC,[Name])
		 VALUES (@AIC,S.PIC,S.[Name])
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	----GET THE DATA FROM TEMP TABLE & UPDATING INCIDENTS TABLE
	SET @INCIDENTS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'incidents')

	MERGE [Incidents] T
	USING (SELECT * FROM OPENJSON(@INCIDENTS)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								Incident NVARCHAR(MAX) '$.incident')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.Incident = S.Incident
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,Incident)
		 VALUES (@AIC,S.Incident)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING MODUSOPERANDI TABLE
	SET @MODUSOPERANDI = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'modusOperandi')

	MERGE [ModusOperandi] T
	USING (SELECT * FROM OPENJSON(@MODUSOPERANDI)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								ModusOperandi NVARCHAR(MAX) '$.modusOperandi')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.ModusOperandi = S.ModusOperandi
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,ModusOperandi)
		 VALUES (@AIC,S.ModusOperandi)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING AVAILABLECDS TABLE
	SET @AVAILABLECDS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'availableCDs')
	
	MERGE [AvailableCDs] T
	USING (SELECT * FROM OPENJSON(@AVAILABLECDS)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						Category NVARCHAR(MAX) '$.category',
						ReferenceNo NVARCHAR(MAX) '$.referenceNo')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.Category = S.Category,
				T.ReferenceNo = S.ReferenceNo
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,Category,ReferenceNo)
		 VALUES (@AIC,S.Category,S.ReferenceNo)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;




	--GET THE DATA FROM TEMP TABLE & UPDATING NOOFPERSONSPARTICIPATED TABLE
	SET @NOOFPERSONSPARTICIPATED = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'noOfPersonsParticipateds')
	
	MERGE [NoOfPersonsParticipated] T
	USING (SELECT * FROM OPENJSON(@NOOFPERSONSPARTICIPATED)
					WITH(
						ID BIGINT '$.id',
						AIC BIGINT '$.aic',
						[Category] NVARCHAR(MAX) '$.category',
						[Date] DATE '$.date',
						Number NVARCHAR(50) '$.number')
						
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[Date] = S.[Date],
				T.Number = S.Number,
				T.Category =S.Category
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,[Date],Number,Category)
		 VALUES (@AIC,S.[Date],S.Number,S.Category)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;



	--GET THE DATA FROM TEMP TABLE & UPDATING ACTIVEORGANIZERS TABLE
	SET @ACTIVEORGANIZERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'activeOrganizers')

	MERGE [ActiveOrganizers] T
	USING (SELECT * FROM OPENJSON(@ACTIVEORGANIZERS)
					WITH(
								AIC BIGINT '$.aic',
								PIC BIGINT '$.pic')
		 )  S
	ON  (S.PIC = T.PIC)
	AND (S.AIC = T.AIC)


	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,PIC)
		 VALUES (@AIC,S.PIC)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;

	
	--GET THE DATA FROM TEMP TABLE & UPDATING NARRATIVEINFORMATION TABLE

	SET @NARRATIVEINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformations')

	MERGE [NarrativeInformation] T
	USING (SELECT * FROM OPENJSON(@NARRATIVEINFORMATION)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								[Date] DATETIME '$.date',
								Information NVARCHAR(MAX) '$.information',
								FileReferenceNo NVARCHAR(MAX) '$.fileReferenceNo')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[Date] = S.[Date],
				T.Information = S.Information,
				T.FileReferenceNo= S.FileReferenceNo
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,[Date],Information,FileReferenceNo)
		 VALUES (@AIC,S.[Date],S.Information,S.FileReferenceNo)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING FILEREFERENCES TABLE

	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')

	MERGE [FileReferences] T
	USING (SELECT * FROM OPENJSON(@FILEREFERENCES)
					WITH(
								ID BIGINT '$.id',
								AIC BIGINT '$.aic',
								FileReference NVARCHAR(MAX) '$.fileReference')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.AIC = T.AIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.FileReference = S.FileReference
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,FileReference)
		 VALUES (@AIC,S.FileReference)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;



	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')

    MERGE [Photographs] p
	USING (SELECT AIC,[Path],AddedDate FROM OPENJSON(@PHOTOGRAPHS)
			 WITH(
					ID BIGINT '$.id',
					AIC BIGINT '$.aic',
					[Path] NVARCHAR(MAX) '$.path',
					AddedDate DATE '$.addedDate'
	             )
		  )PH
	   ON PH.[Path] = p.[Path]
	  AND (PH.AIC = p.AIC AND PH.[Path]=p.[Path])
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,[Path],AddedDate)
		 VALUES (@AIC,PH.[Path],getdate())
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC 
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	
	UPDATE ORI
	SET --ORI.EnteredUserName = TEMP.EnteredUserName,
		ORI.LastModifieduserName = TEMP.LastModifieduserName,
		ORI.LastModifiedDate = getdate(),
		ORI.DeskTarget = TEMP.DeskTarget,
		ORI.[Subject] = TEMP.[Subject]
	FROM [dbo].[SystemDetails] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@SYSTEMDETAILS)
	WITH(
		AIC BIGINT '$.aic',
		--EnteredUserName NVARCHAR(MAX) '$.enteredUserName',
		LastModifieduserName NVARCHAR(MAX) '$.lastModifiedUserName',
		LastModifiedDate DATE '$.lastModifiedDate',
		DeskTarget NVARCHAR(MAX) '$.deskTarget',
		[Subject] NVARCHAR(MAX) '$.subject'
	)) TEMP
	ON ORI.AIC = @AIC 
	WHERE ORI.AIC =  @AIC 


	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')


	MERGE [DirectAndRoleWiseAccessRestrictions] T
	USING (SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
					WITH(
								AIC BIGINT '$.aic',
								DirectorOnly bit '$.directorOnly',
								DeskOfficerOnly bit '$.deskOfficerOnly')
		 )  S
	ON   (S.AIC = T.AIC)
	

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.DirectorOnly = S.DirectorOnly,
				T.DeskOfficerOnly = S.DeskOfficerOnly
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (AIC,DirectorOnly,DeskOfficerOnly)
		 VALUES (@AIC,S.DirectorOnly,S.DeskOfficerOnly)
	WHEN NOT MATCHED BY SOURCE  AND AIC = @AIC
	THEN DELETE;

	
EXEC [dbo].[UPDATE_INFERENCE_RELATIONSHIPS] @AIC
COMMIT TRANSACTION @TR_UPDATE_ACTIVITY
END
GO
