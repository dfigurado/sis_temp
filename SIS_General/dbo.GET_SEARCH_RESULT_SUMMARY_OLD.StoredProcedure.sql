USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SEARCH_RESULT_SUMMARY_OLD]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_SEARCH_RESULT_SUMMARY_OLD] (@id bigint ,@profileType nvarchar(MAX))
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
	SELECT DISTINCT CasePerson.PIC,CaseOrganization.OIC,CaseActivity.AIC,CaseItem.IIC	
	  FROM (SELECT *
			  FROM [SIS_General].[dbo].[CasePerson] with(NOLOCK)
			 WHERE CasePerson.PIC = @id
		   )x
	LEFT OUTER JOIN SIS_General.dbo.CasePerson with(NOLOCK)
				 ON CasePerson.CaseID = x.CaseID
				AND CasePerson.PIC <> @id
	LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
				 ON CaseOrganization.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
				 ON CaseActivity.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
				 ON CaseItem.CaseID = x.CaseID	

END
ELSE IF (@profileType = 'organization')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Organization.dbo.Photographs with(nolock) where OIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT CasePerson.PIC,CaseOrganization.OIC,CaseActivity.AIC,CaseItem.IIC
	  FROM (SELECT *
			  FROM [SIS_General].[dbo].[CaseOrganization] with(NOLOCK)
			 WHERE CaseOrganization.OIC = @id
		   )x
	LEFT OUTER JOIN SIS_General.dbo.CasePerson with(NOLOCK)
				 ON CasePerson.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
				 ON CaseOrganization.CaseID = x.CaseID
				AND CaseOrganization.OIC <> @id
	LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
				 ON CaseActivity.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
				 ON CaseItem.CaseID = x.CaseID

END
ELSE IF (@profileType = 'activity')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Activity.dbo.Photographs with(nolock) where AIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT CasePerson.PIC,CaseOrganization.OIC,CaseActivity.AIC,CaseItem.IIC
	  FROM (SELECT *
			  FROM [SIS_General].[dbo].[CaseActivity] with(NOLOCK)
			 WHERE CaseActivity.AIC = @id
		   )x
	LEFT OUTER JOIN SIS_General.dbo.CasePerson with(NOLOCK)
				 ON CasePerson.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
				 ON CaseOrganization.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
				 ON CaseActivity.CaseID = x.CaseID
				AND CaseActivity.AIC <> @id
	LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
				 ON CaseItem.CaseID = x.CaseID

END
ELSE IF (@profileType = 'item')
BEGIN

	SET @Photographs = CONCAT('Photographs:', (SELECT ISNULL(( select * from SIS_Item.dbo.Photographs with(nolock) where IIC=@id for json auto),'[]')))
	insert into #related
	SELECT DISTINCT CasePerson.PIC,CaseOrganization.OIC,CaseActivity.AIC,CaseItem.IIC
	  FROM (SELECT *
			  FROM [SIS_General].[dbo].[CaseItem] with(NOLOCK)
			 WHERE CaseItem.IIC = @id
		   )x
	LEFT OUTER JOIN SIS_General.dbo.CasePerson with(NOLOCK)
				 ON CasePerson.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseOrganization with(NOLOCK)
				 ON CaseOrganization.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseActivity with(NOLOCK)
				 ON CaseActivity.CaseID = x.CaseID
	LEFT OUTER JOIN SIS_General.dbo.CaseItem with(NOLOCK)
				 ON CaseItem.CaseID = x.CaseID
				AND CaseItem.IIC <> @id

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






 
 --[GET_SEARCH_RESULT_SUMMARY] 1,'activity'
GO
