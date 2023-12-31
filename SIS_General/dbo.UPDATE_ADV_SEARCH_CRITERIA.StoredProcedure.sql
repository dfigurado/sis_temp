USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_ADV_SEARCH_CRITERIA]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_ADV_SEARCH_CRITERIA](@PEOPLE NVARCHAR(MAX),@ITEM NVARCHAR(MAX),@ACTIVITY NVARCHAR(MAX),@ORGANIZATION NVARCHAR(MAX))
AS
BEGIN

	DECLARE @TR NVARCHAR(MAX)
	BEGIN TRANSACTION @TR

	-- PEOPLE
	--UPDATE [SIS_Person].[dbo].[Advanced_Search_Criteria]
	--SET IsSelected = 0
	UPDATE x
	set x.Caption = y.Caption,
		x.ControllType = y.ControllType,
		x.PreDefinedValues_Table = y.PreDefinedValues_Table,
		x.Priority = y.Priority,
		x.DBTable = y.DBTable,
		x.DBColumnName = y.DBColumnName,
		x.AutoCompleteEntity = y.AutoCompleteEntity,
		x.IsSelected = y.IsSelected
	from [SIS_Person].[dbo].[Advanced_Search_Criteria] x
	inner join (
		SELECT * FROM OPENJSON(@PEOPLE)
		WITH(
			ID INT '$.id',
			UserID INT '$.userID',
			Caption NVARCHAR(max) '$.caption',
			ControllType NVARCHAR(MAX) '$.controllType',
			PreDefinedValues_Table NVARCHAR(MAX) '$.preDefinedValues_Table',
			Priority INT '$.priority',
			DBTable NVARCHAR(MAX) '$.dbTable',
			DBColumnName NVARCHAR(MAX) '$.dbColumnName',
			AutoCompleteEntity NVARCHAR(MAX) '$.autoCompleteEntity',
			IsSelected bit '$.isSelected'
		)
	) y
	on x.ID = y.ID

	UPDATE x
	   SET x.IsSelected = 0 
	  FROM [SIS_Person].[dbo].[Advanced_Search_Criteria] x
	LEFT OUTER JOIN (SELECT * FROM OPENJSON(@PEOPLE)
					   WITH(
							ID INT '$.id',
							UserID INT '$.userID',
							Caption NVARCHAR(max) '$.caption',
							DBTable NVARCHAR(MAX) '$.dbTable',
							DBColumnName NVARCHAR(MAX) '$.dbColumnName'
						   )
				    )y
		 		 ON x.UserID = y.UserID
				AND x.Caption = y.Caption
				AND x.DBTable = y.DBTable
				AND x.DBColumnName = y.DBColumnName
	  WHERE x.UserID = (SELECT DISTINCT UserID FROM OPENJSON(@PEOPLE)
						  WITH (UserID INT '$.userID'))
		AND y.UserID IS NULL




	-- ORGANIZATION
	--UPDATE [SIS_Organization].[dbo].[Advanced_Search_Criteria]
	--SET IsSelected = 0
	UPDATE x
	set x.Caption = y.Caption,
		x.ControllType = y.ControllType,
		x.PreDefinedValues_Table = y.PreDefinedValues_Table,
		x.Priority = y.Priority,
		x.DBTable = y.DBTable,
		x.DBColumnName = y.DBColumnName,
		x.AutoCompleteEntity = y.AutoCompleteEntity,
		x.IsSelected = y.IsSelected
	from [SIS_Organization].[dbo].[Advanced_Search_Criteria] x
	inner join (
		SELECT * FROM OPENJSON(@ORGANIZATION)
		WITH(
			ID INT '$.id',
			UserID INT '$.userID',
			Caption NVARCHAR(max) '$.caption',
			ControllType NVARCHAR(MAX) '$.controllType',
			PreDefinedValues_Table NVARCHAR(MAX) '$.preDefinedValues_Table',
			Priority INT '$.priority',
			DBTable NVARCHAR(MAX) '$.dbTable',
			DBColumnName NVARCHAR(MAX) '$.dbColumnName',
			AutoCompleteEntity NVARCHAR(MAX) '$.autoCompleteEntity',
			IsSelected bit '$.isSelected'
		)
	) y
	on x.ID = y.ID


	UPDATE x
	   SET x.IsSelected = 0 
	  FROM [SIS_Organization].[dbo].[Advanced_Search_Criteria] x
	LEFT OUTER JOIN (SELECT * FROM OPENJSON(@ORGANIZATION)
					   WITH(
							ID INT '$.id',
							UserID INT '$.userID',
							Caption NVARCHAR(max) '$.caption',
							DBTable NVARCHAR(MAX) '$.dbTable',
							DBColumnName NVARCHAR(MAX) '$.dbColumnName'
						   )
				    )y
		 		 ON x.UserID = y.UserID
				AND x.Caption = y.Caption
				AND x.DBTable = y.DBTable
				AND x.DBColumnName = y.DBColumnName
	  WHERE x.UserID = (SELECT DISTINCT UserID FROM OPENJSON(@ORGANIZATION)
						  WITH (UserID INT '$.userID'))
		AND y.UserID IS NULL



	-- ITEM
	--UPDATE [SIS_Item].[dbo].[Advanced_Search_Criteria]
	--SET IsSelected = 0
	UPDATE x
	set x.Caption = y.Caption,
		x.ControllType = y.ControllType,
		x.PreDefinedValues_Table = y.PreDefinedValues_Table,
		x.Priority = y.Priority,
		x.DBTable = y.DBTable,
		x.DBColumnName = y.DBColumnName,
		x.AutoCompleteEntity = y.AutoCompleteEntity,
		x.IsSelected = y.IsSelected
	from [SIS_Item].[dbo].[Advanced_Search_Criteria] x
	inner join (
		SELECT * FROM OPENJSON(@ITEM)
		WITH(
			ID INT '$.id',
			UserID INT '$.userID',
			Caption NVARCHAR(max) '$.caption',
			ControllType NVARCHAR(MAX) '$.controllType',
			PreDefinedValues_Table NVARCHAR(MAX) '$.preDefinedValues_Table',
			Priority INT '$.priority',
			DBTable NVARCHAR(MAX) '$.dbTable',
			DBColumnName NVARCHAR(MAX) '$.dbColumnName',
			AutoCompleteEntity NVARCHAR(MAX) '$.autoCompleteEntity',
			IsSelected bit '$.isSelected'
		)
	) y
	on x.ID = y.ID


	UPDATE x
	   SET x.IsSelected = 0 
	  FROM [SIS_Item].[dbo].[Advanced_Search_Criteria] x
	LEFT OUTER JOIN (SELECT * FROM OPENJSON(@ITEM)
					   WITH(
							ID INT '$.id',
							UserID INT '$.userID',
							Caption NVARCHAR(max) '$.caption',
							DBTable NVARCHAR(MAX) '$.dbTable',
							DBColumnName NVARCHAR(MAX) '$.dbColumnName'
						   )
				    )y
		 		 ON x.UserID = y.UserID
				AND x.Caption = y.Caption
				AND x.DBTable = y.DBTable
				AND x.DBColumnName = y.DBColumnName
	  WHERE x.UserID = (SELECT DISTINCT UserID FROM OPENJSON(@ITEM)
						  WITH (UserID INT '$.userID'))
		AND y.UserID IS NULL



	-- ACTIVITY
	--UPDATE [SIS_Activity].[dbo].[Advanced_Search_Criteria]
	--SET IsSelected = 0
	UPDATE x
	set x.Caption = y.Caption,
		x.ControllType = y.ControllType,
		x.PreDefinedValues_Table = y.PreDefinedValues_Table,
		x.Priority = y.Priority,
		x.DBTable = y.DBTable,
		x.DBColumnName = y.DBColumnName,
		x.AutoCompleteEntity = y.AutoCompleteEntity,
		x.IsSelected = y.IsSelected
	from [SIS_Activity].[dbo].[Advanced_Search_Criteria] x
	inner join (
		SELECT * FROM OPENJSON(@ACTIVITY)
		WITH(
			ID INT '$.id',
			UserID INT '$.userID',
			Caption NVARCHAR(max) '$.caption',
			ControllType NVARCHAR(MAX) '$.controllType',
			PreDefinedValues_Table NVARCHAR(MAX) '$.preDefinedValues_Table',
			Priority INT '$.priority',
			DBTable NVARCHAR(MAX) '$.dbTable',
			DBColumnName NVARCHAR(MAX) '$.dbColumnName',
			AutoCompleteEntity NVARCHAR(MAX) '$.autoCompleteEntity',
			IsSelected bit '$.isSelected'
		)
	) y
	on x.ID = y.ID


	UPDATE x
	   SET x.IsSelected = 0 
	  FROM [SIS_Activity].[dbo].[Advanced_Search_Criteria] x
	LEFT OUTER JOIN (SELECT * FROM OPENJSON(@ACTIVITY)
					   WITH(
							ID INT '$.id',
							UserID INT '$.userID',
							Caption NVARCHAR(max) '$.caption',
							DBTable NVARCHAR(MAX) '$.dbTable',
							DBColumnName NVARCHAR(MAX) '$.dbColumnName'
						   )
				    )y
		 		 ON x.UserID = y.UserID
				AND x.Caption = y.Caption
				AND x.DBTable = y.DBTable
				AND x.DBColumnName = y.DBColumnName
	  WHERE x.UserID = (SELECT DISTINCT UserID FROM OPENJSON(@ACTIVITY)
						  WITH (UserID INT '$.userID'))
		AND y.UserID IS NULL


	COMMIT TRANSACTION @TR

END
GO
