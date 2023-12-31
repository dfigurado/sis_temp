USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[GLOBAL_SEARCH_]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GLOBAL_SEARCH_] (@SearchStr nvarchar(100),@MIN int,@MAX int)
AS
BEGIN

DECLARE @TableNamePIC nvarchar(256), @ColumnNamePIC nvarchar(128)
    SET @TableNamePIC = ''
    SET @SearchStr = QUOTENAME('%' + @SearchStr + '%','''')


CREATE TABLE #ResultsPIC (PIC bigint)


    WHILE @TableNamePIC IS NOT NULL
    BEGIN
        SET @ColumnNamePIC = ''
        SET @TableNamePIC = 
						(	
							SELECT MIN('[dbo]' + '.' + QUOTENAME(TABLENAME))
							  FROM SIS_Person.dbo.InformationTable
						     WHERE ('[dbo]' + '.' + QUOTENAME(TABLENAME)) > @TableNamePIC
						)

        WHILE (@TableNamePIC IS NOT NULL) AND (@ColumnNamePIC IS NOT NULL)
        BEGIN
            SET @ColumnNamePIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Person.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNamePIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNamePIC, 1)
								   --AND COLUMN_NAME <> 'ID'
								   --AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNamePIC
							)

				IF((SELECT COUNT(*) FROM #ResultsPIC) < @max AND @ColumnNamePIC IS NOT NULL)
				BEGIN
					INSERT INTO #ResultsPIC 
					EXEC
					(
						'SELECT DISTINCT PIC
						   FROM SIS_Person.' + @TableNamePIC + ' (NOLOCK) ' +
						' WHERE ' + @ColumnNamePIC + ' LIKE ' + @SearchStr
					)
				END
        END
    END



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY PIC ORDER BY PIC) AS rw
		  FROM #ResultsPIC
	)
DELETE FROM CTE1 WHERE rw <>1;


CREATE INDEX IX_PIC ON #ResultsPIC (PIC)


		SELECT * 
		  FROM (SELECT	CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 0))  AS int)ID ,
						'people' AS 'Type',
						'colorIndicator--People' AS 'Class',
						CONCAT(PersonInformation.PIC,' - ',LTRIM(RTRIM(CONCAT(ISNULL(Surname,''),' ',ISNULL(Initials,''),' ',ISNULL(FirstName,''),' ',ISNULL(SecondName,''))))) AS 'Title',								
						[Description] 'Value1',
						Identification.IdNumber AS 'Value2',
						CONVERT(NVARCHAR(10),DateOfBirth,103) AS 'Value3',
						Organizations.OrganizationName AS 'Value4',
						--Organizations.Position AS 'Value5',
						SecurityClassifications.SecurityClassification AS 'Value5',
						CONVERT(NVARCHAR(10),PersonInformation.EnteredDate,103) AS 'Value6',
						--EnteredDate,
						CAST((SELECT COUNT(*)
						   FROM SIS_Person.[dbo].[PersonInformation] p with(nolock)
						 INNER JOIN #ResultsPIC pic ON pic.PIC = p.PIC
						 INNER JOIN SIS_Person.[dbo].SystemDetails sd with(nolock)
								 ON sd.PIC = p.PIC
					     WHERE sd.IsDeleted = 0
						)AS int)  [COUNT]
				   FROM (SELECT p.*,pd.[Description],sd.EnteredDate
						   FROM SIS_Person.[dbo].[PersonInformation] p with(nolock)
						 INNER JOIN #ResultsPIC pic ON pic.PIC = p.PIC
						 INNER JOIN SIS_Person.[dbo].SystemDetails sd with(nolock)
								 ON sd.PIC = p.PIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = Desk
						 WHERE sd.IsDeleted = 0
						)PersonInformation
				LEFT OUTER JOIN (SELECT PIC,IdNumber,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY IdNumber)rw
									FROM SIS_Person.[dbo].Identification with(nolock)
								   WHERE [Type] = 'NIC'
									 AND (Validity IS NULL OR Validity <> 'fake')
								 )Identification
							  ON Identification.PIC = PersonInformation.PIC
				LEFT OUTER JOIN (SELECT PIC,a.Position,b.OrganizationName
									FROM SIS_Person.[dbo].[Organizations] a with(nolock)
								  INNER JOIN SIS_Organization.dbo.OrganizationInformation b with(nolock)
										  ON a.OIC = b.OIC
								   WHERE [Type] = 'Main'
								 )Organizations
							  ON Organizations.PIC = PersonInformation.PIC

				LEFT OUTER JOIN (SELECT PIC,SecurityClassification
				                   FROM (SELECT sc.PIC,SecurityClassification,ROW_NUMBER() OVER(PARTITION BY sc.PIC ORDER BY [DateFrom],[DateTo] DESC)rw
										   FROM [dbo].[SecurityClassifications] sc  with(nolock)
										 INNER JOIN #ResultsPIC pic  with(nolock) ON pic.PIC = sc.PIC
										 )y
								  WHERE y.rw = 1
								 ) SecurityClassifications
							  ON SecurityClassifications.PIC = PersonInformation.PIC
			  )a
        WHERE a.ID BETWEEN @MIN AND @MAX  


END

GO
