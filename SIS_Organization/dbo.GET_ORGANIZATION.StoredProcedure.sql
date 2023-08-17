USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[GET_ORGANIZATION]    Script Date: 8/15/2023 10:52:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GET_ORGANIZATION](@OIC BIGINT)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RE NVARCHAR(MAX)
	--DECLARE @ID BIGINT = 10
	DECLARE @ADDRESS NVARCHAR(MAX)-- = CONCAT('Address:', ISnull((SELECT * FROM Address WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @ALIASES NVARCHAR(MAX) --= CONCAT('Aliases:', ISnull((SELECT * FROM Aliases WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @COURIERS NVARCHAR(MAX)-- = CONCAT('Couriers:', ISnull((SELECT * FROM Couriers WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @DISTRICTLEADERS NVARCHAR(MAX) --= CONCAT('DistrictLeaders:', ISnull((SELECT * FROM DistrictLeaders WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @EMPLOYEES NVARCHAR(MAX)-- = CONCAT('Employees:', ISnull((SELECT * FROM Employees WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @EXTERNALLINKS NVARCHAR(MAX) --= CONCAT('EternalLinks:', ISnull((SELECT * FROM ExternalLinks WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @FILEREFERENCES NVARCHAR(MAX) --= CONCAT('FileReferences:', ISnull((SELECT * FROM FileReferences WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @NARRATIVEINFORMATION NVARCHAR(MAX)-- = CONCAT('NarrativeInformation:', ISnull((SELECT * FROM NarrativeInformation WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @OrganizationInformation NVARCHAR(MAX) --= CONCAT('OrganizationInformation:', ISnull((SELECT * FROM OrganizationInformation WHERE OIC=@ID FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER ),'null'))
	DECLARE @PHOTOGRAPHS NVARCHAR(MAX) --= CONCAT('Photographs:', ISnull((SELECT * FROM Photographs WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @POLITICALLINKS NVARCHAR(MAX) --= CONCAT('PoliticalLinks:', ISnull((SELECT * FROM PoliticalLinks WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @PRESSES NVARCHAR(MAX)-- = CONCAT('Presses:', ISnull((SELECT * FROM Presses WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @PUBLICATIONS NVARCHAR(MAX) --= CONCAT('Publications:', ISnull((SELECT * FROM Publications WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @RELATEDACTIVITIES NVARCHAR(MAX)-- = CONCAT('RelatedActivities:', ISnull((SELECT * FROM RelatedActivities WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @RELATEDORGANIZATIONS NVARCHAR(MAX)-- = CONCAT('RelatedOrganizations:', ISnull((SELECT * FROM RelatedOrganizations WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @SAFEHOUSES NVARCHAR(MAX)-- = CONCAT('SafeHouses:', ISnull((SELECT * FROM SafeHouses WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @SPLINTERGROUPS NVARCHAR(MAX)-- = CONCAT('SplinterGroups:', ISnull((SELECT * FROM SplinterGroups WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)-- = CONCAT('SystemDetails:', ISnull((SELECT * FROM SystemDetails WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @VEHICLESOWNED NVARCHAR(MAX)-- = CONCAT('VehiclesOwned:', ISnull((SELECT * FROM VehiclesOwned WHERE OIC=@ID FOR JSON AUTO ),'null'))
	DECLARE @BRANCHES NVARCHAR(MAX)
	DECLARE @ROLEWISEACCESSRESTRICTIONS NVARCHAR(MAX)
	DECLARE @MEMBERSHIPS NVARCHAR(MAX)


	--SET PARTIAL JSON FOR ADDRESS
	SET @ADDRESS =
	(SELECT ISNULL((SELECT * FROM [dbo].[Addresses] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @ADDRESS = CONCAT('Addresses:',@ADDRESS)

	--SET PARTIAL JSON FOR ALIASES
	SET @ALIASES =
	(SELECT ISNULL((SELECT * FROM [dbo].[Aliases] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @ALIASES = CONCAT('Aliases:',@ALIASES)

	SET @MEMBERSHIPS =
	(SELECT ISNULL((SELECT * FROM [dbo].[Memberships] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @MEMBERSHIPS = CONCAT('Memberships:',@MEMBERSHIPS)
	 
	--SET PARTIAL JSON FOR DISTRICTLEADERS
	SET @DISTRICTLEADERS =
	(SELECT ISNULL((
	SELECT D.*, (SELECT concat(PINFO.FirstName,' ',PINFO.SecondName,' ',PINFO.Surname) FROM SIS_Person.dbo.PersonInformation PINFO WHERE PIC = D.PIC) AS [Name] FROM [dbo].[DistrictLeaders] D with(nolock) 
	WHERE OIC=@OIC
	FOR JSON AUTO),'[]'))
	SET @DISTRICTLEADERS = CONCAT('DistrictLeaders:',@DISTRICTLEADERS)


	--SET PARTIAL JSON FOR EMPLOYEES
	SET @EMPLOYEES =
	(SELECT ISNULL((
	SELECT E.ID,E.Type, E.District, E.OIC, E.PIC AS RelatedPIC ,
	(SELECT (PINFO.Surname) FROM SIS_Person.dbo.PersonInformation PINFO WHERE PIC = E.PIC) AS [Name],
	(e.Country) AS CountryName,
	(e.District) AS DistrictName
	FROM [dbo].[Employees] E with(nolock) 
	
	WHERE OIC=@OIC
	FOR JSON AUTO),'[]'))
	SET @EMPLOYEES = CONCAT('Employees:',@EMPLOYEES)

	--SET PARTIAL JSON FOR EXTERNALLINKS
	SET @EXTERNALLINKS =
	(SELECT ISNULL((SELECT E.OIC, E.ExternalLinksOIC AS RelatedOIC,(SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = E.ExternalLinksOIC) 'Name' FROM [dbo].[ExternalLinks] E with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @EXTERNALLINKS = CONCAT('ExternalLinks:',@EXTERNALLINKS)


	--SET PARTIAL JSON FOR FILEREFERENCES
	SET @FILEREFERENCES =
	(SELECT ISNULL((SELECT * FROM [dbo].[FileReferences] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @FILEREFERENCES = CONCAT('FileReferences:',@FILEREFERENCES)

	--SET PARTIAL JSON FOR NARRATIVEINFORMATION
	SET @NARRATIVEINFORMATION =
	(SELECT ISNULL((SELECT * FROM [dbo].[NarrativeInformation] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @NARRATIVEINFORMATION = CONCAT('NarrativeInformation:',@NARRATIVEINFORMATION)

	--SET PARTIAL JSON FOR OrganizationInformation
	SET @ORGANIZATIONINFORMATION =
	(SELECT ISNULL((SELECT * FROM [dbo].[OrganizationInformation] oi with(nolock) WHERE OIC=@OIC FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER),'{}'))
	SET @ORGANIZATIONINFORMATION = CONCAT('OrganizationInformation:',@ORGANIZATIONINFORMATION)
	 
	--SET PARTIAL JSON FOR Photographs
	SET @PHOTOGRAPHS =
	(SELECT ISNULL((SELECT * FROM [dbo].[Photographs] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @PHOTOGRAPHS = CONCAT('Photographs:',@PHOTOGRAPHS)
	
	--SET PARTIAL JSON FOR POLITICALLINKS
	SET @POLITICALLINKS =
	(SELECT ISNULL((
	SELECT P.OIC, P.LinkOIC AS RelatedOIC,(SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = P.LinkOIC) 'Name' FROM [dbo].[PoliticalLinks] P with(nolock) 
	WHERE OIC=@OIC 
	FOR JSON AUTO
	),'[]'))
	SET @POLITICALLINKS = CONCAT('PoliticalLinks:',@POLITICALLINKS)


	--SET PARTIAL JSON FOR PRESSES
	SET @PRESSES =
	(SELECT ISNULL((SELECT P.OIC,P.PressesOIC as RelatedOIC, (SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = P.PressesOIC) 'Name' FROM [dbo].[Presses] P with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @PRESSES = CONCAT('Presses:',@PRESSES)
	

	--SET PARTIAL JSON FOR PUBLICATIONS
	SET @PUBLICATIONS =
	(SELECT ISNULL((SELECT P.OIC, P.PublicationsOIC RelatedOIC, (SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = P.PublicationsOIC) 'Name' 
	FROM [dbo].[Publications] P with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @PUBLICATIONS = CONCAT('Publications:',@PUBLICATIONS)


	--SET PARTIAL JSON FOR RELATEDACTIVITIES
	SET @RELATEDACTIVITIES =
	(SELECT ISNULL((SELECT RA.OIC, RA.AIC AS RelatedAIC, (SELECT AI.DescriptionOfTheActivity FROM SIS_Activity.[dbo].ActivityInformation AI WHERE AI.AIC = RA.AIC) 'Name' FROM [dbo].[RelatedActivities] RA with(nolock) 
	WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @RELATEDACTIVITIES = CONCAT('RelatedActivities:',@RELATEDACTIVITIES)

	--SET PARTIAL JSON FOR RELATEDORGANIZATIONS
	SET @RELATEDORGANIZATIONS =
	(SELECT ISNULL((SELECT RO.OIC,RO.[RelatedOrganizations(OIC)] AS RelatedOIC,RO.[OrganizationCatagory],
	(SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = RO.[RelatedOrganizations(OIC)]) 'Name'
	FROM [dbo].[RelatedOrganizations] RO
	WHERE RO.OIC = @OIC
	FOR JSON AUTO),'[]'))

	--SELECT RO.OIC,RO.[RelatedOrganizations(OIC)] AS RelatedOIC,
	--(SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = RO.OIC) 'OrganizationName'
	--FROM [dbo].[RelatedOrganizations] RO
	--WHERE RO.OIC = 259
	--FOR JSON AUTO


	SET @RELATEDORGANIZATIONS = CONCAT('RelatedOrganizations:',@RELATEDORGANIZATIONS)

	--SET PARTIAL JSON FOR SAFEHOUSES
	SET @SAFEHOUSES =
	(SELECT ISNULL((SELECT S.OIC,
						   S.SafeHousesOIC AS RelatedOIC,
						   (SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = S.SafeHousesOIC) 'Name',
						   s.FromDate,s.ToDate
					  FROM [dbo].[SafeHouses] S with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @SAFEHOUSES = CONCAT('SafeHouses:',@SAFEHOUSES)


	--SET PARTIAL JSON FOR SPLINTERGROUPS
	SET @SPLINTERGROUPS =
	(SELECT ISNULL((SELECT S.OIC, s.SplinterGroupOIC as 'RelatedOIC', (SELECT OI.OrganizationName FROM [dbo].[OrganizationInformation] OI WHERE OI.OIC = S.SplinterGroupOIC) 'Name' FROM [dbo].[SplinterGroups] S with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @SPLINTERGROUPS = CONCAT('SplinterGroups:',@SPLINTERGROUPS)

	--SET PARTIAL JSON FOR SYSTEMDETAILS
	SET @SYSTEMDETAILS =
	(SELECT ISNULL((SELECT s.*,
	(SELECT [DESCRIPTION] FROM SIS_GENERAL.DBO.PREDEFINED_DESKTARGET WHERE ID = S.DeskTarget) AS DeskName,
	(SELECT [DESCRIPTION] FROM SIS_GENERAL.DBO.Predefined_Subjects WHERE ID = S.Subject) AS SubjectName
	 FROM [dbo].[SystemDetails] s with(nolock)
	 WHERE OIC=@OIC FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER),'{}'))
	SET @SYSTEMDETAILS = CONCAT('SystemDetails:',@SYSTEMDETAILS)


	--SET PARTIAL JSON FOR ACCESSRESTRICTIONS 
	SET @ROLEWISEACCESSRESTRICTIONS =
	(SELECT ISNULL((SELECT * FROM [dbo].[DirectAndRoleWiseAccessRestrictions] with(nolock) WHERE OIC=@OIC FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER),'{}'))
	SET @ROLEWISEACCESSRESTRICTIONS = CONCAT('RoleWiseAccessRestrictions:',@ROLEWISEACCESSRESTRICTIONS)

	
	--SET PARTIAL JSON FOR VEHICLESOWNED
	SET @VEHICLESOWNED =
	(SELECT ISNULL((SELECT V.OIC, V.IIC AS RelatedIIC,(SELECT II.DescriptionOfItem FROM SIS_Item.[dbo].ItemInformation II WHERE II.IIC = V.IIC) 'Name'  FROM [dbo].[VehiclesOwned] V with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @VEHICLESOWNED = CONCAT('VehiclesOwned:',@VEHICLESOWNED)
	
	--SET PARTIAL JSON FOR VEHICLESOWNED
	SET @COURIERS =
	(SELECT ISNULL((
	
	SELECT C.OIC, C.PIC as RelatedPIC,(SELECT concat(PINFO.FirstName,' ',PINFO.SecondName,' ',PINFO.Surname) FROM SIS_Person.dbo.PersonInformation PINFO WHERE PIC = C.PIC) AS [Name] FROM [dbo].[Couriers] C with(nolock) 
	WHERE OIC=@OIC
	FOR JSON AUTO),'[]'))
	SET @COURIERS = CONCAT('Couriers:',@COURIERS)
	
	--SET PARTIAL JSON FOR BRANCHES
	SET @BRANCHES =
	(SELECT ISNULL((SELECT * FROM [dbo].[Branches] with(nolock) WHERE OIC=@OIC FOR JSON AUTO),'[]'))
	SET @BRANCHES = CONCAT('Branches:',@BRANCHES)

	--select @COURIERS
	SELECT CONCAT('{',@ADDRESS,',',@ALIASES,',',@BRANCHES,',',@MEMBERSHIPS,',',@COURIERS,',',@DistrictLeaders,',',@Employees,',',@ExternalLinks,',',@FILEREFERENCES,',',@NARRATIVEINFORMATION,',',@OrganizationInformation,',',@PHOTOGRAPHS,',',@POLITICALLINKS,',',@PRESSES,',',@PUBLICATIONS,',',@RELATEDACTIVITIES,',',@RELATEDORGANIZATIONS,',',@SAFEHOUSES,',',@SPLINTERGROUPS,',',@SYSTEMDETAILS,',',@VEHICLESOWNED,',',@ROLEWISEACCESSRESTRICTIONS,'}')
END

--[GET_ORGANIZATION] 15