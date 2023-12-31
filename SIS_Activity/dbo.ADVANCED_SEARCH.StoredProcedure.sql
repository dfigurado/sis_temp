USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[ADVANCED_SEARCH]    Script Date: 08/06/2023 12:36:43 ******/
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

INSERT INTO #temp
EXEC ('
       SELECT * 
        FROM (SELECT  CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS int)''ID'' ,
       				''activity'' AS Type,
       				''colorIndicator--Incidents'' AS ''Class'',
       				CONCAT(ActivityInformation.AIC,'' - '',ActivityInformation.DescriptionOfTheActivity) AS ''Title'',
       				[Description] ''Value1'',
       				ActivityInformation.Place AS ''Value2'',
       				CONVERT(NVARCHAR(MAX),ActivityInformation.StartDateTime,103) AS ''Value3'',
					CONVERT(NVARCHAR(MAX),ActivityInformation.EndDateTime,103) AS ''Value4'',
       				NULL AS ''Value5'',
       				CONVERT(NVARCHAR(MAX),ActivityInformation.EnteredDate,103) AS ''Value6''
       		   FROM (SELECT ai.*,pd.[Description],sd.EnteredDate
       				   FROM ActivityInformation ai with(nolock)
       				 INNER JOIN SystemDetails sd with(nolock)
       		 				 ON sd.AIC = ai.AIC
					 INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					         ON pd.ID = sd.DeskTarget
                    )ActivityInformation
              INNER JOIN (select DISTINCT ActivityInformation.AIC
							from ActivityInformation with(nolock)
						  inner join SystemDetails with(nolock)
						          on ActivityInformation.AIC = SystemDetails.AIC
						  left outer join ModusOperandi with(nolock)
						               on ActivityInformation.AIC = ModusOperandi.AIC
						  left outer join InstitutionsAffected with(nolock)
						               on InstitutionsAffected.AIC = ActivityInformation.AIC
              			   where SystemDetails.[IsDeleted] = 0 
              		         AND '+@WQUERY+'									 
              			 ) y
              		 ON ActivityInformation.AIC = y.AIC
              	)z'
              		)

DECLARE @i AS INT = (SELECT COUNT(*) FROM #temp)

SELECT [ID],[Type],[Class], [Title],[Value1],[Value2],[Value3],[Value4],[Value5],[Value6],
       [Count] = (SELECT @i)
  FROM #temp
 WHERE ID BETWEEN @MIN AND @MAX

END
GO
