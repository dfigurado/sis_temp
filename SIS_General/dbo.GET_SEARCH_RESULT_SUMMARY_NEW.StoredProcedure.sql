USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SEARCH_RESULT_SUMMARY_NEW]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_SEARCH_RESULT_SUMMARY_NEW] (@id bigint ,@profileType nvarchar(MAX))
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
	SELECT DISTINCT Organizations.OIC,RelatedActivities.AIC,RelatedItems.IIC
	  FROM (SELECT *
			  FROM [SIS_Person].[dbo].PersonInformation with(NOLOCK)
			 WHERE PersonInformation.PIC = @id
		   )x
	LEFT OUTER JOIN [SIS_Person].[dbo].Organizations with(NOLOCK)
				 ON Organizations.PIC = x.PIC
	LEFT OUTER JOIN [SIS_Person].dbo.RelatedActivities with(NOLOCK)
				 ON RelatedActivities.AIC = x.PIC
	LEFT OUTER JOIN [SIS_Person].[dbo].RelatedItems with(NOLOCK)
				 ON RelatedItems.PIC = x.PIC

END
ELSE IF (@profileType = 'organization')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Organization.dbo.Photographs with(nolock) where OIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT RelatedOrganizations.OIC,RelatedActivities.AIC
	  FROM (SELECT *
			  FROM [SIS_Organization].[dbo].OrganizationInformation with(NOLOCK)
			 WHERE OrganizationInformation.OIC = @id
		   )x
	LEFT OUTER JOIN [SIS_Organization].[dbo].RelatedOrganizations with(NOLOCK)
				 ON RelatedOrganizations.OIC = x.OIC
				AND RelatedOrganizations.OIC <> @id
	LEFT OUTER JOIN [SIS_Organization].dbo.RelatedActivities with(NOLOCK)
				 ON RelatedActivities.OIC = x.OIC

END
ELSE IF (@profileType = 'activity')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Activity.dbo.Photographs with(nolock) where AIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT RelatedOrganization.OIC,RelatedActivities.AIC
	  FROM (SELECT *
			  FROM [SIS_Activity].[dbo].ActivityInformation with(NOLOCK)
			 WHERE ActivityInformation.AIC = @id
		   )x
	LEFT OUTER JOIN [SIS_Activity].dbo.RelatedOrganization with(NOLOCK)
				 ON RelatedOrganization.AIC = x.AIC
	LEFT OUTER JOIN [SIS_Activity].dbo.RelatedActivities with(NOLOCK)
				 ON RelatedActivities.[RelatedActivity(AIC)] = x.AIC

END
ELSE IF (@profileType = 'item')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Item.dbo.Photographs with(nolock) where IIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT RelatedPersons.PIC,RelatedOrganizations.OIC,RelatedActivity.AIC,RelatedItem.IIC
	  FROM (SELECT *
			  FROM [SIS_Item].[dbo].ItemInformation with(NOLOCK)
			 WHERE ItemInformation.IIC = @id
		   )x
	LEFT OUTER JOIN [SIS_Item].dbo.RelatedPersons with(NOLOCK)
				 ON RelatedPersons.IIC = x.IIC
	LEFT OUTER JOIN [SIS_Item].dbo.RelatedItem with(NOLOCK)
				 ON RelatedItem.[RelatedItems(IIC)] = x.IIC
	LEFT OUTER JOIN [SIS_Item].[dbo].[RelatedOrganizations] with(NOLOCK)
				 ON RelatedOrganizations.IIC = x.IIC
	LEFT OUTER JOIN [SIS_Item].[dbo].[RelatedActivity]with(NOLOCK)
				 ON RelatedActivity.IIC = x.IIC

END

SET @RelatedPerson = (SELECT ISNULL((SELECT PersonInformation.PIC AS 'PIC',
												PersonInformation.FirstName,
												PersonInformation.Surname,
												Photographs.PhotographsID
										   FROM SIS_Person.dbo.PersonInformation with(nolock)
									     INNER JOIN (SELECT DISTINCT PIC FROM #related WHERE PIC IS NOT NULL)pic
											     ON pic.PIC = PersonInformation.PIC 
                                         LEFT OUTER JOIN (SELECT PIC,ID AS 'PhotographsID'
															FROM (SELECT PIC,ID,ROW_NUMBER()OVER(PARTITION BY PIC ORDER BY (SELECT 0)) rw
															        FROM SIS_Person.dbo.Photographs with(nolock)
																 )x
														   WHERE x.rw = 1
                                                         )Photographs
													  ON Photographs.PIC = PersonInformation.PIC
			              FOR JSON PATH),'[]'))
SET @RelatedPerson = CONCAT('RelatedPeople:',@RelatedPerson)


SET @RelatedOrganization = (SELECT ISNULL((SELECT OrganizationInformation.OIC AS 'OIC',
                                                  OrganizationInformation.OrganizationName,
												  Photographs.PhotographsID
											 FROM SIS_Organization.dbo.OrganizationInformation with(nolock)
											   INNER JOIN (SELECT DISTINCT OIC FROM #related WHERE OIC IS NOT NULL)oic
												   	   ON oic.OIC = OrganizationInformation.OIC
										   LEFT OUTER JOIN (SELECT OIC,ID AS 'PhotographsID'
															  FROM (SELECT OIC,ID,ROW_NUMBER()OVER(PARTITION BY OIC ORDER BY (SELECT 0)) rw
															          FROM SIS_Organization.dbo.Photographs with(nolock)
																   )x
														     WHERE x.rw = 1
                                                           )Photographs
													    ON Photographs.OIC = OrganizationInformation.OIC
			              FOR JSON PATH),'[]'))
SET @RelatedOrganization = CONCAT('RelatedOrganization:',@RelatedOrganization)


SET @RelatedActivity = (SELECT ISNULL((SELECT ActivityInformation.AIC AS 'AIC',
												 DescriptionOfTheActivity AS 'DescriptionOftheActivity',
												 [StartDateTime] as 'StartDateTime',
												 Photographs.PhotographsID
									        FROM SIS_Activity.dbo.ActivityInformation with(nolock)
									      INNER JOIN (SELECT DISTINCT AIC FROM #related WHERE AIC IS NOT NULL)aic
									              ON ActivityInformation.AIC = aic.AIC
									      LEFT OUTER JOIN (SELECT AIC,ID AS 'PhotographsID'
														     FROM (SELECT AIC,ID,ROW_NUMBER()OVER(PARTITION BY AIC ORDER BY (SELECT 0)) rw
														             FROM SIS_Activity.dbo.Photographs with(nolock)
															      )x
													        WHERE x.rw = 1
									                       )Photographs
											           ON Photographs.AIC = ActivityInformation.AIC
			              FOR JSON PATH),'[]'))
SET @RelatedActivity = CONCAT('RelatedActivity:',@RelatedActivity)


SET @RelatedItem = (SELECT ISNULL((SELECT ItemInformation.IIC AS 'IIC',
                                          ItemInformation.DescriptionOfItem,
										  ItemInformation.[MainIdentifyingNumber],
										  Photographs.PhotographsID
							         FROM SIS_Item.dbo.ItemInformation with(nolock)
							      INNER JOIN (SELECT DISTINCT IIC FROM #related WHERE IIC IS NOT NULL)iic
									      ON ItemInformation.IIC = iic.IIC
								  LEFT OUTER JOIN (SELECT IIC,ID AS 'PhotographsID'
													 FROM (SELECT IIC,ID,ROW_NUMBER()OVER(PARTITION BY IIC ORDER BY (SELECT 0)) rw
													         FROM SIS_Item.dbo.Photographs with(nolock)
													      )x
													WHERE x.rw = 1
									              )Photographs
											   ON Photographs.IIC = ItemInformation.IIC
			              FOR JSON PATH),'[]'))
SET @RelatedItem = CONCAT('RelatedItem:',@RelatedItem)




SELECT CONCAT('{',@RelatedPerson,',',@RelatedOrganization,',',@RelatedActivity,',',@RelatedItem,',',@Photographs,'}')

END






 
 --[GET_SEARCH_RESULT_SUMMARY] 16,'person'
GO
