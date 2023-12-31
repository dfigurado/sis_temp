USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_USER_DETAILS_BY_ID]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_USER_DETAILS_BY_ID](@USERID INT)
AS
BEGIN

	DECLARE @RESULT NVARCHAR(MAX)
	DECLARE @ISREG BIT = 'true'
	SET @RESULT = (
		SELECT U.ID,U.UserName,U.IsActive,@ISREG as IsRegistryUser,
		ISNULL((SELECT RP.ProfileID,RP.ProfileType,RP.Title
				FROM [dbo].[SystemUserRestrictedProfiles] RP
				WHERE RP.UserID = U.ID FOR JSON AUTO),'[]') 'RestrictedProfiles'
		,UserGroups.ID,UserGroups.[Name]
		FROM [dbo].[vw_EnadocUser] U
		INNER JOIN [dbo].[vw_EnadocUserGroupUser] UGU
		ON U.ID = UGU.UserID
		INNER JOIN [dbo].[vw_EnadocUserGroup] UserGroups
		ON UserGroups.ID = UGU.UserGroupID
		WHERE U.ID=@USERID
		FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
	)

	SELECT @RESULT

END

select * from [dbo].[vw_EnadocUserGroupUser]
GO
