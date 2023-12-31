USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_MANAGEMENT_ACCESSBILITY]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_MANAGEMENT_ACCESSBILITY](@UserId BIGINT,@accessType nVARCHAR(MAX))
AS
BEGIN

	DECLARE @access AS nVARCHAR(MAX)
	IF(@accessType = 'ALL')
	BEGIN

		SET @access = (SELECT IIF(SUM(CAST(IsManagementAccess AS INT)) > 0,'TRUE','FALSE')'ManagementAccess',
							  IIF(SUM(CAST(IsReportAccess AS INT)) > 0,'TRUE','FALSE')'ReportAccess',
							  IIF(SUM(CAST(IsConfigAccess AS INT)) > 0,'TRUE','FALSE')'ConfigAccess',
							  IIF(SUM(CAST(IsCorrespondenceAccess AS INT)) > 0,'TRUE','FALSE')'CorrespondenceAccess'
						 FROM SIS_General.dbo.vw_EnadocUserGroupUser ug with(nolock)
					   INNER JOIN SIS_General.dbo.UserGroupPermissions up with(nolock)
							   ON up.UserGroupID = ug.UserGroupID 
						 WHERE UserID = @userid
					   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )

	END
	IF(@accessType = 'ReportAccess')
	BEGIN

		SET @access = (SELECT IIF(SUM(CAST(IsReportAccess AS INT))>= 1,'TRUE','FALSE') 'ReportAccess'   
						 FROM SIS_General.dbo.vw_EnadocUserGroupUser ug with(nolock)
					   INNER JOIN SIS_General.dbo.UserGroupPermissions up with(nolock)
				   				ON up.UserGroupID = ug.UserGroupID
						WHERE UserID = @userid
					   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
				   
	END
	IF(@accessType = 'ConfigAccess')
	BEGIN

		SET @access = (SELECT IIF(SUM(CAST(IsConfigAccess AS INT))>= 1,'TRUE','FALSE') 'ConfigAccess'   
						 FROM SIS_General.dbo.vw_EnadocUserGroupUser ug with(nolock)
					   INNER JOIN SIS_General.dbo.UserGroupPermissions up with(nolock)
				   			   ON up.UserGroupID = ug.UserGroupID
						WHERE UserID = @userid
					   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )

	END
	IF(@accessType = 'ManagementAccess')
	BEGIN

		SET @access = (	SELECT IIF(SUM(CAST(IsManagementAccess AS INT))>= 1,'TRUE','FALSE') 'ManagementAccess'   
						  FROM SIS_General.dbo.vw_EnadocUserGroupUser ug with(nolock)
						INNER JOIN SIS_General.dbo.UserGroupPermissions up with(nolock)
								ON up.UserGroupID = ug.UserGroupID
						 WHERE UserID = @userid
					   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )

	END

	IF(@accessType = 'CorrespondenceAccess')
	BEGIN

		SET @access = (	SELECT IIF(SUM(CAST(IsCorrespondenceAccess AS INT))>= 1,'TRUE','FALSE') 'CorrespondenceAccess'   
						  FROM SIS_General.dbo.vw_EnadocUserGroupUser ug with(nolock)
						INNER JOIN SIS_General.dbo.UserGroupPermissions up with(nolock)
								ON up.UserGroupID = ug.UserGroupID
						 WHERE UserID = @userid
					   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )

	END

	SELECT @access


END
GO
