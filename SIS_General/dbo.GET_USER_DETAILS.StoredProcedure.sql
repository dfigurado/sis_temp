USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_USER_DETAILS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_USER_DETAILS]
AS
BEGIN

	DECLARE @RESULT NVARCHAR(MAX)

	SET @RESULT = (
		SELECT U.ID,U.UserName,U.IsActive,U.IsActive as IsRegistryUser,
		ISNULL((SELECT RP.ProfileID,RP.ProfileType,RP.Title
				  FROM [dbo].[SystemUserRestrictedProfiles] RP
				 WHERE RP.UserID = U.ID FOR JSON AUTO),'[]') 'RestrictedProfiles',
		ISNULL((SELECT UserGroups.ID,UserGroups.[Name] 
		          FROM [dbo].[vw_EnadocUserGroupUser] UGU
		        INNER JOIN [dbo].[vw_EnadocUserGroup] UserGroups
		                ON UserGroups.ID = UGU.UserGroupID 
		         WHERE UGU.UserID = u.ID FOR JSON AUTO),'[]')'UserGroups'
		FROM [dbo].[vw_EnadocUser] U FOR JSON AUTO
	)

	SELECT @RESULT

END

	
GO
