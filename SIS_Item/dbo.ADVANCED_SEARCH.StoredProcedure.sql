USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[ADVANCED_SEARCH]    Script Date: 08/06/2023 13:08:17 ******/
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
EXEC('
								SELECT * 
								  FROM (SELECT  CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS int)''ID'' ,
											   ''item'' AS ''Type'',
											   ''colorIndicator--Items'' AS ''Class'',
											   CONCAT(ItemInformation.IIC,'' - '',DescriptionOfItem) AS ''Title'',
											   [Description] ''Value1'',
											   ItemInformation.MainIdentifyingNumber AS ''Value2'',
											   NULL AS ''Value3'',
											   NULL AS ''Value4'',
											   NULL AS ''Value5'',
											   CONVERT(NVARCHAR(MAX),EnteredDate,103) AS ''Value6''
										  FROM(SELECT i.*,pd.[Description],sd.EnteredDate
												 FROM ItemInformation i with(nolock)
											   INNER JOIN SystemDetails sd with(nolock) 
											           ON sd.IIC = i.IIC 
                                               INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd
											           ON pd.ID = sd.DeskTarget
											  )ItemInformation
										INNER JOIN (select DISTINCT ItemInformation.IIC
													  from ItemInformation
													inner join SystemDetails
													        on ItemInformation.IIC = SystemDetails.IIC
													left outer join OtherIdentifyingNumbers
													             on ItemInformation.IIC = OtherIdentifyingNumbers.IIC
													left outer join DetailsOfRecovery
													             on DetailsOfRecovery.IIC = ItemInformation.IIC
													  where SystemDetails.[IsDeleted] = 0 
													 AND '+@WQUERY+'									 
													) y
												 ON ItemInformation.IIC = y.IIC
											)z'
								)
DECLARE @i AS INT = (SELECT COUNT(*) FROM #temp)

SELECT [ID],[Type],[Class], [Title],[Value1],[Value2],[Value3],[Value4],[Value5],[Value6],
       [Count] = (SELECT @i)
  FROM #temp
 WHERE ID BETWEEN @MIN AND @MAX

END
GO
