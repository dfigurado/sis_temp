USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_ITEM]    Script Date: 7/26/2023 4:40:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CREATE_ITEM](@JSON NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;

	--START -> DECLARING VARIABLES
	DECLARE @TR_CREATE_ITEM NVARCHAR(MAX)
	DECLARE @DETAILSOFOWNER NVARCHAR(MAX)
	DECLARE @DETAILSOFRECOVERY NVARCHAR(MAX)
	DECLARE @FILEREFERENCES NVARCHAR(MAX)
	DECLARE @ITEMINFORMATION NVARCHAR(MAX)
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX)
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
	DECLARE @RELATEDACTIVITY NVARCHAR(MAX)
	DECLARE @RELATEDITEM NVARCHAR(MAX)
	DECLARE @RELATEDORGANIZATIONS NVARCHAR(MAX)
	DECLARE @RELATEDPERSONS NVARCHAR(MAX)
	DECLARE @IDENTIFYINGNUMBERS NVARCHAR(MAX)
	DECLARE @ACCESSRESTRICTIONS NVARCHAR(MAX)
	
	DECLARE @IIC BIGINT
	DECLARE @DESCRIPTION NVARCHAR(MAX)
	DECLARE @ITEM TABLE (ID BIGINT)
	DECLARE @DES TABLE (DESCRIPTION NVARCHAR(MAX))
	--END -> DECLARING VARIABLES


	BEGIN TRANSACTION @TR_CREATE_ITEM

	--INSERTING JSON ARRAY TO TEMP TABLE
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO ITEMINFORMATION TABLE
	SET @ITEMINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'itemInformation')
	INSERT INTO [dbo].[ItemInformation](TypeOfItem, SubClassificationI, SubClassificationII, DescriptionOfItem, Model, Make, CountryOfManufacture, Quantity, AmountOrValue ,Measurement ,MainIdentifyingNumber)
	OUTPUT INSERTED.IIC INTO @ITEM
	SELECT * FROM OPENJSON(@ITEMINFORMATION)
	WITH(
		TypeOfItem NVARCHAR(MAX) '$.typeOfItem',
		SubClassificationI NVARCHAR(MAX) '$.subClassificationI',
		SubClassificationII NVARCHAR(MAX) '$.subClassificationII',
		DescriptionOfItem NVARCHAR(MAX) '$.descriptionOfItem',
		Model NVARCHAR(MAX) '$.model',
		Make NVARCHAR(MAX) '$.make',
		CountryOfManufacture NVARCHAR(MAX) '$.countryOfManufacture',
		Quantity NVARCHAR(MAX) '$.quantity',
		AmountOrValue NVARCHAR(MAX) '$.amountOrValue',
		Measurement NVARCHAR(MAX) '$.measurement',
		MainIdentifyingNumber NVARCHAR(MAX) '$.mainIdentifyingNumber'
	)

	SET @IIC = (SELECT TOP 1 ID FROM @ITEM)
	INSERT INTO @DES
	SELECT * FROM OPENJSON(@ITEMINFORMATION) WITH(DescriptionOfItem NVARCHAR(MAX) '$.descriptionOfItem')
	SET @DESCRIPTION=(SELECT TOP 1 DESCRIPTION FROM @DES )

	--GET THE DATA FROM TEMP TABLE & INSERTING TO DETAILSOFOWNER TABLE
	SET @DETAILSOFOWNER = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfOwners')
	INSERT INTO [dbo].[DetailsOfOwner](IIC, PIC,Information,[FromDate],[ToDate])
	SELECT @IIC,* FROM OPENJSON(@DETAILSOFOWNER)
	WITH(
		PIC BIGINT '$.pic',
		Information NVARCHAR(MAX) '$.information',
		[FromDate] DATETIME '$.fromDate',
		[ToDate] DATETIME '$.toDate'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO DETAILSOFRECOVERY TABLE
	SET @DETAILSOFRECOVERY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'detailsOfRecoveries')
	INSERT INTO [dbo].[DetailsOfRecovery](IIC,[Date], Place,Country ,PoliceStation)
	SELECT @IIC,* FROM OPENJSON(@DETAILSOFRECOVERY)
	WITH(
		[Date] DATE '$.date',
		Place NVARCHAR(MAX) '$.place',
		Country NVARCHAR(MAX) '$.country',
		PoliceStation NVARCHAR(MAX) '$.policeStation'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO FILEREFERENCES TABLE
	SET @FILEREFERENCES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'fileReferences')
	INSERT INTO [dbo].[FileReferences](IIC, FileReference)
	SELECT @IIC,* FROM OPENJSON(@FILEREFERENCES)
	WITH(
		--IIC BIGINT '$.iic',
		FileReference NVARCHAR(MAX) '$.fileReference'
	)
	--GET THE DATA FROM TEMP TABLE & INSERTING TO IDENTIFYINGNUMBERS TABLE
	SET @IDENTIFYINGNUMBERS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'identifyingNos')
	INSERT INTO [dbo].[OtherIdentifyingNumbers](IIC,IdentifyingNumber)
	SELECT @IIC,* FROM OPENJSON(@IDENTIFYINGNUMBERS)
	WITH(
		IdentifyingNumber NVARCHAR(MAX) '$.identifyingNumber'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO NARRATIVEINFORMATION TABLE
	SET @NARRATIVEINFORMATION = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'narrativeInformations')
	INSERT INTO [dbo].[NarrativeInformation](IIC, [Date], Information,FileReferenceNumber)
	SELECT @IIC,* FROM OPENJSON(@NARRATIVEINFORMATION)
	WITH(
		[Date] DATE '$.date',
		Information NVARCHAR(MAX) '$.information',
		FileReferenceNumber NVARCHAR(MAX) '$.fileReferenceNumber'
	)


	--GET THE DATA FROM TEMP TABLE & INSERTING TO PHOTOGRAPHS TABLE
	SET @PHOTOGRAPHS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'photographs')
	INSERT INTO [dbo].[Photographs](IIC, [Path], [Description], AddedDate)
	SELECT @IIC,*,GETDATE() FROM OPENJSON(@PHOTOGRAPHS)
	WITH(
		[Path] NVARCHAR(MAX) '$.path',
		[Description] NVARCHAR(MAX) '$.description'
	) 
	--GET THE DATA FROM TEMP TABLE & INSERTING TO SYSTEMDETAILS TABLE
	SET @SYSTEMDETAILS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'systemDetails')
	INSERT INTO [dbo].[SystemDetails](IIC, EnteredUserName, LastModifieduserName, DeskTarget,[Subject], EnteredDate)
	SELECT @IIC,*,getdate() FROM OPENJSON(@SYSTEMDETAILS)
	WITH(
		EnteredUserName NVARCHAR(MAX) '$.enteredUserName', 
		LastModifieduserName NVARCHAR(MAX) '$.lastModifieduserName',
		DeskTarget NVARCHAR(MAX) '$.deskTarget',
		[Subject] NVARCHAR(MAX) '$.subject'
	)


	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATEDACTIVITY TABLE
	SET @RELATEDACTIVITY = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedActivities')
	INSERT INTO [dbo].[RelatedActivity](IIC, AIC, [Description],[Type])
	SELECT @IIC,* FROM OPENJSON(@RELATEDACTIVITY)
	WITH(
		AIC BIGINT '$.aic',
		[Description]  NVARCHAR(MAX) '$.description',
		[Type] NVARCHAR(MAX) '$.type'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATEDITEM TABLE
	SET @RELATEDITEM = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedItems')
	INSERT INTO [dbo].[RelatedItem](IIC, [RelatedItems(IIC)])
	SELECT @IIC,* FROM OPENJSON(@RELATEDITEM)
	WITH(
		--IIC BIGINT '$.iic',
		[RelatedItems(IIC)]  NVARCHAR(MAX) '$.relatedItemsIIC'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATEDORGANIZATIONS TABLE
	SET @RELATEDORGANIZATIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'organizationInfos')
	INSERT INTO [dbo].[RelatedOrganizations](IIC, OIC)
	SELECT @IIC,* FROM OPENJSON(@RELATEDORGANIZATIONS)
	WITH(
		--IIC BIGINT '$.iic',
		OIC NVARCHAR(MAX) '$.oic'
	)

	--GET THE DATA FROM TEMP TABLE & INSERTING TO RELATEDPERSONS TABLE
	SET @RELATEDPERSONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'relatedPersons')
	INSERT INTO [dbo].[RelatedPersons](IIC, PIC)
	SELECT @IIC,* FROM OPENJSON(@RELATEDPERSONS)
	WITH(
		--IIC BIGINT '$.iic',
		PIC NVARCHAR(MAX) '$.pic'
	)

	
	SET @ACCESSRESTRICTIONS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'rolewiseAccessRestrictions')
	INSERT INTO dbo.DirectAndRoleWiseAccessRestrictions(IIC,DirectorOnly,DeskOfficerOnly)
	--SELECT * FROM DirectAndRoleWiseAccessRestrictions
	SELECT @IIC,* FROM OPENJSON(@ACCESSRESTRICTIONS)
	WITH(
		DirectorOnly bit '$.directorOnly',
		DeskOfficerOnly bit '$.deskOfficerOnly'
	)

	EXEC [UPDATE_INFERENCE_RELATIONSHIPS] @IIC, @DESCRIPTION
	SELECT @IIC AS 'IIC' , @DESCRIPTION AS 'Description'
	COMMIT TRANSACTION @TR_CREATE_ITEM
END
