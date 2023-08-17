USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]    Script Date: 7/20/2023 4:42:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]
(@fromIC BIGINT)
AS
BEGIN 

	BEGIN TRANSACTION T1

	DELETE FROM SIS_Organization.dbo.RelatedOrganizations
	WHERE IsInferred = 1
	AND [RelatedOrganizations(OIC)] = @fromIC

	INSERT INTO SIS_Organization.dbo.RelatedOrganizations(OIC,[RelatedOrganizations(OIC)],IsInferred, InferredTable)
		SELECT [RelatedOrganizations(OIC)],OIC, 1,'SIS_Organization.dbo.RelatedOrganizations' FROM SIS_Organization.dbo.RelatedOrganizations
		WHERE OIC=@fromIC
		UNION SELECT ExternalLinksOIC,OIC, 1,'SIS_Organization.dbo.ExternalLinks' FROM SIS_Organization.dbo.ExternalLinks
		WHERE OIC=@fromIC
		UNION SELECT PublicationsOIC,OIC, 1,'SIS_Organization.dbo.Publications' FROM SIS_Organization.dbo.Publications
		WHERE OIC=@fromIC
		UNION SELECT SplinterGroupOIC,OIC, 1,'SIS_Organization.dbo.SplinterGroups' FROM SIS_Organization.dbo.SplinterGroups
		WHERE OIC=@fromIC
		UNION SELECT LinkOIC,OIC, 1,'SIS_Organization.dbo.PoliticalLinks' FROM SIS_Organization.dbo.PoliticalLinks
		WHERE OIC=@fromIC
		UNION SELECT SafeHousesOIC,OIC, 1,'SIS_Organization.dbo.SafeHouses' FROM SIS_Organization.dbo.SafeHouses
		WHERE OIC=@fromIC
		UNION SELECT PressesOIC,OIC, 1,'SIS_Organization.dbo.SafeHouses' FROM SIS_Organization.dbo.Presses
		WHERE OIC=@fromIC

    DELETE FROM SIS_Person.dbo.Organizations
	WHERE OIC=@fromIC

   INSERT INTO SIS_Person.dbo.Organizations(OIC,PIC,[IsInferred],[InferredTable])
		SELECT OIC,PIC, 1,'SIS_Organization.dbo.Employees' FROM SIS_Organization.dbo.Employees
		WHERE OIC=@fromIC
		UNION SELECT OIC,PIC, 1,'SIS_Organization.dbo.Couriers' FROM SIS_Organization.dbo.Couriers
		WHERE OIC=@fromIC
		UNION SELECT OIC,PIC, 1,'SIS_Organization.dbo.DistrictLeaders' FROM SIS_Organization.dbo.DistrictLeaders
		WHERE OIC=@fromIC
		
	DELETE FROM SIS_Activity.dbo.RelatedOrganization
	WHERE IsInferred=1
	AND OIC=@fromIC

	INSERT INTO SIS_Activity.dbo.RelatedOrganization(OIC,AIC,IsInferred,InferredTable)
		SELECT OIC,AIC,1,'SIS_Organization.dbo.RelatedActivities' FROM SIS_Organization.dbo.RelatedActivities
		WHERE OIC=@fromIC
		
	DELETE FROM SIS_Item.dbo.RelatedOrganizations
	WHERE IsInferred=1
	AND OIC=@fromIC

	INSERT INTO SIS_Item.dbo.RelatedOrganizations(OIC,IIC,IsInferred,InferredTable)
		SELECT OIC,IIC,1,'SIS_Organization.dbo.VehiclesOwned' FROM SIS_Organization.dbo.VehiclesOwned
		WHERE OIC=@fromIC
	
	COMMIT TRANSACTION T1
END
