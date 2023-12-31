USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CHECK_PREDEFINED_USED]    Script Date: 08/06/2023 13:06:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CHECK_PREDEFINED_USED](@dropDownValue nVARCHAR(MAX))
AS
BEGIN


--Person	
	IF EXISTS (SELECT * FROM SIS_Person.dbo.PersonInformation WITH(nolock) WHERE FieldOfOperation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.SecurityClassifications WITH(nolock) WHERE SecurityClassification = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.SecurityClassifications WITH(nolock) WHERE RelatedCountry = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.CurrentStatus WITH(nolock) WHERE [Status] = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation WITH(nolock) WHERE Surname = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Nationality n WITH(nolock) WHERE n.Nation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation WITH(nolock) WHERE ResidenceCountry = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation WITH(nolock) WHERE SIS_Person.dbo.PersonInformation.Race = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation WITH(nolock) WHERE SIS_Person.dbo.PersonInformation.Religion = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
    ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PhotographsOtherDetails pod WITH(nolock) WHERE pod.Place = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Identification i WITH(nolock) WHERE i.CountryOfIssue = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Identification i WITH(nolock) WHERE i.Authenticity = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation pi WITH(nolock) WHERE pi.FingerPrintLocation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation pi WITH(nolock) WHERE pi.Weight = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation pi WITH(nolock) WHERE pi.Height = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.PersonInformation pi WITH(nolock) WHERE pi.Complexion = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.SpecialSkills ss WITH(nolock) WHERE ss.SpecialSkill = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.SpecialPeculiarities sp WITH(nolock) WHERE sp.SpecialPeculiarity = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Weaknesses w WITH(nolock) WHERE w.Weakness = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Addresses a WITH(nolock) WHERE a.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Addresses a WITH(nolock) WHERE a.PoliceStation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Education e WITH(nolock) WHERE e.CollageName = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Education e WITH(nolock) WHERE e.Place = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Education e WITH(nolock) WHERE e.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Occupations o WITH(nolock) WHERE o.Occupation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Occupations o WITH(nolock) WHERE o.Rank = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Occupations o WITH(nolock) WHERE o.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Occupations o WITH(nolock) WHERE o.PoliceStation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.SocialMediaDetails smd WITH(nolock) WHERE smd.SocialMedia = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AsylumSeeker [as] WITH(nolock) WHERE [as].SeekingCountry = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.Realtives r WITH(nolock)  WHERE r.Relationship = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.TravelInformation ti WITH(nolock) WHERE ti.ActionToBeTakenOnArrival = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.TravelInformation ti WITH(nolock) WHERE ti.ActionToBeTakenOnDeparture = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AllTravelParticulars atp WITH(nolock) WHERE atp.CountryOfOrigin = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AllTravelParticulars atp WITH(nolock) WHERE atp.PortOfOrigin = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AllTravelParticulars atp WITH(nolock) WHERE atp.CountryOfDestination = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AllTravelParticulars atp WITH(nolock) WHERE atp.PortOfDestination = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.AllTravelParticulars atp WITH(nolock) WHERE atp.PurposeOfVisit = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.CourtCases cc WITH(nolock) WHERE cc.Court = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.CourtCases cc WITH(nolock) WHERE cc.PlaceOfDetention = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.CourtCases cc WITH(nolock) WHERE cc.Absconded = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.DetentionPlace dp WITH(nolock) WHERE dp.DetentionPlaceCode = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.DetentionPlace dp WITH(nolock) WHERE dp.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Person.dbo.DetentionPlace dp WITH(nolock) WHERE dp.Institution = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END


--Activity
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.TypeOfActivity = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.MajorClassification = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.MinorClassification = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.AdministrativeDistrict = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.PoliceStation = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ActivityInformation ai WITH(nolock) WHERE ai.OutCome = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ModusOperandi mo WITH(nolock) WHERE mo.ModusOperandi = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.NoOfVictims nov WITH(nolock) WHERE nov.Category = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.NoOfVictims nov WITH(nolock) WHERE nov.Race = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.NoOfVictims nov WITH(nolock) WHERE nov.Status = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.NoOfVictims nov WITH(nolock) WHERE nov.Organization = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfVictims dov WITH(nolock) WHERE dov.Category = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfVictims dov WITH(nolock) WHERE dov.Race = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfVictims dov WITH(nolock) WHERE dov.Rank = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfVictims dov WITH(nolock) WHERE dov.Status = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfVictims dov WITH(nolock) WHERE dov.Organization = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.InstitutionsAffected ia WITH(nolock) WHERE ia.MajorType = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.InstitutionsAffected ia WITH(nolock) WHERE ia.MinorType = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.InstitutionsAffected ia WITH(nolock) WHERE ia.HowAffected = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailOfSuspect dos WITH(nolock) WHERE dos.Status = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.NoOfInstructors noi WITH(nolock) WHERE noi.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.DetailsOfInstructors doi WITH(nolock) WHERE doi.Country = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ItemsUsed iu WITH(nolock) WHERE iu.MajorType = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.ItemsUsed iu WITH(nolock) WHERE iu.MinorType = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END
	ELSE IF EXISTS(SELECT * FROM SIS_Activity.dbo.Incidents i WITH(nolock) WHERE i.Incident = @dropDownValue)
	BEGIN

		SELECT CAST(N'1' AS bit) AS 'IsUsed'
	
	END


--Organization
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.OrganizationInformation oi WITH(nolock) WHERE oi.TypeOfOrganization = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.OrganizationInformation oi WITH(nolock) WHERE oi.SubClassificationI = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.OrganizationInformation oi WITH(nolock) WHERE oi.SubClassificationII = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.OrganizationInformation oi WITH(nolock) WHERE oi.OrganizationCountry = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.Employees e WITH(nolock) WHERE e.Country = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.Employees e WITH(nolock) WHERE e.District = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Organization.dbo.DistrictLeaders dl WITH(nolock) WHERE dl.District = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END


--Item
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.ItemInformation ii WITH(nolock) WHERE ii.TypeOfItem = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.ItemInformation ii WITH(nolock) WHERE ii.SubClassificationI = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.ItemInformation ii WITH(nolock) WHERE ii.SubClassificationII = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.ItemInformation ii WITH(nolock) WHERE ii.CountryOfManufacture = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.DetailsOfRecovery dr WITH(nolock) WHERE dr.Country = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END
	ELSE IF EXISTS(SELECT * FROM SIS_Item.dbo.DetailsOfRecovery dr WITH(nolock) WHERE dr.PoliceStation = @dropDownValue)
	BEGIN

			SELECT CAST(N'1' AS bit) AS 'IsUsed'

	END



	ELSE
	BEGIN

			SELECT CAST(N'0' AS bit) AS 'IsUsed'		

	END


END
GO
