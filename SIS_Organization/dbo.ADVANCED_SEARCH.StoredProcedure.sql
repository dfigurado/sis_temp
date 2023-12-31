USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[ADVANCED_SEARCH]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ADVANCED_SEARCH](@WQUERY NVARCHAR(MAX),@MIN NVARCHAR(MAX),@MAX NVARCHAR(MAX))
AS
BEGIN

SET @WQUERY = REPLACE(@WQUERY,'_~_','%')
SET @WQUERY = REPLACE(@WQUERY,'~','.')

CREATE TABLE #temp( [ID] [int] NOT NULL,
					[Type]   [nvarchar](max) NULL,
					[Class]  [nvarchar](max) NULL,
					[Title]  [nvarchar](max) NULL,
					[Value1] [nvarchar](max) NULL,
					[Value2] [nvarchar](max) NULL,
					[Value3] [nvarchar](max) NULL,
					[Value4] [nvarchar](max) NULL,
					[Value5] [nvarchar](max) NULL,
					[Value6] [nvarchar](max) NULL)

INSERT INTO #temp
EXEC ('
								SELECT * 
								  FROM (SELECT  CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS int)''ID'' ,
											   ''organization'' AS ''Type'',
											   ''colorIndicator--Org'' AS ''Class'',
											   CONCAT(OrganizationInformation.OIC,'' - '',OrganizationName) AS ''Title'',
											   OrganizationInformation.[Description] ''Value1'',
											   Aliases.AliasName AS ''Value2'',
											   RelatedOrganizationName AS ''Value3'',
											   NULL AS ''Value4'',
											   NULL AS ''Value5'',
											   CONVERT(NVARCHAR(MAX),EnteredDate,103) AS ''Value6''
										  FROM (SELECT oi.*,[Description],sd.DeskTarget,sd.EnteredDate,sd.[IsDeleted]
												  FROM OrganizationInformation oi with(nolock)
												INNER JOIN SystemDetails sd with(nolock)
														ON sd.OIC = oi.OIC
												INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
														ON pd.ID = sd.DeskTarget
											   )OrganizationInformation
										LEFT OUTER JOIN (SELECT OIC,AliasName
										                   FROM (SELECT OIC,AliasName,ROW_NUMBER() OVER(PARTITION BY OIC ORDER BY AliasName)rw
														           FROM Aliases with(nolock)
                                                                )a
														  WHERE a.rw = 1
														)Aliases
													 ON Aliases.OIC = OrganizationInformation.OIC
											LEFT OUTER JOIN (SELECT OIC,OrganizationAddress
										                   FROM (SELECT OIC,OrganizationAddress,ROW_NUMBER() OVER(PARTITION BY OIC ORDER BY OrganizationAddress)rws
														           FROM Addresses with(nolock)
                                                                )a
														  WHERE a.rws = 1
														)Addresses
													 ON Addresses.OIC = OrganizationInformation.OIC
										LEFT OUTER JOIN (SELECT ro.*,oi.OrganizationName AS ''RelatedOrganizationName'',ROW_NUMBER() OVER(PARTITION BY ro.OIC ORDER BY ro.OIC desc)as rx
														   FROM RelatedOrganizations ro with(nolock)
														 INNER JOIN OrganizationInformation oi with(nolock)
																 ON oi.OIC = ro.[RelatedOrganizations(OIC)]
														)RelatedOrganizations
													 ON RelatedOrganizations.OIC = OrganizationInformation.OIC and RelatedOrganizations.rx=1
										   WHERE OrganizationInformation.[IsDeleted] = 0 AND '+@WQUERY+')x'
										   )

										  
SELECT [ID],[Type],[Class], [Title],[Value1],[Value2],[Value3],[Value4],[Value5],[Value6],
       [Count] = (SELECT COUNT(*) FROM #temp)
  FROM #temp
 WHERE ID BETWEEN @MIN AND @MAX

END



GO
