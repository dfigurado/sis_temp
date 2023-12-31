USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[GLOBAL_SEARCH]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GLOBAL_SEARCH] (@SearchStr nvarchar(100),@MIN int,@MAX int)
AS
BEGIN

DECLARE @TableNameIIC nvarchar(256), @ColumnNameIIC nvarchar(128)
    SET @TableNameIIC = ''
    SET @SearchStr = QUOTENAME(@SearchStr + '%','''')

CREATE TABLE #ResultsIIC (IIC bigint)


WHILE @TableNameIIC IS NOT NULL 
    BEGIN
        SET @ColumnNameIIC = ''
        SET @TableNameIIC = 
						(	
							SELECT MIN('[dbo]' + '.' + QUOTENAME(TABLENAME))
							  FROM [SIS_Item].dbo.INFORMATIONTABLE
						     WHERE ('[dbo]' + '.' + QUOTENAME(TABLENAME)) > @TableNameIIC
						)

        WHILE (@TableNameIIC IS NOT NULL) AND (@ColumnNameIIC IS NOT NULL)
        BEGIN
            SET @ColumnNameIIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Item.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNameIIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNameIIC, 1)
								   --AND COLUMN_NAME <> 'ID'
								   --AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNameIIC
							)


		    IF((SELECT COUNT(*) FROM #ResultsIIC) < @max AND @ColumnNameIIC IS NOT NULL)
            BEGIN
					INSERT INTO #ResultsIIC
					EXEC
					(
					    'SELECT DISTINCT IIC
					       FROM SIS_Item.' + @TableNameIIC + ' (NOLOCK) ' +
					    ' WHERE ' + @ColumnNameIIC + ' LIKE ' + @SearchStr
					)
            END
        END
END


;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY IIC ORDER BY IIC) AS rw
		  FROM #ResultsIIC
	)
DELETE FROM CTE1 WHERE rw <>1;


CREATE INDEX IX_PIC ON #ResultsIIC (IIC)


		SELECT * 
		  FROM (SELECT CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS  int) AS 'ID' ,
					   'item' AS 'Type',
					   'colorIndicator--Items' AS 'Class',
					   CONCAT(ItemInformation.IIC,' - ',DescriptionOfItem) AS 'Title',
					   [Description] 'Value1',
					   MainIdentifyingNumber AS 'Value2',
					   NULL AS 'Value3',
					   NULL AS 'Value4',
					   NULL AS 'Value5',
					   CONVERT(NVARCHAR(10),ItemInformation.EnteredDate,103) AS 'Value6',
					   --EnteredDate,
					   (SELECT COUNT(*)
						  FROM SIS_Item.dbo.ItemInformation i with(nolock)
						INNER JOIN SIS_Item.dbo.SystemDetails sd with(nolock) 
						 	    ON sd.IIC = i.IIC
						INNER JOIN #ResultsIIC c ON c.IIC = i.IIC
					     WHERE sd.IsDeleted = 0
					   ) AS [COUNT] 
				  FROM(SELECT i.*,pd.[Description],sd.EnteredDate
						 FROM SIS_Item.dbo.ItemInformation i with(nolock)
					   INNER JOIN SIS_Item.dbo.SystemDetails sd with(nolock) 
							   ON sd.IIC = i.IIC
					   INNER JOIN #ResultsIIC c ON c.IIC = i.IIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
					   WHERE sd.IsDeleted = 0
					  )ItemInformation
			   )x
        WHERE x.ID BETWEEN @MIN AND @MAX  

END
GO
