USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_USER_DESK_GROUPS]    Script Date: 8/7/2023 2:52:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sachithra Dilshan>
-- Create date: <2023-08-07>
-- Description:	<Get Logged in User's Desk groups>
-- =============================================
CREATE PROCEDURE [dbo].[GET_USER_DESK_GROUPS]
	@UserId BIGINT
AS
BEGIN
SELECT(SELECT ID, [Name] FROM [dbo].[vw_EnadocUserGroup]
WHERE ID IN (SELECT UserGroupID FROM [dbo].[vw_EnadocUserGroupUser] WHERE UserGroupID IN (SELECT UserGroupID FROM UserGroupPermissions WHERE IsDeskOfficer = 1)
  AND UserID = @UserId) FOR JSON AUTO) AS UserDeskGroups
END
