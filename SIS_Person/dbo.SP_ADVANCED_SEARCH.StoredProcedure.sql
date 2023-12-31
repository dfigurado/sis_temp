USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[ADVANCED_SEARCH]    Script Date: 08/06/2023 13:14:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ADVANCED_SEARCH](@WQUERY NVARCHAR(MAX),@MIN NVARCHAR(MAX),@MAX NVARCHAR(MAX))
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

					declare @test nvarchar(max)
INSERT INTO #temp
		EXEC  ('SELECT * 
				  FROM (SELECT  CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS int)''ID'' ,
								''people'' AS ''Type'',
								''colorIndicator--People'' AS ''Class'',							
								CONCAT(PersonInformation.PIC,'' - '',LTRIM(RTRIM(CONCAT(ISNULL(Surname,'' ''),/*'' '',ISNULL(Initials,'' ''),*/'' '',ISNULL(FirstName,'' ''),'' '',ISNULL(SecondName,'' ''))))) AS ''Title'',
								[Description] ''Value1'',
								Identification.IdNumber AS ''Value2'',
								CONVERT(NVARCHAR(MAX),DateOfBirth,103) AS ''Value3'',
								Organizations.OrganizationName AS ''Value4'',
								SecurityClassifications.SecurityClassification AS ''Value5'',
								CONVERT(NVARCHAR(MAX),PersonInformation.EnteredDate,103) AS ''Value6''
						   FROM (SELECT p.*,[Description],sd.EnteredDate
								   FROM [dbo].[PersonInformation] p with(nolock)
								 INNER JOIN SystemDetails sd with(nolock)
										 ON sd.PIC = p.PIC
								 INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
								         ON pd.ID = sd.Desk
								)PersonInformation
						 LEFT OUTER JOIN (SELECT PIC,IdNumber
						                    FROM(SELECT PIC,IdNumber,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY IdNumber)rw
												   FROM Identification with(nolock)
										          WHERE [Type] = ''NIC''
											        AND (Validity IS NULL OR Validity <> ''fake'')
											    )x
									       WHERE x.rw = 1
										 )Identification
									  ON Identification.PIC = PersonInformation.PIC

						 LEFT OUTER JOIN (SELECT PIC,a.Position,b.OrganizationName,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY PIC)as rx
											FROM [dbo].[Organizations] a with(nolock)
										  INNER JOIN SIS_Organization.dbo.OrganizationInformation b with(nolock)
												  ON a.OIC = b.OIC
										   WHERE [Type] = ''Main''
										 )Organizations
									  ON Organizations.PIC = PersonInformation.PIC and Organizations.rx=1
						
						LEFT OUTER JOIN (SELECT PIC,SecurityClassification
						                   FROM (SELECT PIC,SecurityClassification,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY [DateFrom],[DateTo] DESC)rw
												   FROM [dbo].[SecurityClassifications] sc  with(nolock)
												 )y
										  WHERE y.rw = 1
										 ) SecurityClassifications
									  ON SecurityClassifications.PIC = PersonInformation.PIC

						 INNER JOIN (select DISTINCT PersonInformation.PIC 
									   from PersonInformation with(nolock)
									 inner join SystemDetails with(nolock)
									 		 on PersonInformation.PIC = SystemDetails.PIC
									 left outer join SecurityClassifications with(nolock)
									 			  on PersonInformation.PIC = SecurityClassifications.PIC
									 left outer join Identification with(nolock)
									 			  on Identification.PIC = PersonInformation.PIC
									 left outer join Addresses with(nolock)
									 			  on Addresses.PIC = PersonInformation.PIC
									 left outer join Occupations with(nolock)
									 			  on Occupations.PIC = PersonInformation.PIC
									 LEFT OUTER JOIN (SELECT PIC,FileReference FROM FileReferences with(nolock)
													  UNION
													  SELECT PIC,FileReferenceNumber FROM NarrativeInformation with(nolock)
													 )FileReferences
									              ON FileReferences.PIC = PersonInformation.PIC
									 LEFT OUTER JOIN Organizations with(nolock)
												  ON Organizations.PIC =  PersonInformation.PIC
									LEFT OUTER JOIN Nationality with(nolock)
												  ON Nationality.PIC =  PersonInformation.PIC
									 LEFT OUTER JOIN Aliases with(nolock)
									              ON Aliases.PIC = PersonInformation.PIC
									 LEFT OUTER JOIN AKA with(nolock)
									              ON AKA.PIC=PersonInformation.PIC
									   where SystemDetails.[IsDeleted] = 0 
								         AND '+@WQUERY+'									 
									 ) y
								 ON PersonInformation.PIC = y.PIC
							)z'
		       )

DECLARE @i AS INT = (SELECT COUNT(*) FROM #temp)

SELECT [ID],[Type],[Class], [Title],[Value1],[Value2],[Value3],[Value4],[Value5],[Value6],
       [Count] = (SELECT @i)
  FROM #temp
 WHERE ID BETWEEN @MIN AND @MAX

END
GO
