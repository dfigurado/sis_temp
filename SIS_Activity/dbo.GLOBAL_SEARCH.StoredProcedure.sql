USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[GLOBAL_SEARCH]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GLOBAL_SEARCH] (@SearchStr nvarchar(100),@MIN int,@MAX int)
AS
BEGIN

DECLARE @TableNameAIC nvarchar(256), @ColumnNameAIC nvarchar(128)
    SET @TableNameAIC = ''
    SET @SearchStr = QUOTENAME(@SearchStr + '%','''')


CREATE TABLE #ResultsAIC (AIC bigint)


WHILE @TableNameAIC IS NOT NULL 
    BEGIN
        SET @ColumnNameAIC = ''
        SET @TableNameAIC = 
						(	
							SELECT MIN('[dbo]' + '.' + QUOTENAME(TABLENAME))
							  FROM SIS_Activity.dbo.INFORMATIONTABLE
						     WHERE ('[dbo]' + '.' + QUOTENAME(TABLENAME)) > @TableNameAIC
						)

        WHILE (@TableNameAIC IS NOT NULL) AND (@ColumnNameAIC IS NOT NULL)
        BEGIN
            SET @ColumnNameAIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Activity.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNameAIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNameAIC, 1)
								   --AND COLUMN_NAME <> 'ID'
								   --AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNameAIC
							)

				IF((SELECT COUNT(*) FROM #ResultsAIC) < @max AND @ColumnNameAIC IS NOT NULL)
				BEGIN
					INSERT INTO #ResultsAIC
					EXEC
					(
						'SELECT DISTINCT AIC
						   FROM SIS_Activity.' + @TableNameAIC + ' (NOLOCK) ' +
						' WHERE ' + @ColumnNameAIC + ' LIKE ' + @SearchStr
					)
            END
        END
END



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY AIC ORDER BY AIC) AS rw
		  FROM #ResultsAIC
	)
DELETE FROM CTE1 WHERE rw <>1;


CREATE INDEX IX_AIC ON #ResultsAIC (AIC)


		SELECT * 
		  FROM (SELECT CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS  int) AS 'ID',
		                'activity' AS Type,
						'colorIndicator--Incidents' AS 'Class',
						CONCAT(ActivityInformation.AIC,' - ',ActivityInformation.DescriptionOfTheActivity) AS 'Title',
						[Description] 'Value1',
						ActivityInformation.Place AS 'Value2',
						CONVERT(NVARCHAR(10),ActivityInformation.StartDateTime,103) AS 'Value3',
						CONVERT(NVARCHAR(10),ActivityInformation.EndDateTime,103) AS 'Value4',
						NULL AS 'Value5',
						CONVERT(NVARCHAR(10),ActivityInformation.EnteredDate,103) AS 'Value6',
						--EnteredDate,
						(SELECT COUNT(*)
							FROM SIS_Activity.dbo.ActivityInformation ai with(nolock)
						INNER JOIN SIS_Activity.dbo.SystemDetails sd with(nolock)
								ON sd.AIC = ai.AIC
						INNER JOIN #ResultsAIC a 
								ON a.AIC = ai.AIC
					     WHERE sd.IsDeleted = 0
					   )AS [COUNT]
				  FROM (SELECT ai.*,pd.[Description],sd.EnteredDate
							FROM SIS_Activity.dbo.ActivityInformation ai with(nolock)
						INNER JOIN SIS_Activity.dbo.SystemDetails sd with(nolock)
								ON sd.AIC = ai.AIC
						INNER JOIN #ResultsAIC a 
								ON a.AIC = ai.AIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
						WHERE sd.IsDeleted = 0
						 )ActivityInformation
			  )z
        WHERE z.ID BETWEEN @MIN AND @MAX  
END
GO
