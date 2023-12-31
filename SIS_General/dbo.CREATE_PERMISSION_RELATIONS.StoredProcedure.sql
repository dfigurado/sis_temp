USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_PERMISSION_RELATIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CREATE_PERMISSION_RELATIONS] (@JSON nVARCHAR(MAX))
AS
BEGIN

	SELECT * INTO #JSON FROM OPENJSON(@JSON)
	DECLARE @PermissionRelations TABLE (ID int) 
	DECLARE @PermissionRelationsID int

	--ADD Permissions to PermissionRelations table
	INSERT INTO PermissionRelations (UserGroupID,[Level],[View],[Add],[Edit],[Delete],[Print],[Email],[Download])
	OUTPUT inserted.ID INTO @PermissionRelations
	SELECT * FROM OPENJSON(@JSON)
					 WITH(
							UserGroupID int '$.userGroupID',
							[Level] nvarchar(max) '$.level',
							[View] bit '$.view',
							[Add] bit '$.add',
							[Edit] bit '$.edit',
							[Delete] bit '$.delete',
							[Print] bit '$.print',
							[Email] bit '$.email',
							[Download] bit '$.download'
						 )

	SET @PermissionRelationsID = (SELECT * FROM @PermissionRelations)

	--Get deskID passing by Level
	CREATE TABLE #levelID (ID int)
	DECLARE @levels nVARCHAR(MAX) = (SELECT [value] FROM #JSON WHERE [key] = 'levels')
	DECLARE @i int = 0
	WHILE((SELECT MAX([key]) FROM OPENJSON(@levels)) >= @i)
	BEGIN

		DECLARE @levelJson nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@levels) WHERE [key] = @i)
		INSERT INTO #levelID
		SELECT ID FROM OPENJSON(@levelJson)WITH(ID int '$.id')

	SET @i = @i + 1
	END

	--IRelationshipID & LevelID Insert to RelationShipLevels table
	INSERT INTO RelationShipLevels (RelationshipID,LevelID)
	SELECT @PermissionRelationsID AS 'RelationsID', ID AS 'LevelID' FROM #levelID


	--------------------------------------------------------------------------------


	----Get Users using UserGroup
	--SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',gu.UserGroupID,gu.UserID
	--into #UserGroupUsers
	--  FROM vw_EnadocUserGroupUser gu with(nolock)
	--INNER JOIN (SELECT [value] FROM #JSON j WHERE [key] = 'userGroupID')j ON gu.UserGroupID = j.[value]
	 

	----Get Desks using levels
	--CREATE TABLE #desk (rw int ,ID int)
	--IF((SELECT [value] FROM #JSON j WHERE [key] = 'level') = 'Division')
	--BEGIN

	--	insert into #desk
	--	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy with(nolock) WHERE DivisionID IN (SELECT ID FROM #levelID)

	--END
	--ELSE IF ((SELECT [value] FROM #JSON j WHERE [key] = 'level') = 'Sub Division')
	--BEGIN

	--	insert into #desk	
	--	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy with(nolock) WHERE SubDivisionID IN (SELECT ID FROM #levelID)

	--END
	--ELSE IF ((SELECT [value] FROM #JSON j WHERE [key] = 'level') = 'Desk')
	--BEGIN

	--	insert into #desk
	--	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',ID FROM #levelID

	--END
	--ELSE IF ((SELECT [value] FROM #JSON j WHERE [key] = 'level') = 'SIS')
	--BEGIN

	--	insert into #desk	
	--	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy with(nolock)

	--END

	----UserGroupPermissions & PermissionRelations Intersect
	--SELECT IIF(SUM(CAST([view] AS int))> 0,1,0)'View',       
	--	   IIF(SUM(CAST([Print] AS int))> 0,1,0)'Print',
	--	   IIF(SUM(CAST([Download] AS int))> 0,1,0)'Download',
	--	   IIF(SUM(CAST([Email] AS int))> 0,1,0)'Email',
	--	   IIF(SUM(CAST([Add] AS int))> 0,1,0)'Add',
	--	   IIF(SUM(CAST([Edit] AS int))> 0,1,0)'Edit',
	--	   IIF(SUM(CAST([Delete] AS int))> 0,1,0)'Delete'
	--into #temp
	--  FROM (
	--		SELECT [View],[Print],[Download],[Email],[Add],[Edit],[Delete] FROM UserGroupPermissions up with(nolock)
	--		INNER JOIN (SELECT [value] FROM #JSON j WHERE [key] = 'userGroupID')j ON up.UserGroupID = j.[value]

	--		UNION

	--		SELECT [View],[Print],[Download],[Email],[Add],[Edit],[Delete] FROM PermissionRelations 
	--		 WHERE ID = @PermissionRelationsID  
	--	  )a


	----Insert data to DeskUserPermissions
	--DECLARE @j int = 1
	--DECLARE @k int = 1
	--WHILE((SELECT MAX(rw) FROM #desk) >= @j)
	--BEGIN

	--	WHILE((SELECT MAX(rw) FROM #UserGroupUsers) >= @k)
	--	BEGIN
	
	--		DECLARE @deskVal int = (SELECT ID FROM #desk WHERE rw = @j)
	--		DECLARE @userVal int = (SELECT UserID FROM #UserGroupUsers WHERE rw = @k)
		
	--		INSERT INTO DeskUserPermissions (DeskID,UserID,PermissionsRelationID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete])
	--		SELECT @deskVal,@userVal,@PermissionRelationsID,t.* FROM #temp t

	--		SET @k = @k + 1
	--	END

	--	SET @j = @j + 1
	--	SET @k = 1
	--END


	--TRUNCATE TABLE DeskUserPermissionsSummary

	--INSERT INTO DeskUserPermissionsSummary(UserID,DeskID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete])
	--SELECT UserID,DeskID,
	--	   IIF(SUM(CAST([view] AS int))> 0,1,0)'View',       
	--	   IIF(SUM(CAST([Print] AS int))> 0,1,0)'Print',
	--	   IIF(SUM(CAST([Download] AS int))> 0,1,0)'Download',
	--	   IIF(SUM(CAST([Email] AS int))> 0,1,0)'Email',
	--	   IIF(SUM(CAST([Add] AS int))> 0,1,0)'Add',
	--	   IIF(SUM(CAST([Edit] AS int))> 0,1,0)'Edit',
	--	   IIF(SUM(CAST([Delete] AS int))> 0,1,0)'Delete'
	-- FROM DeskUserPermissions with(nolock)
	--GROUP BY UserID,DeskID

	--Update Desk User Permission
	EXEC UPDATE_DESK_USER_PERMISSION

END
GO
