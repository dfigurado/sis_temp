USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GLOBAL_SEARCH]    Script Date: 08/06/2023 13:06:49 ******/
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


CREATE TABLE #SearchTemp([ID] [int] NOT NULL,[Type] [nvarchar](max) NULL,[Class] [nvarchar](max) NULL,[Title] [nvarchar](max) NULL,
					 	 [Value1] [nvarchar](max) NULL,[Value2] [nvarchar](max) NULL,[Value3] [nvarchar](max) NULL,[Value4] [nvarchar](max) NULL,
	                     [Value5] [nvarchar](max) NULL,[Value6] [nvarchar](max) NULL,EnteredDate DATETIME NULL,[COUNT] int) 


DECLARE @TableNameIIC nvarchar(256), @ColumnNameIIC nvarchar(128), @SearchStr2 nvarchar(110)
    SET @TableNameIIC = ''
    SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')


-- =============================================
-- IIC
-- =============================================

CREATE TABLE #ResultsIIC (TableName nvarchar(256) ,ColumnName nvarchar(370), ColumnValue nvarchar(3630))
CREATE TABLE #tmptableIIC (VAL nVARCHAR(MAX))
CREATE TABLE #IIC (IIC bigint)


WHILE @TableNameIIC IS NOT NULL 
    BEGIN
        SET @ColumnNameIIC = ''
        SET @TableNameIIC = 
						(	SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
							  FROM SIS_Item.INFORMATION_SCHEMA.TABLES
							 WHERE TABLE_TYPE = 'BASE TABLE'
							   AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableNameIIC
							   AND TABLE_NAME NOT IN ('sysdiagrams','Keyword_Search','Advanced_Search_Criteria','Photographs' )
							   --AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
						)

        WHILE (@TableNameIIC IS NOT NULL) AND (@ColumnNameIIC IS NOT NULL)
        BEGIN
            SET @ColumnNameIIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Item.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNameIIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNameIIC, 1)
								   AND COLUMN_NAME <> 'ID'
								   AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNameIIC
							)

            IF @ColumnNameIIC IS NOT NULL
            BEGIN
				IF (@TableNameIIC NOT IN ('[dbo].[sysdiagrams]','[dbo].[Keyword_Search]','[dbo].[Advanced_Search_Criteria]','[dbo].[Photographs]' ))
				BEGIN
					INSERT INTO #ResultsIIC
					EXEC
					(
					    'SELECT ''' + @TableNameIIC +''',''' + @TableNameIIC + '.' + @ColumnNameIIC + ''', LEFT(' + @ColumnNameIIC + ', 3630) 
					       FROM SIS_Item.' + @TableNameIIC + ' (NOLOCK) ' +
					    ' WHERE ' + @ColumnNameIIC + ' LIKE ' + @SearchStr2
					)
				END
            END
        END
END

UPDATE #ResultsIIC SET ColumnName = REPLACE(ColumnName,'[dbo].','')

DECLARE @TableIIC nvarchar(256),  @ColumnIIC nvarchar(128);  
DECLARE contact_cursor CURSOR FOR  
SELECT DISTINCT TableName,ColumnName FROM #ResultsIIC

SET @ColumnIIC = REPLACE(@ColumnIIC,'[dbo].','')

OPEN contact_cursor;  
FETCH NEXT FROM contact_cursor  
	INTO @TableIIC, @ColumnIIC;  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  

		INSERT INTO #IIC
		EXEC
		(
			'SELECT IIC FROM SIS_Item.' + @TableIIC + ' (NOLOCK) ' +
			' WHERE CAST('+ @ColumnIIC +' AS nVARCHAR(MAX)) IN (SELECT DISTINCT ColumnValue FROM #ResultsIIC)'
		)


	FETCH NEXT FROM contact_cursor  
	INTO @TableIIC, @ColumnIIC;  
	END  

CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY IIC ORDER BY IIC) AS rw
		  FROM #IIC
	)
DELETE FROM CTE1 WHERE rw <>1;


---------------------------------------------------------------------------------------------
-- =============================================
-- OIC
-- =============================================

CREATE TABLE #ResultsOIC (TableName nvarchar(256) ,ColumnName nvarchar(370), ColumnValue nvarchar(3630))
CREATE TABLE #tmptableOIC (VAL nVARCHAR(MAX))
CREATE TABLE #OIC (OIC bigint)

DECLARE @TableNameOIC nvarchar(256), @ColumnNameOIC nvarchar(128)
    SET @TableNameOIC = ''


WHILE @TableNameOIC IS NOT NULL
    BEGIN
        SET @ColumnNameOIC = ''
        SET @TableNameOIC = 
						(	SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
							  FROM SIS_Organization.INFORMATION_SCHEMA.TABLES
							 WHERE TABLE_TYPE = 'BASE TABLE'
							   AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableNameOIC
							   AND TABLE_NAME NOT IN ('sysdiagrams','Keyword_Search','Advanced_Search_Criteria','Photographs' )
							   --AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
						)

        WHILE (@TableNameOIC IS NOT NULL) AND (@ColumnNameOIC IS NOT NULL)
        BEGIN
            SET @ColumnNameOIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Organization.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNameOIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNameOIC, 1)
								   AND COLUMN_NAME <> 'ID'
								   AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNameOIC
							)

            IF @ColumnNameOIC IS NOT NULL
            BEGIN
				IF (@TableNameOIC NOT IN ('[dbo].[sysdiagrams]','[dbo].[Keyword_Search]','[dbo].[Advanced_Search_Criteria]','[dbo].[Photographs]' ))
				BEGIN
					INSERT INTO #ResultsOIC
					EXEC
					(
					    'SELECT ''' + @TableNameOIC +''',''' + @TableNameOIC + '.' + @ColumnNameOIC + ''', LEFT(' + @ColumnNameOIC + ', 3630) 
					       FROM SIS_Organization.' + @TableNameOIC + ' (NOLOCK) ' +
					    ' WHERE ' + @ColumnNameOIC + ' LIKE ' + @SearchStr2
					)
				END
            END
        END
END

UPDATE #ResultsOIC SET ColumnName = REPLACE(ColumnName,'[dbo].','')

DECLARE @TableOIC nvarchar(256),  @ColumnOIC nvarchar(128);  
DECLARE contact_cursor CURSOR FOR  
SELECT DISTINCT TableName,ColumnName FROM #ResultsOIC

SET @ColumnOIC = REPLACE(@ColumnOIC,'[dbo].','')

OPEN contact_cursor;  
FETCH NEXT FROM contact_cursor  
	INTO @TableOIC, @ColumnOIC;  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  

		INSERT INTO #OIC
		EXEC
		(
			'SELECT OIC FROM SIS_Organization.' + @TableOIC + ' (NOLOCK) ' +
			' WHERE CAST('+ @ColumnOIC +' AS nVARCHAR(MAX)) IN (SELECT DISTINCT ColumnValue FROM #ResultsOIC)'
		)


	FETCH NEXT FROM contact_cursor  
	INTO @TableOIC, @ColumnOIC;  
	END  

CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY OIC ORDER BY OIC) AS rw
		  FROM #OIC
	)
DELETE FROM CTE1 WHERE rw <>1;


---------------------------------------------------------------------------------------------
-- =============================================
-- AIC
-- =============================================

CREATE TABLE #ResultsAIC (TableName nvarchar(256) ,ColumnName nvarchar(370), ColumnValue nvarchar(3630))
CREATE TABLE #tmptableAIC (VAL nVARCHAR(MAX))
CREATE TABLE #AIC (AIC bigint)

DECLARE @TableNameAIC nvarchar(256), @ColumnNameAIC nvarchar(128)
    SET @TableNameAIC = ''


WHILE @TableNameAIC IS NOT NULL 
    BEGIN
        SET @ColumnNameAIC = ''
        SET @TableNameAIC = 
						(	SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
							  FROM SIS_Activity.INFORMATION_SCHEMA.TABLES
							 WHERE TABLE_TYPE = 'BASE TABLE'
							   AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableNameAIC
							   AND TABLE_NAME NOT IN ('sysdiagrams','Keyword_Search','Advanced_Search_Criteria','Photographs' )
							   --AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
						)

        WHILE (@TableNameAIC IS NOT NULL) AND (@ColumnNameAIC IS NOT NULL)
        BEGIN
            SET @ColumnNameAIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Activity.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNameAIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNameAIC, 1)
								   AND COLUMN_NAME <> 'ID'
								   AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNameAIC
							)

            IF @ColumnNameAIC IS NOT NULL
            BEGIN
				IF (@TableNameAIC NOT IN ('[dbo].[sysdiagrams]','[dbo].[Keyword_Search]','[dbo].[Advanced_Search_Criteria]','[dbo].[Photographs]' ))
				BEGIN
					INSERT INTO #ResultsAIC
					EXEC
					(
					    'SELECT ''' + @TableNameAIC +''',''' + @TableNameAIC + '.' + @ColumnNameAIC + ''', LEFT(' + @ColumnNameAIC + ', 3630) 
					       FROM SIS_Activity.' + @TableNameAIC + ' (NOLOCK) ' +
					    ' WHERE ' + @ColumnNameAIC + ' LIKE ' + @SearchStr2
					)
				END
            END
        END
END

UPDATE #ResultsAIC SET ColumnName = REPLACE(ColumnName,'[dbo].','')

DECLARE @TableAIC nvarchar(256),  @ColumnAIC nvarchar(128);  
DECLARE contact_cursor CURSOR FOR  
SELECT DISTINCT TableName,ColumnName FROM #ResultsAIC

SET @ColumnAIC = REPLACE(@ColumnAIC,'[dbo].','')

OPEN contact_cursor;  
FETCH NEXT FROM contact_cursor  
INTO @TableAIC, @ColumnAIC;  

WHILE @@FETCH_STATUS = 0  
BEGIN  

	INSERT INTO #AIC
	EXEC
	(
		'SELECT AIC FROM SIS_Activity.' + @TableAIC + ' (NOLOCK) ' +
		' WHERE CAST('+ @ColumnAIC +' AS nVARCHAR(MAX)) IN (SELECT DISTINCT ColumnValue FROM #ResultsAIC)'
	)


FETCH NEXT FROM contact_cursor  
INTO @TableAIC, @ColumnAIC;  
END  

CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY AIC ORDER BY AIC) AS rw
		  FROM #AIC
	)
DELETE FROM CTE1 WHERE rw <>1;


---------------------------------------------------------------------------------------------
-- =============================================
-- PIC
-- =============================================

CREATE TABLE #ResultsPIC (TableName nvarchar(256) ,ColumnName nvarchar(370), ColumnValue nvarchar(3630))
CREATE TABLE #tmptablePIC (VAL nVARCHAR(MAX))
CREATE TABLE #PIC (PIC bigint)

DECLARE @TableNamePIC nvarchar(256), @ColumnNamePIC nvarchar(128)
SET  @TableNamePIC = ''


    WHILE @TableNamePIC IS NOT NULL
    BEGIN
        SET @ColumnNamePIC = ''
        SET @TableNamePIC = 
						(	SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
							  FROM SIS_Person.INFORMATION_SCHEMA.TABLES
							 WHERE TABLE_TYPE = 'BASE TABLE'
							   AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableNamePIC
							   AND TABLE_NAME NOT IN ('sysdiagrams','Keyword_Search','Advanced_Search_Criteria','Photographs' )
							   --AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
						)

        WHILE (@TableNamePIC IS NOT NULL) AND (@ColumnNamePIC IS NOT NULL)
        BEGIN
            SET @ColumnNamePIC =
							(   SELECT MIN(QUOTENAME(COLUMN_NAME))
								  FROM SIS_Person.INFORMATION_SCHEMA.COLUMNS
								 WHERE TABLE_SCHEMA = PARSENAME(@TableNamePIC, 2)
								   AND TABLE_NAME = PARSENAME(@TableNamePIC, 1)
								   AND COLUMN_NAME <> 'ID'
								   AND DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
								   AND QUOTENAME(COLUMN_NAME) > @ColumnNamePIC
							)

            IF @ColumnNamePIC IS NOT NULL
            BEGIN
				IF (@TableNamePIC NOT IN ('[dbo].[sysdiagrams]','[dbo].[Keyword_Search]','[dbo].[Advanced_Search_Criteria]','[dbo].[Photographs]' ))
				BEGIN
					INSERT INTO #ResultsPIC
					EXEC
					(
					    'SELECT ''' + @TableNamePIC +''',''' + @TableNamePIC + '.' + @ColumnNamePIC + ''', LEFT(' + @ColumnNamePIC + ', 3630) 
					       FROM SIS_Person.' + @TableNamePIC + ' (NOLOCK) ' +
					    ' WHERE ' + @ColumnNamePIC + ' LIKE ' + @SearchStr2
					)
				END
            END
        END
    END

UPDATE #ResultsPIC SET ColumnName = REPLACE(ColumnName,'[dbo].','')

DECLARE @TablePIC nvarchar(256),  @ColumnPIC nvarchar(128);  
DECLARE contact_cursor CURSOR FOR  
SELECT DISTINCT TableName,ColumnName FROM #ResultsPIC

SET @ColumnPIC = REPLACE(@ColumnPIC,'[dbo].','')

OPEN contact_cursor;  
FETCH NEXT FROM contact_cursor  
INTO @TablePIC, @ColumnPIC;  

WHILE @@FETCH_STATUS = 0  
BEGIN  

	INSERT INTO #PIC
	EXEC
	(
		'SELECT PIC FROM SIS_Person.' + @TablePIC + ' (NOLOCK) ' +
		' WHERE CAST('+ @ColumnPIC +' AS nVARCHAR(MAX)) IN (SELECT DISTINCT ColumnValue FROM #ResultsPIC)'
	)


FETCH NEXT FROM contact_cursor  
INTO @TablePIC, @ColumnPIC;  
END  

CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  



;WITH CTE1 AS
	(
		SELECT *,ROW_NUMBER() OVER (PARTITION BY PIC ORDER BY PIC) AS rw
		  FROM #PIC
	)
DELETE FROM CTE1 WHERE rw <>1;



---------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM #IIC)
BEGIN

		INSERT #SearchTemp
		SELECT * 
		  FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID ,
					   'item' AS 'Type',
					   'colorIndicator--Items' AS 'Class',
					   CONCAT(ItemInformation.IIC,' - ',DescriptionOfItem) AS 'Title',
					   [Description] 'Value1',
					   MainIdentifyingNumber AS 'Value2',
					   NULL AS 'Value3',
					   NULL AS 'Value4',
					   NULL AS 'Value5',
					   CONVERT(NVARCHAR(MAX),EnteredDate,103) AS 'Value6',
					   EnteredDate,
					   (SELECT COUNT(*)
						  FROM SIS_Item.dbo.ItemInformation i with(nolock)
						INNER JOIN SIS_Item.dbo.SystemDetails sd with(nolock) 
						 	    ON sd.IIC = i.IIC
						INNER JOIN #IIC c ON c.IIC = i.IIC
					     WHERE sd.IsDeleted = 0
					   ) AS [COUNT] 
				  FROM(SELECT i.*,pd.[Description],sd.EnteredDate
						 FROM SIS_Item.dbo.ItemInformation i with(nolock)
					   INNER JOIN SIS_Item.dbo.SystemDetails sd with(nolock) 
							   ON sd.IIC = i.IIC
					   INNER JOIN #IIC c ON c.IIC = i.IIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
					   WHERE sd.IsDeleted = 0
					  )ItemInformation
			   )x
        WHERE x.ID BETWEEN @MIN AND @MAX  
END


IF EXISTS (SELECT * FROM #OIC)
BEGIN

		INSERT #SearchTemp
		SELECT *
		  FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID ,
		               'organization' AS 'Type',
					   'colorIndicator--Org' AS 'Class',
					   CONCAT(OrganizationInformation.OIC,' - ',OrganizationName) AS 'Title',
					   [Description] 'Value1',
					   Aliases.AliasName AS 'Value2',
					   RelatedOrganizationName AS 'Value3',
					   NULL AS 'Value4',
					   NULL AS 'Value5',
					   CONVERT(NVARCHAR(MAX),EnteredDate,103) AS 'Value6',
					   EnteredDate,
					   (SELECT COUNT(*)
						  FROM SIS_Organization.dbo.OrganizationInformation oi with(nolock)
						INNER JOIN SIS_Organization.dbo.SystemDetails sd with(nolock)
								ON sd.OIC = oi.OIC
						INNER JOIN #OIC o
								ON o.OIC = oi.OIC
					     WHERE sd.IsDeleted = 0
					   ) AS [COUNT]
				  FROM (SELECT oi.*,pd.[Description],EnteredDate
						  FROM SIS_Organization.dbo.OrganizationInformation oi with(nolock)
						INNER JOIN SIS_Organization.dbo.SystemDetails sd with(nolock)
								ON sd.OIC = oi.OIC
						INNER JOIN #OIC o
								ON o.OIC = oi.OIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
						WHERE sd.IsDeleted = 0
					   )OrganizationInformation
				LEFT OUTER JOIN (SELECT TOP 1 OIC,AliasName
								   FROM SIS_Organization.dbo.Aliases with(nolock)
								)Aliases
							 ON Aliases.OIC = OrganizationInformation.OIC
				LEFT OUTER JOIN (SELECT ro.*,oi.OrganizationName AS 'RelatedOrganizationName'
								   FROM SIS_Organization.dbo.RelatedOrganizations ro with(nolock)
								 INNER JOIN SIS_Organization.dbo.OrganizationInformation oi with(nolock)
										 ON oi.OIC = ro.[RelatedOrganizations(OIC)]
								)RelatedOrganizations
							 ON RelatedOrganizations.OIC = OrganizationInformation.OIC
				)y
        WHERE y.ID BETWEEN @MIN AND @MAX  

END


IF EXISTS (SELECT * FROM #AIC)
BEGIN

		INSERT #SearchTemp
		SELECT * 
		  FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID ,
		                'activity' AS Type,
						'colorIndicator--Incidents' AS 'Class',
						CONCAT(ActivityInformation.AIC,' - ',ActivityInformation.DescriptionOfTheActivity) AS 'Title',
						[Description] 'Value1',
						ActivityInformation.Place AS 'Value2',
						CAST(ActivityInformation.StartDateTime AS NVARCHAR) AS 'Value3',
						CAST(ActivityInformation.EndDateTime AS NVARCHAR) AS 'Value4',
						NULL AS 'Value5',
						CONVERT(NVARCHAR(MAX),EnteredDate,103) AS 'Value6',
						EnteredDate,
						(SELECT COUNT(*)
							FROM SIS_Activity.dbo.ActivityInformation ai with(nolock)
						INNER JOIN SIS_Activity.dbo.SystemDetails sd with(nolock)
								ON sd.AIC = ai.AIC
						INNER JOIN #AIC a 
								ON a.AIC = ai.AIC
					     WHERE sd.IsDeleted = 0
					   )AS [COUNT]
				  FROM (SELECT ai.*,pd.[Description],sd.EnteredDate
							FROM SIS_Activity.dbo.ActivityInformation ai with(nolock)
						INNER JOIN SIS_Activity.dbo.SystemDetails sd with(nolock)
								ON sd.AIC = ai.AIC
						INNER JOIN #AIC a 
								ON a.AIC = ai.AIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = DeskTarget
						WHERE sd.IsDeleted = 0
						 )ActivityInformation
			  )z
        WHERE z.ID BETWEEN @MIN AND @MAX  
END


IF EXISTS (SELECT * FROM #PIC)
BEGIN
		INSERT #SearchTemp
		SELECT * 
		  FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID ,
						'people' AS 'Type',
						'colorIndicator--People' AS 'Class',
						CONCAT(PersonInformation.PIC,' - ',LTRIM(RTRIM(CONCAT(ISNULL(FirstName,' '),' ',ISNULL(SecondName,' '),' ',ISNULL(Surname,' '))))) AS 'Title',
						[Description] 'Value1',
						Identification.IdNumber AS 'Value2',
						CAST(DateOfBirth AS NVARCHAR) AS 'Value3',
						Organizations.OrganizationName AS 'Value4',
						Organizations.Position AS 'Value5',
						CONVERT(NVARCHAR(MAX),PersonInformation.EnteredDate,103) AS 'Value6',
						EnteredDate,
						(SELECT COUNT(*)
						   FROM SIS_Person.[dbo].[PersonInformation] p with(nolock)
						 INNER JOIN #PIC pic ON pic.PIC = p.PIC
						 INNER JOIN SIS_Person.[dbo].SystemDetails sd with(nolock)
								 ON sd.PIC = p.PIC
					     WHERE sd.IsDeleted = 0
						)AS [COUNT]
				   FROM (SELECT p.*,pd.[Description],sd.EnteredDate
						   FROM SIS_Person.[dbo].[PersonInformation] p with(nolock)
						 INNER JOIN #PIC pic ON pic.PIC = p.PIC
						 INNER JOIN SIS_Person.[dbo].SystemDetails sd with(nolock)
								 ON sd.PIC = p.PIC
					   INNER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] pd with(nolock)
					           ON pd.ID = Desk
						 WHERE sd.IsDeleted = 0
						)PersonInformation
				LEFT OUTER JOIN (SELECT PIC,IdNumber
						                    FROM(SELECT PIC,IdNumber,ROW_NUMBER() OVER(PARTITION BY PIC ORDER BY IdNumber)rw
												   FROM SIS_Person.[dbo].Identification a with(nolock)
										          WHERE [Type] = 'NIC'
											        AND (Validity IS NULL OR Validity <> 'fake')
											    )x
									       WHERE x.rw = 1
								 )Identification
							  ON Identification.PIC = PersonInformation.PIC
				LEFT OUTER JOIN (SELECT PIC,a.Position,b.OrganizationName
									FROM SIS_Person.[dbo].[Organizations] a with(nolock)
								  INNER JOIN SIS_Organization.dbo.OrganizationInformation b with(nolock)
										  ON a.OIC = b.OIC
								   WHERE [Type] = 'Main'
								 )Organizations
							  ON Organizations.PIC = PersonInformation.PIC
			  )a
        WHERE a.ID BETWEEN @MIN AND @MAX  
END
---------------------------------------------------------------------------------------------




SELECT * 
  FROM(SELECT CAST(ROW_NUMBER() OVER(ORDER BY EnteredDate) AS INT)ID,
              [Type],Class,Title,Value1,Value2,
			  Value3,Value4,Value5,Value6,[COUNT]  
         FROM #SearchTemp
	  )w
 WHERE ID BETWEEN @MIN AND @MAX




END

GO
