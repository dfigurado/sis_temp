use [SIS_Organization]
GO

/****** Object:  StoredProcedure [dbo].[MAINSEARCH]    Script Date: 30/06/2023 16:35:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MAINSEARCH] (@SearchStr nvarchar(100),@MIN int,@MAX int)
AS
BEGIN


SET @SearchStr = QUOTENAME('%'+ @SearchStr + '%','''')

CREATE TABLE #ResultsOIC (OIC bigint)


INSERT INTO #ResultsOIC 
						EXEC
						(
							'SELECT DISTINCT OIC
							   FROM [SIS_Organization].[dbo].[OrganizationInformation] with(nolock) ' +
							' WHERE OrganizationName LIKE ' + @SearchStr 
						)

;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY OIC ORDER BY OIC) AS rw
		  FROM #ResultsOIC
	)
DELETE FROM CTE1 WHERE rw <>1;

CREATE INDEX IX_PIC ON #ResultsOIC (OIC)

	SELECT *
		  FROM (SELECT CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS  int) AS 'ID',
		               'organization' AS 'Type',
					   'colorIndicator--Org' AS 'Class',
					   CONCAT(OrganizationInformation.OIC,' - ',OrganizationName) AS 'Title',
					   [Description] 'Value1',
					   Aliases.AliasName AS 'Value2',
					   RelatedOrganizationName AS 'Value3',
					   NULL AS 'Value4',
					   NULL AS 'Value5',
					   --CAST(EnteredDate AS NVARCHAR) AS 'Value6',
					   CONVERT(NVARCHAR(10),OrganizationInformation.EnteredDate,103) AS 'Value6',
					   --EnteredDate,
					   (SELECT COUNT(*)
						  FROM SIS_Organization.dbo.OrganizationInformation oi with(nolock)
						INNER JOIN SIS_Organization.dbo.SystemDetails sd with(nolock)
								ON sd.OIC = oi.OIC
						INNER JOIN #ResultsOIC o
								ON o.OIC = oi.OIC
					     WHERE sd.IsDeleted = 0
					   ) AS [COUNT]
				  FROM (SELECT oi.*,pd.[Description],EnteredDate
						  FROM SIS_Organization.dbo.OrganizationInformation oi with(nolock)
						INNER JOIN SIS_Organization.dbo.SystemDetails sd with(nolock)
								ON sd.OIC = oi.OIC
						INNER JOIN #ResultsOIC o
								ON o.OIC = oi.OIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
						WHERE sd.IsDeleted = 0
					   )OrganizationInformation
				LEFT OUTER JOIN (SELECT TOP 1 OIC,AliasName
								   FROM SIS_Organization.dbo.Aliases with(nolock)
								)Aliases
							 ON Aliases.OIC = OrganizationInformation.OIC
				LEFT OUTER JOIN (SELECT TOP(1) ro.*,oi.OrganizationName AS 'RelatedOrganizationName'
								   FROM SIS_Organization.dbo.RelatedOrganizations ro with(nolock) 
								 INNER JOIN SIS_Organization.dbo.OrganizationInformation oi with(nolock)
										 ON oi.OIC = ro.[RelatedOrganizations(OIC)]
										 order by ro.ID desc
								)RelatedOrganizations
							 ON RelatedOrganizations.OIC = OrganizationInformation.OIC
							
				)y
        WHERE y.ID BETWEEN @MIN AND @MAX

END
GO


