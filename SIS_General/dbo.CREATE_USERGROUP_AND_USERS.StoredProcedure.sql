USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_USERGROUP_AND_USERS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[CREATE_USERGROUP_AND_USERS] (@JSON AS nVARCHAR(MAX))
AS 
BEGIN

	DECLARE @TRANS_USERGROUP_AND_USERS nVARCHAR(MAX);
	DECLARE @UserGroupID AS INT;
	DECLARE @Users AS nVARCHAR(MAX);

	SET XACT_ABORT ON
	--BEGIN TRANSACTION @TRANS_USERGROUP_AND_USERS

	--------------------------------------------
	--USER & USER GROUP DATA INSERTING TO Enadoc
	--------------------------------------------

	--GET THE DATA FROM JSON & INSERTING TO EnadocUserGroup
	INSERT INTO [vw_EnadocUserGroup] (OrganizationID, Name, Description, IsQCUserGroup, SecurityLevel, IsPublicUserGroup, ApplyPasswordPolicy, AccessLevel)
	SELECT * FROM OPENJSON(@JSON)
	WITH
	(
		OrganizationID INT '$.organizationID',
		Name VARCHAR(50) '$.name',
		Description VARCHAR(150) '$.description',
		IsQCUserGroup BIT '$.isQCUserGroup',
		SecurityLevel INT '$.securityLevel',
		IsPublicUserGroup BIT '$.isPublicUserGroup',
		ApplyPasswordPolicy BIT '$.applyPasswordPolicy',
		AccessLevel INT '$.accessLevel'
	)
	SET @UserGroupID = (SELECT TOP 1 ID FROM [vw_EnadocUserGroup] ORDER BY ID DESC)



	--DATA INSERTING TO UserGroupPortal
	SELECT ID,ROW_NUMBER() OVER(ORDER BY (SELECT ID))rw
	into #portal
	FROM [SIS_General].[dbo].[vw_EnadocPortal]

	DECLARE @i int = 1
	WHILE ((SELECT COUNT(*) FROM #portal)>0)
	BEGIN

		DECLARE @PortalID int = (SELECT ID FROM #portal WHERE rw = @i )
		INSERT INTO [dbo].[vw_EnadocUserGroupPortal] (PortalID,UserGroupID) VALUES (@PortalID,@UserGroupID)
	
		DELETE FROM #portal WHERE rw = @i
		SET @i = @i + 1

	END



	--GET THE DATA FROM JSON & INSERTING TO EnadocUser

	SELECT * INTO #JSON FROM OPENJSON(@JSON)
	SET @Users = (SELECT [VALUE] FROM #JSON WHERE [KEY] = 'users')    


	CREATE TABLE #user (userName nVARCHAR(MAX))
	DECLARE @j int =  0
	WHILE((SELECT MAX(CAST([key]AS int)) FROM OPENJSON(@Users)) >= @j)
	BEGIN

		DECLARE @UserJson nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@Users) WHERE [key] = @j)

		--get passed users for the table
		INSERT INTO #user
		SELECT UserName FROM OPENJSON(@UserJson)WITH(UserName varchar(50) '$.userName')
		
		-----

		IF (SELECT COUNT(*) 
		      FROM [vw_EnadocUser] en with(nolock) 
			INNER JOIN (SELECT UserName FROM OPENJSON(@UserJson) WITH(UserName varchar(50) '$.userName'))x
					ON x.UserName = en.UserName 
		   ) = 0
		BEGIN
		
			INSERT INTO [dbo].[vw_EnadocUser] (OrganizationID,VerificationCode,[Password],FirstName,LastName,UserName,TOC,Email,Designation,SecurityLevel,IsFirstLogin,IsBlocked,IsActive)
			SELECT 1 AS 'OrganizationID',
				   ' ' AS VerificationCode,
				   ' ' AS 'Password',
				   ' ' AS FirstName,
				   ' ' AS LastName,
				   UserName,
				   'Mr' AS 'TOC',
				   CONCAT(UserName,'@',domain,'.com') AS 'Email',
				   UserName AS 'Designation',
				   1 AS 'SecurityLevel',
				   1 AS 'IsFirstLogin',
				   0 AS 'IsBlocked',
				   1 AS 'IsActive'
			 FROM OPENJSON(@UserJson)
					  WITH(
						   UserName varchar(50) '$.userName',
						   --FirstName varchar(100) '$.firstName',
						   --LastName varchar(150) '$.lastName',
						   IsActive bit '$.isActive',
						   domain varchar(50) '$.domain'
						  )
            WHERE UserName NOT IN (SELECT UserName FROM [vw_EnadocUser] WITH(nolock))
		END
	SET @j = @j + 1
	END



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
	 SELECT @UserGroupID,ID FROM #EnadocUser
	 


	 --GET THE USERS FROM TEMP USER TABLE & INSERTING TO EmailNotificationSetting
	 INSERT INTO [dbo].[vw_EmailNotificationSetting]([UserID],[hasNotification],[NotificationType])
	 SELECT eu.ID AS 'UserID',1 AS 'hasNotification', NULL AS 'NotificationType'
	   FROM #EnadocUser eu
	 LEFT OUTER JOIN [vw_EmailNotificationSetting] en
	              ON en.UserID = eu.ID
	 WHERE en.UserID IS NULL 



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
	 --USER GROUP PERMISSIONS INSERTING TO MIS
	 -----------------------------------------

	 DECLARE @USERGROUPPERMISSIONS nVARCHAR(MAX) = (SELECT [value] FROM #JSON WHERE [key] = 'userGroupPermissions')
	 INSERT INTO [SIS_General].dbo.UserGroupPermissions ([UserGroupID],[View],[Print],[Download],[Email],[Add],[Edit],[Delete],[IsDeskOfficer],[IsRegistryGroup],[IsReportAccess],[IsConfigAccess],[IsManagementAccess],[IsCorrespondenceAccess])
	 SELECT @UserGroupID,* FROM OPENJSON(@USERGROUPPERMISSIONS)
								    WITH(
								    	[view] bit '$.view',
								    	[print] bit '$.print',
								    	[download] bit '$.download',
								    	[email] bit '$.email',
								    	[add] bit '$.add',
								    	[edit] bit '$.edit',
								    	[delete] bit '$.delete',
								    	[IsDeskOfficer] bit '$.isDeskOfficer',
								    	[IsRegistryGroup] bit '$.isRegistryGroup',
										[IsReportAccess] bit '$.isReportAccess',
										[IsConfigAccess] bit '$.isConfigAccess',
										[IsManagementAccess] bit '$.isManagementAccess',
										[IsCorrespondenceAccess] bit '$.isCorrespondenceAccess'
								    	)

	--COMMIT TRANSACTION @TRANS_USERGROUP_AND_USERS	  

	SELECT eu.ID,ROW_NUMBER() OVER(ORDER BY (SELECT 0))rw
	into #x
	FROM #EnadocUser eu
	left outer join [SIS_Person].[dbo].[Advanced_Search_Criteria] adsc
	on eu.ID = adsc.UserID
	where adsc.UserID IS NULL

	DECLARE @a AS int = 1
	declare @userid int
	WHILE((SELECT MAX(rw) FROM #x) >= @a)
	BEGIN
		
		set @userid = (select ID from #x where rw = @a)
		exec [dbo].[GENERATE_USER_PREFERENCES] @userid
		set @a = @a+1

	END

	EXEC UPDATE_DESK_USER_PERMISSION

	SELECT @UserGroupID
END



--SELECT * FROM [vw_EnadocUser]
GO
