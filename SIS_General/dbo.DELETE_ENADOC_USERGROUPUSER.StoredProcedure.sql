USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_ENADOC_USERGROUPUSER]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_ENADOC_USERGROUPUSER] (@USERGROUPID int)
AS
BEGIN
	/*
	This is not a single procedure,
	This proc run before the UPDATE_USERGROUP_AND_USERS
	*/
	SET XACT_ABORT ON

	IF NOT EXISTS (SELECT * FROM DBO.vw_EnadocUserGroup WHERE ID = @USERGROUPID AND [NAME]='Administrators')
	BEGIN

		DELETE FROM vw_EnadocUserGroupUser WHERE UserGroupID = @USERGROUPID

		EXEC UPDATE_DESK_USER_PERMISSION
	END

END
GO
