USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[INSERT_RELATED_RELATIONSHIP]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INSERT_RELATED_RELATIONSHIP](@TYPE NVARCHAR(MAX),@JSON NVARCHAR(MAX))
AS
BEGIN
BEGIN TRANSACTION T1
	--START -> DECLARING VARIABLES
	DECLARE @QRY NVARCHAR(MAX)
	--END -> DECLARING VARIABLES 
 
	IF @TYPE='SIS_PersonEntities.RelatedActivities'
		--BEGIN 
		--	IF NOT EXISTS (SELECT * FROM [SIS_Person].[dbo].[RelatedActivities] ra inner join (select PIC,AIC from OPENJSON(@JSON)
		--WITH(
		--	PIC BIGINT '$.PIC',
		--	AIC BIGINT '$.AIC'
		--)) x on x.PIC == ra.PIC) 
		
		--BEGIN
		--	--INSERTING JSON ARRAY TO TEMP TABLE
		--	INSERT INTO [SIS_Person].[dbo].[RelatedActivities](PIC, AIC, Category, IdentifyingFeature, IsInferred,InferredTable)
		--	SELECT PIC,AIC,'','',1,'SIS_PersonEntities.RelatedActivities' FROM OPENJSON(@JSON)
		--	WITH(
		--		PIC BIGINT '$.PIC',
		--		AIC BIGINT '$.AIC'
		--	)
		--END
		--END
		BEGIN
		MERGE [SIS_Person].[dbo].[RelatedActivities] RA
		USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					PIC BIGINT '$.PIC',
					AIC BIGINT '$.AIC'
					)) RATEMP
					ON RA.PIC = RATEMP.PIC and RA.AIC = RATEMP.AIC
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (PIC, AIC, Category, IdentifyingFeature, IsInferred,InferredTable)
				VALUES(RATEMP.PIC,RATEMP.AIC,'','',1,'SIS_PersonEntities.RelatedActivities');
		END
    IF @TYPE='SIS_OrganizationEntities.RelatedActivities'
		BEGIN 
			--IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
			--	WITH(
			--		OIC BIGINT '$.OIC',
			--		AIC BIGINT '$.RelatedAIC'
			--	)) 
			--BEGIN
			--	--INSERTING JSON ARRAY TO TEMP TABLE
			--	INSERT INTO [SIS_Organization].[dbo].[RelatedActivities](OIC, AIC, IsInferred,InferredTable)
			--	SELECT OIC,AIC,1,'SIS_OrganizationEntities.RelatedActivities' FROM OPENJSON(@JSON)
			--	WITH(
			--		OIC BIGINT '$.OIC',
			--		AIC BIGINT '$.RelatedAIC'
			--	)
			--END
			MERGE [SIS_Organization].[dbo].[RelatedActivities] RA
USING (SELECT * FROM OPENJSON(@JSON)
		WITH(
			OIC BIGINT '$.OIC',
			AIC BIGINT '$.RelatedAIC'
			)) RATEMP
			ON RA.OIC = RATEMP.OIC and RA.AIC = RATEMP.AIC
			WHEN NOT MATCHED BY TARGET
		 THEN INSERT (OIC, AIC, IsInferred,InferredTable)
		VALUES(RATEMP.OIC,RATEMP.AIC,1,'SIS_OrganizationEntities.RelatedActivities');

		END
    IF @TYPE='SIS_OrganizationEntities.RelatedOrganizations'
		BEGIN 
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		OIC BIGINT '$.OIC',
	--		[RelatedOrganizations(OIC)] BIGINT '$.RelatedOIC'
	--	))
	--		BEGIN
	--	--INSERTING JSON ARRAY TO TEMP TABLE
	--	INSERT INTO [SIS_Organization].[dbo].[RelatedOrganizations] (OIC, [RelatedOrganizations(OIC)], IsInferred,InferredTable)
	--	SELECT OIC,[RelatedOrganizations(OIC)],'1','SIS_OrganizationEntities.RelatedOrganizations' FROM OPENJSON(@JSON)
	--	WITH(
	--		OIC BIGINT '$.OIC',
	--		[RelatedOrganizations(OIC)] BIGINT '$.RelatedOIC'
	--	)
	--END

	MERGE [SIS_Organization].[dbo].[RelatedOrganizations] RA
USING (SELECT * FROM OPENJSON(@JSON)
		WITH(
			OIC BIGINT '$.OIC',
			[RelatedOrganizations(OIC)] BIGINT '$.RelatedOIC'
			)) RATEMP
			ON RA.OIC = RATEMP.OIC and RA.[RelatedOrganizations(OIC)] = RATEMP.[RelatedOrganizations(OIC)]
			WHEN NOT MATCHED BY TARGET
		 THEN INSERT (OIC, [RelatedOrganizations(OIC)], IsInferred,InferredTable)
		VALUES(RATEMP.OIC,RATEMP.[RelatedOrganizations(OIC)],'1','SIS_OrganizationEntities.RelatedOrganizations');

		END
    IF @TYPE='SIS_ItemEntities.RelatedOrganizations'
	BEGIN 
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		OIC BIGINT '$.OIC'
	--	))
	--BEGIN
	--	--INSERTING JSON ARRAY TO TEMP TABLE
	--	INSERT INTO [SIS_Item].[dbo].[RelatedOrganizations](IIC, OIC,IsInferred,InferredTable)
	--	SELECT IIC,OIC,1,'SIS_ItemEntities.RelatedOrganizations' FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		OIC BIGINT '$.OIC'
	--	)
	--END

	MERGE [SIS_Item].[dbo].[RelatedOrganizations] RO
		USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					IIC BIGINT '$.IIC',
					OIC BIGINT '$.OIC'
					)) RATEMP
					ON RO.OIC = RATEMP.OIC and RO.IIC = RATEMP.IIC
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (IIC, OIC,IsInferred,InferredTable)
				VALUES(RATEMP.IIC,RATEMP.OIC,1,'SIS_ItemEntities.RelatedOrganizations');

		END
	IF @TYPE='SIS_OrganizationEntities.Employees'
		BEGIN 
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		OIC BIGINT '$.OIC',
	--		[RelatedOrganizations(OIC)] BIGINT '$.RelatedOIC'
	--	))
	--		BEGIN
	--	--INSERTING JSON ARRAY TO TEMP TABLE
	--	INSERT INTO [SIS_Organization].[dbo].[RelatedOrganizations] (OIC, [RelatedOrganizations(OIC)], IsInferred,InferredTable)
	--	SELECT OIC,[RelatedOrganizations(OIC)],'1','SIS_OrganizationEntities.RelatedOrganizations' FROM OPENJSON(@JSON)
	--	WITH(
	--		OIC BIGINT '$.OIC',
	--		[RelatedOrganizations(OIC)] BIGINT '$.RelatedOIC'
	--	)
	--END

	MERGE [SIS_Organization].[dbo].[Employees] E
	USING (SELECT * FROM OPENJSON(@JSON)
		WITH(
			OIC BIGINT '$.OIC',
			PIC BIGINT '$.PIC',
			[Type] nvarchar(50) '$.Type'
			)) RATEMP
			ON E.OIC = RATEMP.[OIC] and E.[PIC] = RATEMP.[PIC]
			WHEN NOT MATCHED BY TARGET
		 THEN INSERT (OIC, PIC, [Type],Country,District)
		VALUES(RATEMP.OIC,RATEMP.[PIC],RATEMP.[Type],null,null);

	END
		
	IF @TYPE='SIS_ItemEntities.RelatedActivities'
		BEGIN 
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		AIC BIGINT '$.AIC'
	--	))
	--BEGIN
	--	--INSERTING JSON ARRAY TO TEMP TABLE
	--	INSERT INTO [SIS_Item].[dbo].[RelatedActivity](IIC, AIC, [Description], [Type], IsInferred,InferredTable)
	--	SELECT IIC,AIC,'','',1,'SIS_ItemEntities.RelatedActivities' FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		AIC BIGINT '$.AIC'
	--	)
	--END

	MERGE [SIS_Item].[dbo].[RelatedActivity] RA
		USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					IIC BIGINT '$.IIC',
					AIC BIGINT '$.AIC'
					)) RATEMP
					ON RA.IIC = RATEMP.IIC and RA.AIC = RATEMP.AIC
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (IIC, AIC, [Description], [Type], IsInferred,InferredTable)
				VALUES(RATEMP.IIC,RATEMP.AIC,'','',1,'SIS_ItemEntities.RelatedActivities');

		END
	IF @TYPE='SIS_ItemEntities.RelatedItems'
		BEGIN 
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		[RelatedItems(IIC)] BIGINT '$.RelatedItemsIIC'
	--	))
	--BEGIN
	--    INSERT INTO [SIS_Item].[dbo].[RelatedItem](IIC, [RelatedItems(IIC)],IsInferred,InferredTable)
	--	SELECT IIC,[RelatedItems(IIC)],1,'SIS_ItemEntities.RelatedItems' FROM OPENJSON(@JSON)
	--	WITH(
	--		IIC BIGINT '$.IIC',
	--		[RelatedItems(IIC)] BIGINT '$.RelatedItemsIIC'
	--	)
	--END

	MERGE [SIS_Item].[dbo].[RelatedItem] RI
		USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					IIC BIGINT '$.IIC',
					[RelatedItems(IIC)] BIGINT '$.RelatedItemsIIC'
					)) RATEMP
					ON RI.IIC = RATEMP.IIC and RI.[RelatedItems(IIC)] = RATEMP.[RelatedItems(IIC)]
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (IIC, [RelatedItems(IIC)],IsInferred,InferredTable)
				VALUES(RATEMP.IIC,RATEMP.[RelatedItems(IIC)],1,'SIS_ItemEntities.RelatedItems');

		END
	IF @TYPE='SIS_ActivityEntities.RelatedOrganisation'
		BEGIN
	--		IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		AIC BIGINT '$.AIC',
	--		OIC BIGINT '$.OIC',
	--		OrganizationCatagory nvarchar(max) '$.OrganizationCatagory'
	--	))
	--BEGIN
	--    INSERT INTO [SIS_Activity].[dbo].[RelatedOrganization](AIC, OIC,OrganizationCatagory,IsInferred,InferredTable)
	--	SELECT AIC,OIC,OrganizationCatagory,1,'SIS_ActivityEntities.RelatedOrganisation' FROM OPENJSON(@JSON)
	--	WITH(
	--		AIC BIGINT '$.AIC',
	--		OIC BIGINT '$.OIC',
	--		OrganizationCatagory nvarchar(max) '$.OrganizationCatagory'
	--	)
	--END
	MERGE [SIS_Activity].[dbo].[RelatedOrganization] RO
	USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					AIC BIGINT '$.AIC',
					OIC BIGINT '$.OIC',
					OrganizationCatagory nvarchar(max) '$.OrganizationCatagory'
					)) RATEMP
					ON RO.AIC = RATEMP.AIC and RO.OIC = RATEMP.OIC and RO.OrganizationCatagory = RATEMP.OrganizationCatagory
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (AIC, OIC,OrganizationCatagory,IsInferred,InferredTable)
				VALUES(RATEMP.AIC,RATEMP.OIC,RATEMP.OrganizationCatagory,1,'SIS_ActivityEntities.RelatedOrganisation');
		END
	IF @TYPE='SIS_PersonEntities.RelatedOrganisations'
		BEGIN
	-- IF NOT EXISTS (SELECT * FROM OPENJSON(@JSON)
	--	WITH(
	--		PIC BIGINT '$.PIC',
	--		OIC BIGINT '$.OIC',
	--		[Type] nvarchar(max) '$.Type'
	--	))
	--	BEGIN
	--    INSERT INTO SIS_Person.[dbo].Organizations(PIC, OIC,Place,[From],Position,PrimeDesignationOffice,[To],Type)
	--	SELECT PIC,OIC,'','','','','',[Type] FROM OPENJSON(@JSON)
	--	WITH(
	--		PIC BIGINT '$.PIC',
	--		OIC BIGINT '$.OIC',
	--		[Type] nvarchar(max) '$.Type'
	--	)
	--END
		MERGE SIS_Person.[dbo].Organizations PO
	USING (SELECT * FROM OPENJSON(@JSON)
				WITH(
					PIC BIGINT '$.PIC',
					OIC BIGINT '$.OIC',
					[Type] nvarchar(max) '$.Type'
					)) RATEMP
					ON PO.PIC = RATEMP.PIC and PO.OIC = RATEMP.OIC and PO.[Type] = RATEMP.[Type]
					WHEN NOT MATCHED BY TARGET
				 THEN INSERT (PIC, OIC,Place,[From],Position,PrimeDesignationOffice,[To],Type)
				VALUES(RATEMP.PIC,RATEMP.OIC,'','','','','',RATEMP.[Type]);
		



		END
COMMIT TRANSACTION @QRY
RETURN 1
END
GO
