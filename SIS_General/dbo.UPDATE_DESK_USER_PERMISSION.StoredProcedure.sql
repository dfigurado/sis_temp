USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_DESK_USER_PERMISSION]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_DESK_USER_PERMISSION]
AS
BEGIN
	TRUNCATE TABLE [dbo].[DeskUserPermissions]
	DECLARE @i int = 1
		
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw', pr.* 
	into #PermissionRelation
	FROM dbo.PermissionRelations pr 

	WHILE((SELECT ISNULL(MAX(rw),0) FROM #PermissionRelation) >= @i)
	BEGIN 

		-- set permission relation variables
		DECLARE @PRID nvarchar(max)	
		DECLARE @PRUserGroupID nvarchar(max)	
		DECLARE @PRLevel nvarchar(max)	

		SELECT @PRID=ID, @PRUserGroupID=UserGroupID, @PRLevel=[Level] FROM #PermissionRelation WHERE rw = @i  

	   --Get UserGroups
		SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',gu.UserGroupID,gu.UserID
		into #UserGroupUsers
		  FROM vw_EnadocUserGroupUser gu
		WHERE gu.UserGroupID = (SELECT UserGroupID FROM #PermissionRelation WHERE rw = @i) 

		--Get Desks using permission levels
		CREATE TABLE #desk (rw int ,ID int)		

		IF (@PRLevel = 'SIS')
		BEGIN

			insert into #desk	
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',ID FROM Predefined_DeskTarget 

		END
		ELSE IF(@PRLevel = 'Division')
		BEGIN

			insert into #desk
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy  WHERE DivisionID IN (SELECT LevelID FROM [dbo].[RelationshipLevels]  WHERE RelationshipID = @PRID )

		END
		ELSE IF (@PRLevel = 'Sub Division')
		BEGIN

			insert into #desk	
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy  WHERE SubDivisionID IN (SELECT LevelID FROM [dbo].[RelationshipLevels]  WHERE RelationshipID = @PRID)

		END
		ELSE IF (@PRLevel = 'Desk')
		BEGIN

			insert into #desk
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw', LevelID FROM [dbo].[RelationshipLevels]  WHERE RelationshipID = @PRID

		END

		--UserGroupPermissions & PermissionRelations Intersect
		SELECT IIF(SUM(CAST([View] AS int))> 1,1,0)'View',       
			   IIF(SUM(CAST([Print] AS int))> 1,1,0)'Print',
			   IIF(SUM(CAST([Download] AS int))> 1,1,0)'Download',
			   IIF(SUM(CAST([Email] AS int))> 1,1,0)'Email',
			   IIF(SUM(CAST([Add] AS int))> 1,1,0)'Add',
			   IIF(SUM(CAST([Edit] AS int))> 1,1,0)'Edit',
			   IIF(SUM(CAST([Delete] AS int))> 1,1,0)'Delete'
		into #temp
		  FROM (
				SELECT [View],[Print],[Download],[Email],[Add],[Edit],[Delete] FROM UserGroupPermissions up 
				WHERE up.UserGroupID = @PRUserGroupID

				UNION ALL

				SELECT [View],[Print],[Download],[Email],[Add],[Edit],[Delete] FROM PermissionRelations 
				 WHERE ID = @PRID  
			  )a			

		DECLARE @j int = 1
		DECLARE @k int = 1
		WHILE((SELECT MAX(rw) FROM #desk) >= @j)
		BEGIN

			WHILE((SELECT MAX(rw) FROM #UserGroupUsers) >= @k)
			BEGIN
	
				DECLARE @deskVal int = (SELECT ID FROM #desk WHERE rw = @j)
				DECLARE @userVal int = (SELECT UserID FROM #UserGroupUsers WHERE rw = @k)
		
				INSERT INTO DeskUserPermissions (DeskID,UserID,PermissionsRelationID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete])
				SELECT @deskVal,@userVal,@PRID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete] FROM #temp t

				SET @k = @k + 1
			END

			SET @j = @j + 1
			SET @k = 1
		END
		drop table #temp
		drop table #desk
		drop table #UserGroupUsers
		SET @i = @i + 1
	END

	drop table #PermissionRelation

	TRUNCATE TABLE DeskUserPermissionsSummary

	INSERT INTO DeskUserPermissionsSummary(UserID,DeskID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete])
	SELECT UserID,DeskID,
		   IIF(SUM(CAST([View] AS int))> 0,1,0)'View',       
		   IIF(SUM(CAST([Print] AS int))> 0,1,0)'Print',
		   IIF(SUM(CAST([Download] AS int))> 0,1,0)'Download',
		   IIF(SUM(CAST([Email] AS int))> 0,1,0)'Email',
		   IIF(SUM(CAST([Add] AS int))> 0,1,0)'Add',
		   IIF(SUM(CAST([Edit] AS int))> 0,1,0)'Edit',
		   IIF(SUM(CAST([Delete] AS int))> 0,1,0)'Delete'
	 FROM DeskUserPermissions 
		GROUP BY UserID,DeskID
END

GO
