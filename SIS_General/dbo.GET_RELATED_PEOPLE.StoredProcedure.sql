USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_RELATED_PEOPLE]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RELATED_PEOPLE](@CASEID BIGINT)
AS
BEGIN

SELECT  PersonInformation.PIC,(SELECT [Description] FROM SIS_General.DBO.Predefined_DeskTarget WHERE ID = PersonInformation.Desk) AS DeskName,
        PersonInformation.EnteredDate AS 'EnteredDate',
        LTRIM(RTRIM(CONCAT(ISNULL(Surname,' '),' ',ISNULL(Initials,' '),' ',ISNULL(FirstName,' '),' ',ISNULL(SecondName,' ')))) AS 'FullName',
		Identification.IdNumber AS 'NIC',
	    DateOfBirth AS 'DOB',
	    Organizations.Position AS 'PrimeDesignation',Organizations.OrganizationName AS 'MainOrganizationName'
  FROM (SELECT p.*,sd.Desk,sd.EnteredDate, [Case].AddedOn
		   FROM SIS_Person.[dbo].[PersonInformation] p with(nolock)
		 INNER JOIN SIS_Person.[dbo].SystemDetails sd with(nolock)
		         ON sd.PIC = p.PIC
		 INNER JOIN (SELECT PIC, AddedOn FROM SIS_General.dbo.[Case] with(nolock)
					 INNER JOIN SIS_General.dbo.CasePerson with(nolock)
							 ON CasePerson.CaseID = [Case].ID
					 WHERE [Case].ID  = @CASEID
					)[Case]
				 ON [Case].PIC = p.PIC
	   )PersonInformation
 LEFT OUTER JOIN (SELECT TOP 1 PIC,IdNumber 
				    FROM SIS_Person.[dbo].Identification with(nolock)
				   WHERE [Type] = 'NIC'
					 AND (Validity IS NULL OR Validity <> 'fake')
				  ORDER BY PIC DESC
				 )Identification
			  ON Identification.PIC = PersonInformation.PIC
 LEFT OUTER JOIN (SELECT PIC,a.Position,b.OrganizationName,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY PIC)as rx
				    FROM SIS_Person.[dbo].[Organizations] a with(nolock)
				  INNER JOIN SIS_Organization.dbo.OrganizationInformation b with(nolock)
						  ON a.OIC = b.OIC
				   WHERE [Type] = 'Main'
				 )Organizations
			  ON Organizations.PIC = PersonInformation.PIC and Organizations.rx=1
			  Order by AddedOn desc

END

GO
