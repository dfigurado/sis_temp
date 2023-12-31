USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_USERGROUPS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_USERGROUPS]
AS
BEGIN

	DECLARE @RESULT NVARCHAR(MAX) =  (SELECT UG.ID,UG.[Name],UG.[Description],
	ISNULL((SELECT U.UserName FROM [dbo].[vw_EnadocUserGroupUser] UGU with(nolock) INNER JOIN [dbo].[vw_EnadocUser] U with(nolock) ON UGU.UserID = U.ID WHERE UGU.UserGroupID = UG.ID FOR JSON AUTO),'[]') 'Users',
	ISNULL(JSON_QUERY((SELECT UP.[View],UP.[Add],UP.Edit,UP.[Delete],UP.[Print],UP.Email,UP.Download,UP.IsDeskOfficer,UP.IsRegistryGroup, UP.IsReportAccess, UP.IsConfigAccess, UP.IsManagementAccess, UP.IsCorrespondenceAccess  FROM [dbo].[UserGroupPermissions] UP with(nolock) WHERE UP.UserGroupID = UG.ID FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER)),'{}') 'UserGroupPermissions'
	FROM [dbo].[vw_EnadocUserGroup] UG with(nolock)
	FOR JSON AUTO)

	SELECT @RESULT

END

GO
