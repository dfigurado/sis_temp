USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_USERGROUP_AND_USERS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UPDATE_USERGROUP_AND_USERS] (@JSON nVARCHAR(MAX))
AS
BEGIN

	/*
		Before run this query please execute 'DELETE_ENADOC_USERGROUPUSER' passing user groupID
	*/
	DECLARE @USERS nVARCHAR(MAX) 
	DECLARE @TRANS_UPDATE_USERGROUP_AND_USERS nVARCHAR(MAX)
	DECLARE @USERGROUPID AS int = (SELECT ID FROM OPENJSON(@JSON)WITH (ID int '$.id'))
	SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	SET XACT_ABORT ON
	--BEGIN TRANSACTION @TRANS_UPDATE_USERGROUP_AND_USERS	

	---UPDATE USER GROUP ON Enadoc
	UPDATE en
	   SET en.[Name] = a.[Name],
		   en.[Description] = a.[Description]
	  FROM vw_EnadocUserGroup en
	INNER JOIN (SELECT * FROM OPENJSON(@JSON)
								  WITH (
										 ID int '$.id',
										 [Name] nvARCHAR(MAX) '$.name',
										 [Description] nvARCHAR(MAX) '$.description'
									   )
			   )a
			ON en.ID = a.ID
	-------



	---UPDATE USER GROUP USERS ON Enadoc
	SET @USERS = (SELECT [Value] FROM #PARSED WHERE [Key] = 'users')

	CREATE TABLE #user (ID int,UserName nvarchar(max))
	DECLARE @j int =  0
	WHILE((SELECT MAX(CAST([key]AS int)) FROM OPENJSON(@Users)) >= @j)
	BEGIN
	
		DECLARE @UserJson nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@Users) WHERE [key] = @j)
		INSERT INTO #user (ID,UserName)
		SELECT * FROM OPENJSON(@UserJson)WITH(ID int '$.id',UserName nvarchar(max) '$.userName')

		SET @j = @j + 1
	END


	INSERT INTO [dbo].[vw_EnadocUser] (OrganizationID,FirstName,LastName,UserName,TOC,Email,Designation,SecurityLevel,IsFirstLogin,IsBlocked,IsActive)
	SELECT 1 AS 'OrganizationID',
		   ' ' AS FirstName,
		   ' ' AS LastName,
		   UserName,
		   'Mr' AS 'TOC',
		   CONCAT(UserName,'@','.com') AS 'Email',
		   UserName AS 'Designation',
		   1 AS 'SecurityLevel',
		   1 AS 'IsFirstLogin',
		   0 AS 'IsBlocked',
		   1 AS 'IsActive'
	 FROM (SELECT userName FROM #user WHERE ID = 0)x
	WHERE UserName NOT IN (SELECT UserName FROM [vw_EnadocUser])


	 --PASS USER NAMES & GET USERID, INSERTING TO EnadocUserLoginType IF USERID NOT IN THERE
	 SELECT ID,eu.UserName
	 into #EnadocUser
	   FROM [vw_EnadocUser] eu
	 INNER JOIN (SELECT userName FROM #user)us
	 		ON us.userName = eu.UserName

	 INSERT INTO [dbo].[vw_EnadocUserLoginType] ([UserID],[LoginType])
	 SELECT ID AS 'UserID','enadoc' AS 'LoginType'
	   FROM [dbo].[vw_EnadocUserLoginType] lt
	 RIGHT OUTER JOIN #EnadocUser e
	              ON e.ID = lt.UserID
	  WHERE lt.UserID IS NULL


	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO vw_EnadocUserGroupUser
	 INSERT INTO vw_EnadocUserGroupUser (UserGroupID,UserID)
	 SELECT @USERGROUPID,ID FROM #EnadocUser


	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO EmailNotificationSetting
	 INSERT INTO [dbo].[vw_EmailNotificationSetting]([UserID],[hasNotification],[NotificationType])
	 SELECT eu.ID AS 'UserID',1 AS 'hasNotification', NULL AS 'NotificationType'
	   FROM #EnadocUser eu
	 LEFT OUTER JOIN [vw_EmailNotificationSetting] en
	              ON en.UserID = eu.ID
	 WHERE en.UserID IS NULL 



	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO UserSettings
     INSERT INTO dbo.vw_UserSettings(UserID, ThemeID, ViewerModeID, NoOfThumbnails,ImageQuality, DateFormatID, SessionTimeOut, NoOfRecordsToDisplay,DefaultPage,IsViewerModeRemember,Tags_SortOption,LanguageSelectionJsonFile,IsMyworkspaceDefault,IsFirstLoginVideo)
	 SELECT eu.ID,6,5,3,100,4,20,0,1,null,'0|RS','',0,0
	   FROM #EnadocUser eu
	 LEFT OUTER JOIN vw_UserSettings us
	 			 ON us.UserID = eu.ID
	  WHERE us.UserID IS NULL



	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO Portal_User
     INSERT INTO [vw_Portal_User]([UserID],[PortalID],[DefaultPortal])
	 SELECT ID,1,DefaultPortal
	   FROM #EnadocUser eu
     LEFT OUTER JOIN [dbo].[vw_Portal_User] pu
	               ON eu.ID = pu.UserID
	   WHERE pu.UserID IS NULL



	 -----------------------------------------
	 --USER DATA INSERTING TO Eip
	 -----------------------------------------

	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO EipUser
     INSERT INTO [vw_EipUser] ([ID],[OrganizationID],[UserName],[IsFirstLogin],[IsBlocked],[IsActive])
     SELECT eu.ID,1 AS 'OrganizationID',eu.UserName,1 AS 'IsFirstLogin',0 AS 'IsBlocked',1 AS 'IsActive'
	   FROM #EnadocUser eu
	 LEFT OUTER JOIN [vw_EipUser] u
	              ON u.ID = eu.ID
	  WHERE u.ID IS NULL 



	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO EipUserLoginType
	 INSERT INTO [vw_EipUserLoginType] ([OrganizationID],[UserID],[LoginType])
	 SELECT 1 AS 'OrganizationID',eu.ID AS 'UserID','enadoc' AS 'LoginType'
	   FROM #EnadocUser eu
	 LEFT OUTER JOIN [vw_EipUserLoginType] lt
	              ON lt.UserID = eu.ID
      WHERE lt.UserID IS NULL



	--UPDATE UserGroupPermissions ON MIS
	DECLARE @USERGROUPPERMISSIONS nVARCHAR(MAX)
	SET @USERGROUPPERMISSIONS = (SELECT [value] FROM #PARSED WHERE [Key] = 'userGroupPermissions')


	IF EXISTS (SELECT * FROM SIS_General.dbo.UserGroupPermissions WHERE UserGroupID = @USERGROUPID)
	BEGIN
		UPDATE up
		   SET up.[View] = x.[View],
			   up.[Print] = x.[Print],
			   up.Download = x.Download,
			   up.Email = x.[Email],
			   up.[Add] = x.[Add],
			   up.Edit = x.Edit,
			   up.[Delete] = x.[Delete],
			   up.IsDeskOfficer = x.IsDeskOfficer,
			   up.IsRegistryGroup = x.IsRegistryGroup,
			   up.[IsReportAccess] = x.[IsReportAccess],
			   up.[IsConfigAccess] = x.[IsConfigAccess],
			   up.[IsManagementAccess] = x.[IsManagementAccess],
			   up.[IsCorrespondenceAccess] = x.[IsCorrespondenceAccess]
		  FROM UserGroupPermissions up
		INNER JOIN (SELECT * FROM OPENJSON(@USERGROUPPERMISSIONS)
									  WITH(
										  [View] bit '$.view',
										  [Print] bit '$.print',
										  Download bit '$.download',
										  [Email] bit '$.email',
										  [Add] bit '$.add',
										  Edit bit '$.edit',
										  [Delete] bit '$.delete',
										  IsDeskOfficer bit '$.isDeskOfficer',
										  IsRegistryGroup bit '$.isRegistryGroup',
										  [IsReportAccess] bit '$.isReportAccess',
										  [IsConfigAccess] bit '$.isConfigAccess',
										  [IsManagementAccess] bit '$.isManagementAccess',
										  [IsCorrespondenceAccess] bit '$.isCorrespondenceAccess'
										  )
					 )x
				ON @USERGROUPID = up.UserGroupID
	END
	ELSE
	BEGIN
		INSERT INTO UserGroupPermissions (UserGroupID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete],[IsDeskOfficer],[IsRegistryGroup], [IsReportAccess], [IsConfigAccess], [IsManagementAccess],[IsCorrespondenceAccess])
		SELECT @USERGROUPID, * 
		  FROM OPENJSON(@USERGROUPPERMISSIONS)
  				   WITH(
						[View] bit '$.view',
						[Print] bit '$.print',
						Download bit '$.download',
						[Email] bit '$.email',
						[Add] bit '$.add',
						Edit bit '$.edit',
						[Delete] bit '$.delete',
						IsDeskOfficer bit '$.isDeskOfficer',
						IsRegistryGroup bit '$.isRegistryGroup',
						[IsReportAccess] bit '$.isReportAccess',
						[IsConfigAccess] bit '$.isConfigAccess',
						[IsManagementAccess] bit '$.isManagementAccess',
						[IsCorrespondenceAccess] bit '$.isCorrespondenceAccess'
					   )
	END

	SELECT eu.ID,ROW_NUMBER() OVER(ORDER BY (SELECT 0))rw
	into #x
	FROM #EnadocUser eu
	left outer join [SIS_Person].[dbo].[Advanced_Search_Criteria] adsc
	on eu.ID = adsc.UserID
	where adsc.UserID IS NULL

	--select * from #x
	--SELECT MAX(rw) as 'Max' FROM #x
	DECLARE @a AS int = 1
	declare @userid int
	WHILE((SELECT MAX(rw) FROM #x) >= @a)
	BEGIN
		
		set @userid = (select ID from #x where rw = @a)
		--select @userid as 'UserID'
		exec [dbo].[GENERATE_USER_PREFERENCES] @userid
		set @a = @a+1

	END


	--COMMIT TRANSACTION @TRANS_UPDATE_USERGROUP_AND_USERS	
	EXEC UPDATE_DESK_USER_PERMISSION

	SELECT @USERGROUPID 

END



GO
