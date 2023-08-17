USE [SIS_General]
GO

/****** Object:  StoredProcedure [dbo].[GET_RELATED_SEARCH_RESULT]    Script Date: 19/06/2023 09:54:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GET_RELATED_SEARCH_RESULT] (@id BIGINT, @profileType NVARCHAR(MAX))
AS
BEGIN

	SET NOCOUNT ON;


	DECLARE @Photographs NVARCHAR(MAX)
	DECLARE @RelatedPerson NVARCHAR(MAX)
	DECLARE @RelatedOrganization NVARCHAR(MAX)
	DECLARE @RelatedActivity NVARCHAR(MAX)
	DECLARE @RelatedItem NVARCHAR(MAX)

	CREATE TABLE #related (
		PIC BIGINT
	   ,OIC BIGINT
	   ,AIC BIGINT
	   ,IIC BIGINT
	)

	IF (@profileType = 'person')
	BEGIN

		SET @Photographs = CONCAT('Photographs:', (SELECT
				ISNULL((SELECT
						*
					FROM SIS_Person.dbo.Photographs WITH (NOLOCK)
					WHERE PIC = @id
					FOR JSON AUTO)
				, '[]'))
		)
		INSERT INTO #related
			SELECT DISTINCT
				rax.RelativesPIC
			   ,xc.OIC
			   ,ra.AIC
			   ,ri.IIC
			FROM (SELECT
					*
				FROM [SIS_General].[dbo].[CasePerson] WITH (NOLOCK)
				WHERE CasePerson.PIC = @id) x
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Person].[dbo].[Realtives] WITH (NOLOCK)) rax
				ON rax.PIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Person].[dbo].Organizations WITH (NOLOCK)) xc
				ON xc.PIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Person].[dbo].RelatedItems WITH (NOLOCK)) ri
				ON ri.PIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Person].[dbo].RelatedActivities WITH (NOLOCK)) ra
				ON ra.PIC = @id
	--			 ON CaseActivity.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID	

	END
	ELSE
	IF (@profileType = 'organization')
	BEGIN

		SET @Photographs = CONCAT('Photographs:', (SELECT
				ISNULL((SELECT
						*
					FROM SIS_Organization.dbo.Photographs WITH (NOLOCK)
					WHERE OIC = @id
					FOR JSON AUTO)
				, '[]'))
		)
		INSERT INTO #related
			SELECT DISTINCT
				rr.PIC
			   ,ro.[RelatedOrganizations(OIC)]
			   ,ra.AIC
			   ,0
			FROM (SELECT
					*
				FROM [SIS_Organization].[dbo].[OrganizationInformation] WITH (NOLOCK)
				WHERE [SIS_Organization].[dbo].[OrganizationInformation].OIC = @id) x
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Organization].[dbo].RelatedActivities WITH (NOLOCK)) ra
				ON ra.OIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Organization].[dbo].RelatedOrganizations WITH (NOLOCK)) ro
				ON ro.OIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM [SIS_Organization].[dbo].[RelatedPersons] WITH (NOLOCK)) rr
				ON rr.OIC = @id

	END
	ELSE
	IF (@profileType = 'activity')
	BEGIN

		SET @Photographs = CONCAT('Photographs:', (SELECT
				ISNULL((SELECT
						*
					FROM SIS_Activity.dbo.Photographs WITH (NOLOCK)
					WHERE AIC = @id
					FOR JSON AUTO)
				, '[]'))
		)
		INSERT INTO #related
			SELECT DISTINCT
				0
			   ,ro.OIC
			   ,ra.AIC
			   ,0
			FROM (SELECT
					*
				FROM [SIS_General].[dbo].[CaseActivity] WITH (NOLOCK)
				WHERE CaseActivity.AIC = @id) x
			LEFT OUTER JOIN (SELECT
					*
				FROM SIS_Activity.[dbo].RelatedActivities WITH (NOLOCK)) ra
				ON ra.AIC = @id
			LEFT OUTER JOIN (SELECT
					*
				FROM SIS_Activity.[dbo].RelatedOrganization WITH (NOLOCK)) ro
				ON ro.AIC = @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
	--			 ON CaseOrganization.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
	--			 ON CaseActivity.CaseID = x.CaseID
	--			AND CaseActivity.AIC <> @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID

	END
	ELSE
	IF (@profileType = 'item')
	BEGIN

		SET @Photographs = CONCAT('Photographs:', (SELECT
				ISNULL((SELECT
						*
					FROM SIS_Item.dbo.Photographs WITH (NOLOCK)
					WHERE IIC = @id
					FOR JSON AUTO)
				, '[]'))
		)
		--insert into #related
		SELECT DISTINCT
			rp.PIC
		   ,ro.OIC
		   ,ra.AIC
		   ,ri.IIC
		FROM (SELECT
				*
			FROM [SIS_General].[dbo].[CaseItem] WITH (NOLOCK)
			WHERE CaseItem.IIC = @id) x
		LEFT OUTER JOIN (SELECT
				*
			FROM SIS_Item.[dbo].RelatedActivity WITH (NOLOCK)) ra
			ON ra.IIC = @id
		LEFT OUTER JOIN (SELECT
				*
			FROM SIS_Item.[dbo].RelatedItem WITH (NOLOCK)) ri
			ON ri.IIC = @id
		LEFT OUTER JOIN (SELECT
				*
			FROM SIS_Item.[dbo].RelatedOrganizations WITH (NOLOCK)) ro
			ON ro.IIC = @id
		LEFT OUTER JOIN (SELECT
				*
			FROM SIS_Item.[dbo].RelatedPersons WITH (NOLOCK)) rp
			ON rp.IIC = @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
	--			 ON CaseOrganization.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
	--			 ON CaseActivity.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID
	--			AND CaseItem.IIC <> @id

	END

	SET @RelatedPerson = (SELECT
			ISNULL((SELECT
					PersonInformation.PIC AS 'PIC'
				   ,PersonInformation.FirstName
				   ,PersonInformation.Surname
				   ,Photographs.[Path]
				FROM SIS_Person.dbo.PersonInformation WITH (NOLOCK)
				INNER JOIN (SELECT DISTINCT
						PIC
					FROM #related
					WHERE PIC IS NOT NULL) pic
					ON SIS_Person.dbo.PersonInformation.PIC = pic.PIC
				LEFT OUTER JOIN (SELECT
						PIC
					   ,[Path] AS 'Path'
					FROM (SELECT
							PIC
						   ,[Path]
						   ,ROW_NUMBER() OVER (PARTITION BY PIC ORDER BY (SELECT
									0)
							) rw
						FROM SIS_Person.dbo.Photographs WITH (NOLOCK)) x
					WHERE x.rw = 1) Photographs
					ON Photographs.PIC = PersonInformation.PIC


				FOR JSON Path)
			, '[]'))
	SET @RelatedPerson = CONCAT('RelatedPeople:', @RelatedPerson)


	SET @RelatedOrganization = (SELECT
			ISNULL((SELECT
					OrganizationInformation.OIC AS 'OIC'
				   ,OrganizationInformation.OrganizationName
				   ,Photographs.[Path]
				FROM SIS_Organization.dbo.OrganizationInformation WITH (NOLOCK)
				INNER JOIN (SELECT DISTINCT
						OIC
					FROM #related
					WHERE OIC IS NOT NULL) oic
					ON OrganizationInformation.OIC = oic.OIC
				LEFT OUTER JOIN (SELECT
						OIC
					   ,[Path] AS 'Path'
					FROM (SELECT
							OIC
						   ,[Path]
						   ,ROW_NUMBER() OVER (PARTITION BY OIC ORDER BY (SELECT
									0)
							) rw
						FROM SIS_Organization.dbo.Photographs WITH (NOLOCK)) x
					WHERE x.rw = 1) Photographs
					ON Photographs.OIC = OrganizationInformation.OIC
				FOR JSON Path)
			, '[]'))
	SET @RelatedOrganization = CONCAT('RelatedOrganization:', @RelatedOrganization)


	SET @RelatedActivity = (SELECT
			ISNULL((SELECT
					ActivityInformation.AIC AS 'AIC'
				   ,DescriptionOfTheActivity AS 'DescriptionOftheActivity'
				   ,[StartDateTime] AS 'StartDateTime'
				   ,Photographs.[Path]
				FROM SIS_Activity.dbo.ActivityInformation WITH (NOLOCK)
				INNER JOIN (SELECT DISTINCT
						AIC
					FROM #related
					WHERE AIC IS NOT NULL) aic
					ON ActivityInformation.AIC = aic.AIC
				LEFT OUTER JOIN (SELECT
						AIC
					   ,[Path] AS 'Path'
					FROM (SELECT
							AIC
						   ,[Path]
						   ,ROW_NUMBER() OVER (PARTITION BY AIC ORDER BY (SELECT
									0)
							) rw
						FROM SIS_Activity.dbo.Photographs WITH (NOLOCK)) x
					WHERE x.rw = 1) Photographs
					ON Photographs.AIC = ActivityInformation.AIC
				FOR JSON Path)
			, '[]'))
	SET @RelatedActivity = CONCAT('RelatedActivity:', @RelatedActivity)


	SET @RelatedItem = (SELECT
			ISNULL((SELECT
					ItemInformation.IIC AS 'IIC'
				   ,ItemInformation.DescriptionOfItem
				   ,ItemInformation.[MainIdentifyingNumber]
				   ,Photographs.[Path]
				FROM SIS_Item.dbo.ItemInformation WITH (NOLOCK)
				INNER JOIN (SELECT DISTINCT
						IIC
					FROM #related
					WHERE IIC IS NOT NULL) iic
					ON ItemInformation.IIC = iic.IIC
				LEFT OUTER JOIN (SELECT
						IIC
					   ,[Path] AS 'Path'
					FROM (SELECT
							IIC
						   ,[Path]
						   ,ROW_NUMBER() OVER (PARTITION BY IIC ORDER BY (SELECT
									0)
							) rw
						FROM SIS_Item.dbo.Photographs WITH (NOLOCK)) x
					WHERE x.rw = 1) Photographs
					ON Photographs.IIC = ItemInformation.IIC
				FOR JSON Path)
			, '[]'))
	SET @RelatedItem = CONCAT('RelatedItem:', @RelatedItem)




	SELECT
		CONCAT('{', @RelatedPerson, ',', @RelatedOrganization, ',', @RelatedActivity, ',', @RelatedItem, ',', @Photographs, '}')

END







--[GET_RELATED_SEARCH_RESULT] 3,'person'
GO


