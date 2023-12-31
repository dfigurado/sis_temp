USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_USER]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_USER](@USER NVARCHAR(MAX))
AS
BEGIN

	DECLARE @USERID BIGINT
	DECLARE @ISACTIVE BIT
	DECLARE @USERGROUPS NVARCHAR(MAX)
	DECLARE @RESTRICTEDPROFILES NVARCHAR(MAX)
	DECLARE @TR NVARCHAR(MAX)

	SET XACT_ABORT ON
	BEGIN TRANSACTION @TR

	SELECT * INTO #PARSED FROM OPENJSON(@USER)
	SET @USERID = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'id')
	SET @ISACTIVE = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'isActive')

	UPDATE [dbo].[vw_EnadocUser]
	SET IsActive = @ISACTIVE
	WHERE ID = @USERID

	DELETE FROM [dbo].[vw_EnadocUserGroupUser]
	WHERE UserID = @USERID

	SET @USERGROUPS = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'userGroups')
	INSERT INTO [dbo].[vw_EnadocUserGroupUser](UserID,UserGroupID)
	SELECT @USERID,* FROM OPENJSON(@USERGROUPS)
	WITH(
		UserGroupID BIGINT '$.id'
	)

	DELETE FROM [dbo].[SystemUserRestrictedProfiles]
	WHERE UserID = @USERID

	SET @RESTRICTEDPROFILES = (SELECT [VALUE] FROM #PARSED WHERE [KEY] = 'restrictedProfiles')
	INSERT INTO [dbo].[SystemUserRestrictedProfiles]([UserID], [ProfileType], [ProfileID],Title)
	SELECT @USERID,* FROM OPENJSON(@RESTRICTEDPROFILES)
	WITH(
		ProfileType NVARCHAR(MAX) '$.profileType',
		ProfileID BIGINT '$.profileID',
		Title NVARCHAR(MAX) '$.title'
	)

	--select 1

	COMMIT TRANSACTION @TR

		EXEC UPDATE_DESK_USER_PERMISSION
END


GO
