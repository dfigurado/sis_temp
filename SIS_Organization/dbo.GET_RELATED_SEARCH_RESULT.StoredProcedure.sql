USE [SIS_General]
GO

/****** Object:  StoredProcedure [dbo].[GET_RELATED_SEARCH_RESULT]    Script Date: 24/07/2023 15:50:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GET_RELATED_SEARCH_RESULT] (@id bigint ,@profileType nvarchar(MAX))
AS
BEGIN

SET NOCOUNT ON;
 

DECLARE @Photographs NVARCHAR(MAX)
DECLARE @RelatedPerson nVARCHAR(MAX)
DECLARE @RelatedOrganization nVARCHAR(MAX)
DECLARE @RelatedActivity nVARCHAR(MAX)
DECLARE @RelatedItem nVARCHAR(MAX)

CREATE TABLE #related (PIC bigint,OIC bigint,AIC bigint,IIC bigint)

IF (@profileType = 'person')
BEGIN
	
	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Person.dbo.Photographs with(nolock) where pic=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT rax.RelativesPIC,xc.OIC,ra.AIC,ri.IIC
	  FROM (SELECT *
			  FROM [SIS_Person].[dbo].[PersonInformation] with(NOLOCK)
			 WHERE [PIC] = @id
		   )x
	LEFT OUTER JOIN (select * from [SIS_Person].[dbo].[Realtives] with(NOLOCK)) rax
				ON rax.PIC = @id
		LEFT OUTER JOIN (select * from [SIS_Person].[dbo].Organizations with(NOLOCK)) xc
				ON xc.PIC = @id
	LEFT OUTER JOIN (select * from [SIS_Person].[dbo].RelatedItems with(NOLOCK)) ri
				ON ri.PIC = @id
				LEFT OUTER JOIN (select * from [SIS_Person].[dbo].RelatedActivities with(NOLOCK)) ra
				ON ra.PIC = @id
	--			 ON CaseActivity.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID	

END
ELSE IF (@profileType = 'organization')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Organization.dbo.Photographs with(nolock) where OIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT rr.pic,ro.[RelatedOrganizations(OIC)],ra.AIC,ri.IIC
	  FROM (SELECT *
			  FROM [SIS_Organization].[dbo].[OrganizationInformation] with(NOLOCK)
			 WHERE [SIS_Organization].[dbo].[OrganizationInformation].OIC = @id
		   )x
	LEFT OUTER JOIN (select * from [SIS_Organization].[dbo].RelatedActivities with(NOLOCK)) ra
				ON ra.OIC = @id
				LEFT OUTER JOIN (select * from [SIS_Organization].[dbo].RelatedOrganizations with(NOLOCK)) ro
				ON ro.OIC = @id
				left outer join (select * from [SIS_Organization].[dbo].[RelatedPersons] with(NOLOCK)) rr
				on rr.oic=@id
				left outer join (select * from [SIS_Organization].[dbo].[RelatedItems] with(NOLOCK)) ri
				on ri.oic=@id

END
ELSE IF (@profileType = 'activity')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Activity.dbo.Photographs with(nolock) where AIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT 0,ro.OIC,[RelatedActivity(AIC)],0
	  FROM (SELECT *
			  FROM [SIS_Activity].[dbo].[ActivityInformation] with(NOLOCK)
			  WHERE [SIS_Activity].[dbo].[ActivityInformation].AIC = @id
		   )x
		LEFT OUTER JOIN (select * from SIS_Activity.[dbo].RelatedActivities with(NOLOCK)) ra
				ON ra.AIC = @id
				LEFT OUTER JOIN (select * from SIS_Activity.[dbo].RelatedOrganization with(NOLOCK)) ro
				ON ro.AIC = @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
	--			 ON CaseOrganization.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
	--			 ON CaseActivity.CaseID = x.CaseID
	--			AND CaseActivity.AIC <> @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID

END
ELSE IF (@profileType = 'item')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Item.dbo.Photographs with(nolock) where IIC=@id for json auto),'[]')))
	--insert into #related
	SELECT DISTINCT rp.PIC,ro.OIC,ra.AIC,ri.IIC
	  FROM (SELECT *
			  FROM [SIS_Item].[dbo].[ItemInformation] with(NOLOCK)
			 WHERE IIC = @id
		   )x
	LEFT OUTER JOIN (select * from SIS_Item.[dbo].RelatedActivity with(NOLOCK)) ra
				ON ra.IIC = @id
				LEFT OUTER JOIN (select * from SIS_Item.[dbo].RelatedItem with(NOLOCK)) ri
					ON ri.IIC = @id
					LEFT OUTER JOIN (select * from SIS_Item.[dbo].RelatedOrganizations with(NOLOCK)) ro
					ON ro.IIC = @id
					LEFT OUTER JOIN (select * from SIS_Item.[dbo].RelatedPersons with(NOLOCK)) rp
					ON rp.IIC = @id
	--LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
	--			 ON CaseOrganization.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
	--			 ON CaseActivity.CaseID = x.CaseID
	--LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
	--			 ON CaseItem.CaseID = x.CaseID
	--			AND CaseItem.IIC <> @id

END

SET @RelatedPerson = (SELECT ISNULL((SELECT PersonInformation.PIC AS 'PIC',
												PersonInformation.FirstName,
												PersonInformation.Surname,
												Photographs.[Path]
										   FROM SIS_Person.dbo.PersonInformation with(nolock)
										    INNER JOIN (SELECT DISTINCT PIC FROM #related WHERE PIC IS NOT NULL)pic
									              ON SIS_Person.dbo.PersonInformation.PIC = pic.PIC
												  INNER JOIN SIS_Person.dbo.SystemDetails SD ON SD.PIC=pic.PIC
                                          LEFT OUTER JOIN (SELECT PIC,[Path] AS 'Path'
															FROM (SELECT PIC,[Path],ROW_NUMBER()OVER(PARTITION BY PIC ORDER BY (SELECT 0)) rw
															        FROM SIS_Person.dbo.Photographs with(nolock)
																 )x
														   WHERE x.rw = 1
                                                         )Photographs
													  ON Photographs.PIC = PersonInformation.PIC
													WHERE SD.IsDeleted=0

			              FOR JSON PATH),'[]'))
SET @RelatedPerson = CONCAT('RelatedPeople:',@RelatedPerson)


SET @RelatedOrganization = (SELECT ISNULL((SELECT OrganizationInformation.OIC AS 'OIC',
                                                  OrganizationInformation.OrganizationName,
												  Photographs.[Path]
											 FROM SIS_Organization.dbo.OrganizationInformation with(nolock)
											  INNER JOIN (SELECT DISTINCT OIC FROM #related WHERE OIC IS NOT NULL)oic
									              ON OrganizationInformation.OIC = oic.OIC
											  INNER JOIN SIS_Organization.dbo.SystemDetails SD ON SD.OIC=oic.OIC
										  LEFT OUTER JOIN  (SELECT OIC,[Path] AS 'Path'
															  FROM (SELECT OIC,[Path],ROW_NUMBER()OVER(PARTITION BY OIC ORDER BY (SELECT 0)) rw
															          FROM SIS_Organization.dbo.Photographs with(nolock)
																   )x
														     WHERE x.rw = 1
                                                           )Photographs
													    ON Photographs.OIC = OrganizationInformation.OIC
														WHERE SD.IsDeleted=0
			              FOR JSON PATH),'[]'))
SET @RelatedOrganization = CONCAT('RelatedOrganization:',@RelatedOrganization)


SET @RelatedActivity = (SELECT ISNULL((SELECT ActivityInformation.AIC AS 'AIC',
												 DescriptionOfTheActivity AS 'DescriptionOftheActivity',
												 [StartDateTime] as 'StartDateTime',
												 Photographs.[Path]
									        FROM SIS_Activity.dbo.ActivityInformation with(nolock)
									      INNER JOIN (SELECT DISTINCT AIC FROM #related WHERE AIC IS NOT NULL)aic
									              ON ActivityInformation.AIC = aic.AIC
												  INNER JOIN SIS_Activity.dbo.SystemDetails SD ON SD.AIC=aic.AIC
									      LEFT OUTER JOIN (SELECT AIC,[Path] AS 'Path'
														     FROM (SELECT AIC,[Path],ROW_NUMBER()OVER(PARTITION BY AIC ORDER BY (SELECT 0)) rw
														             FROM SIS_Activity.dbo.Photographs with(nolock)
															      )x
													        WHERE x.rw = 1
									                       )Photographs
											           ON Photographs.AIC = ActivityInformation.AIC
													   WHERE SD.IsDeleted=0
			              FOR JSON PATH),'[]'))
SET @RelatedActivity = CONCAT('RelatedActivity:',@RelatedActivity)


SET @RelatedItem = (SELECT ISNULL((SELECT ItemInformation.IIC AS 'IIC',
                                          ItemInformation.DescriptionOfItem,
										  ItemInformation.[MainIdentifyingNumber],
										  Photographs.[Path]
							         FROM SIS_Item.dbo.ItemInformation with(nolock)
							      INNER JOIN (SELECT DISTINCT IIC FROM #related WHERE IIC IS NOT NULL)iic
									      ON ItemInformation.IIC = iic.IIC
										  INNER JOIN SIS_Item.dbo.SystemDetails SD ON SD.IIC=iic.IIC
								  LEFT OUTER JOIN (SELECT IIC,[Path] AS 'Path'
													 FROM (SELECT IIC,[Path],ROW_NUMBER()OVER(PARTITION BY IIC ORDER BY (SELECT 0)) rw
													         FROM SIS_Item.dbo.Photographs with(nolock)
													      )x
													WHERE x.rw = 1
									              )Photographs
											   ON Photographs.IIC = ItemInformation.IIC
											   WHERE SD.IsDeleted=0
			              FOR JSON PATH),'[]'))
SET @RelatedItem = CONCAT('RelatedItem:',@RelatedItem)




SELECT CONCAT('{',@RelatedPerson,',',@RelatedOrganization,',',@RelatedActivity,',',@RelatedItem,',',@Photographs,'}')

END






 
 --[GET_RELATED_SEARCH_RESULT] 3,'person'
GO


