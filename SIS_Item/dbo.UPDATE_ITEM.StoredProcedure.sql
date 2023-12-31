USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_ITEM]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_ITEM](@JSON NVARCHAR(MAX))
AS
BEGIN

	--START -> DECLARING VARIABLES
	DECLARE @TR_UPDATE_ITEM NVARCHAR(MAX)
	DECLARE @DETAILSOFOWNER NVARCHAR(MAX)
	DECLARE @DETAILSOFRECOVERY NVARCHAR(MAX)
	DECLARE @FILEREFERENCES NVARCHAR(MAX)
	DECLARE @ITEMINFORMATION NVARCHAR(MAX)
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX)
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX)
	DECLARE @RELATEDITEMS NVARCHAR(MAX)
	DECLARE @RELATEDPEOPLES NVARCHAR(MAX)
	DECLARE @RELATEDORGANIZATION NVARCHAR(MAX)
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
	DECLARE @IDENTIFYINGNUMBERS NVARCHAR(MAX)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	
	
	DECLARE @IIC BIGINT
	--END -> DECLARING VARIABLES
 
    BEGIN TRANSACTION; 

	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	--GET THE DATA FROM TEMP TABLE & UPDATING ITEMINFORMATION TABLE
	SET @ITEMINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'itemInformation')
	SET @IIC = (SELECT IIC FROM OPENJSON(@ITEMINFORMATION) WITH(IIC BIGINT '$.iic'))

	UPDATE ORI
	SET ORI.TypeOfItem = TEMP.TypeOfItem,
		ORI.SubClassificationI = TEMP.SubClassificationI,
		ORI.SubClassificationII = TEMP.SubClassificationII,
		ORI.DescriptionOfItem = TEMP.DescriptionOfItem,
		ORI.Model = TEMP.Model,
		ORI.Make = TEMP.Make,
		ORI.MainIdentifyingNumber = TEMP.MainIdentifyingNumber,
		ORI.CountryOfManufacture = TEMP.CountryOfManufacture,
		ORI.Quantity = TEMP.Quantity,
		ORI.AmountOrValue = TEMP.AmountOrValue
	FROM [dbo].[ItemInformation] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@ITEMINFORMATION)
	WITH(
		IIC BIGINT '$.iic',
		TypeOfItem NVARCHAR(MAX) '$.typeOfItem',
		SubClassificationI NVARCHAR(MAX) '$.subClassificationI',
		SubClassificationII NVARCHAR(MAX) '$.subClassificationII',
		DescriptionOfItem NVARCHAR(MAX) '$.descriptionOfItem',
		Model NVARCHAR(MAX) '$.model',
		Make NVARCHAR(MAX) '$.make',
		MainIdentifyingNumber NVARCHAR(MAX) '$.mainIdentifyingNumber',
		CountryOfManufacture NVARCHAR(MAX) '$.countryOfManufacture',
		Quantity NVARCHAR(MAX) '$.quantity',
		AmountOrValue NVARCHAR(MAX) '$.amountOrValue'
	)) TEMP
	ON ORI.IIC = TEMP.IIC
	WHERE ORI.IIC = TEMP.IIC

	--GET THE DATA FROM TEMP TABLE & UPDATING DETAILSOFOWNER TABLE
	SET @DETAILSOFOWNER = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfOwners')

	MERGE [DetailsOfOwner] T
	USING (SELECT * FROM OPENJSON(@DETAILSOFOWNER)
					WITH(
						ID BIGINT '$.id',
						IIC BIGINT '$.iic',
						PIC BIGINT '$.pic',
						Information NVARCHAR(MAX) '$.information',
						[FromDate] DATETIME '$.fromDate',
						[ToDate] DATETIME '$.toDate')
		 )  S
	ON (S.ID = T.ID)
	AND  (S.IIC = T.IIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.PIC = S.PIC ,
				T.Information =S.Information,
				T.[FromDate] =S.[FromDate],
				T.[ToDate] =S.[ToDate]
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,PIC,Information,[FromDate],[ToDate])
		 VALUES (@IIC,S.PIC,S.Information,S.[FromDate],S.[ToDate])
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;

	--GET THE DATA FROM TEMP TABLE & UPDATING DETAILSOFRECOVERY TABLE
	SET @DETAILSOFRECOVERY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfRecoveries')

	MERGE [DetailsOfRecovery] T
	USING (SELECT * FROM OPENJSON(@DETAILSOFRECOVERY)
					WITH(
								ID BIGINT '$.id',
								IIC BIGINT '$.iic',
								[Date] DATE '$.date',
								Place NVARCHAR(MAX) '$.place',
								Country NVARCHAR(MAX) '$.country',
								PoliceStation NVARCHAR(MAX) '$.policeStation')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.IIC = T.IIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[Date] = S.[Date],
				T.Place = S.Place,
				T.Country= S.Country,
				T.PoliceStation= T.PoliceStation
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,[Date], Place,Country,PoliceStation)
		 VALUES (@IIC,S.[Date], S.Place,S.Country, S.PoliceStation)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;

	--GET THE DATA FROM TEMP TABLE & UPDATING FILEREFERENCES TABLE

	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')

	MERGE [FileReferences] T
	USING (SELECT * FROM OPENJSON(@FILEREFERENCES)
					WITH(
								ID BIGINT '$.id',
								IIC BIGINT '$.iic',
								FileReference NVARCHAR(MAX) '$.fileReference')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.IIC = T.IIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.FileReference = S.FileReference
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,FileReference)
		 VALUES (@IIC,S.FileReference)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING NARRATIVEINFORMATION TABLE

	SET @NARRATIVEINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformations')

	MERGE [NarrativeInformation] T
	USING (SELECT * FROM OPENJSON(@NARRATIVEINFORMATION)
					WITH(
								ID BIGINT '$.id',
								IIC BIGINT '$.iic',
								[Date] DATETIME '$.date',
							    Information NVARCHAR(MAX) '$.information',
								FileReferenceNumber NVARCHAR(MAX) '$.fileReferenceNumber')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.IIC = T.IIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[Date] = S.[Date],
				T.Information = S.Information,
				T.FileReferenceNumber= S.FileReferenceNumber
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,[Date],Information,FileReferenceNumber)
		 VALUES (@IIC,S.[Date],S.Information,S.FileReferenceNumber)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')

    MERGE [Photographs] p
	USING (SELECT IIC,[Path],AddedDate FROM OPENJSON(@PHOTOGRAPHS)
			 WITH(
					ID BIGINT '$.id',
					IIC BIGINT '$.aic',
					[Path] NVARCHAR(MAX) '$.path',
					AddedDate DATE '$.addedDate'
	             )
		  )PH
	   ON PH.[Path] = p.[Path]
	  AND (PH.IIC = p.IIC AND PH.[Path]=p.[Path])
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,[Path],AddedDate)
		 VALUES (@IIC,PH.[Path],getdate())
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC 
	THEN DELETE;

	--GET THE DATA FROM TEMP TABLE & UPDATING SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	
	UPDATE ORI
	SET ORI.LastModifieduserName = TEMP.LastModifieduserName,
		ORI.LastModifiedDate = GETDATE() ,
		ORI.DeskTarget = TEMP.DeskTarget,
		ORI.[Subject] = TEMP.[Subject]
	FROM [dbo].[SystemDetails] ORI
		 INNER JOIN
	(SELECT * FROM OPENJSON(@SYSTEMDETAILS)
	WITH(
		IIC BIGINT '$.iic',
		LastModifieduserName NVARCHAR(MAX) '$.lastModifieduserName',
		DeskTarget NVARCHAR(MAX) '$.deskTarget',
		[Subject] NVARCHAR(MAX) '$.subject'
	)) TEMP
	ON ORI.IIC = TEMP.IIC
	WHERE ORI.IIC = TEMP.IIC 



	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDACTIVITIES TABLE
	SET @RELATEDACTIVITIES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities')

	MERGE [RelatedActivity] T
	USING (SELECT * FROM OPENJSON(@RELATEDACTIVITIES)
					WITH(
						ID BIGINT '$.id',
						IIC BIGINT '$.iic',
						AIC BIGINT '$.aic',
						[Type]  NVARCHAR(MAX) '$.type',
						[Description] NVARCHAR(MAX) '$.description')
		 )  S
	ON  (S.AIC = T.AIC)
	AND (S.IIC = T.IIC)
	AND (S.ID = T.ID)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.[Type] = S.[Type],
				T.[Description] = S.[Description]
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,AIC,[Type], [Description])
		 VALUES (@IIC,S.AIC,S.[Type], S.[Description])
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDITEMS TABLE
	SET @RELATEDITEMS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedItems')

	MERGE [RelatedItem] T
	USING (SELECT * FROM OPENJSON(@RELATEDITEMS)
					WITH(
						ID BIGINT '$.id',
						IIC BIGINT '$.iic',
						[RelatedItems(IIC)] BIGINT '$.relatedItemsIIC')
		 )  S
	ON  (S.[RelatedItems(IIC)] = T.[RelatedItems(IIC)])
	AND (S.IIC = T.IIC)
	AND (S.ID = T.ID)

	
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,[RelatedItems(IIC)])
		 VALUES (@IIC,S.[RelatedItems(IIC)])
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDITEMS TABLE
	SET @RELATEDPEOPLES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedPersons')

	MERGE [RelatedPersons] T
	USING (SELECT * FROM OPENJSON(@RELATEDPEOPLES)
					WITH(
						ID BIGINT '$.id',
						IIC BIGINT '$.iic',
						PIC BIGINT '$.pic')
		 )  S
	ON  (S.PIC= T.PIC)
	AND (S.IIC = T.IIC)
	AND (S.ID = T.ID)

	
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,PIC)
		 VALUES (@IIC,S.PIC)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING RELATEDITEMS TABLE
	SET @RELATEDORGANIZATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'organizationInfos')

	MERGE [RelatedOrganizations] T
	USING (SELECT * FROM OPENJSON(@RELATEDORGANIZATION)
					WITH(
						ID BIGINT '$.id',
						IIC BIGINT '$.iic',
						OIC BIGINT '$.oic')
		 )  S
	ON  (S.OIC= T.OIC)
	AND (S.IIC = T.IIC)

	
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,OIC)
		 VALUES (@IIC,S.OIC)
	WHEN NOT MATCHED BY SOURCE AND IIC = @IIC 
	THEN DELETE;


	--GET THE DATA FROM TEMP TABLE & UPDATING IDENTIFYINGNUMBERS TABLE
	SET @IDENTIFYINGNUMBERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'identifyingNos')

	MERGE [OtherIdentifyingNumbers] T
	USING (SELECT * FROM OPENJSON(@IDENTIFYINGNUMBERS)
					WITH(
								ID BIGINT '$.id',
								IIC BIGINT '$.iic',
								IdentifyingNumber NVARCHAR(MAX) '$.identifyingNumber')
		 )  S
	ON  (S.ID = T.ID)
	AND (S.IIC = T.IIC)

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.IdentifyingNumber = S.IdentifyingNumber
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,IdentifyingNumber)
		 VALUES (@IIC,S.IdentifyingNumber)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;


		
	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')


	MERGE [DirectAndRoleWiseAccessRestrictions] T
	USING (SELECT * FROM OPENJSON(@ACCESSRESTRICTIONS)
					WITH(
								IIC BIGINT '$.iic',
								DirectorOnly bit '$.directorOnly',
								DeskOfficerOnly bit '$.deskOfficerOnly')
		 )  S
	ON   (S.IIC = T.IIC)
	

	WHEN MATCHED 
		 THEN UPDATE
		 SET    T.DirectorOnly = S.DirectorOnly,
				T.DeskOfficerOnly = S.DeskOfficerOnly
	WHEN NOT MATCHED BY TARGET
	THEN INSERT (IIC,DirectorOnly,DeskOfficerOnly)
		 VALUES (@IIC,S.DirectorOnly,S.DeskOfficerOnly)
	WHEN NOT MATCHED BY SOURCE  AND IIC = @IIC
	THEN DELETE;

	
	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @IIC

	COMMIT TRANSACTION;  
END
GO
