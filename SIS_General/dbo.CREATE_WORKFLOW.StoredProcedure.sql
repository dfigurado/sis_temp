USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_WORKFLOW]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CREATE_WORKFLOW] (@RequestedUserID int,@RequestedUserDeskID int,@RequestedReson nvarchar(max),@Time int,@RequestType nvarchar(max),@View bit,@Print bit,@Download bit,@Email bit,@Add bit,
								         @Edit bit,@Delete bit,@ProfileType nvarchar(max),@ProfileID bigint,@ProfileDeskID int,@PermissionStatus nvarchar(max),@GrantedUserID int,@GrantedReson nvarchar(max)	)
AS
BEGIN

	DECLARE @TR_CREATE_WORKFLOW nVARCHAR(MAX);
	DECLARE @WFID BIGINT
	DECLARE @WORKFLOWID TABLE (ID BIGINT)

BEGIN TRANSACTION @TR_CREATE_WORKFLOW
	BEGIN TRY

		--GET DESK USING PROFILE TYPE & PROFILEID
		IF(@ProfileType = 'person')
			SELECT @profileDeskID  = Desk  FROM SIS_Person.dbo.SystemDetails WITH(nolock) WHERE PIC = @ProfileID

		ELSE IF (@ProfileType = 'organization')
			SELECT @profileDeskID  =  DeskTarget FROM SIS_Organization.dbo.SystemDetails WITH(nolock) WHERE OIC = @ProfileID

		ELSE IF (@ProfileType = 'activity')
			SELECT @profileDeskID  =  DeskTarget FROM SIS_Activity.dbo.SystemDetails WITH(nolock) WHERE AIC = @ProfileID

		ELSE IF (@ProfileType = 'item')
			SELECT @profileDeskID  =  DeskTarget FROM SIS_Item.dbo.SystemDetails WITH(nolock) WHERE IIC = @ProfileID


		--CREATE WorkFlowRequest
		INSERT INTO SIS_General.dbo.WorkFlowRequest 
		([RequestedUserID],[RequestedUserDeskID],[RequestedReson],[CreatedTime],[Time],[RequestType],
		 [View],[Print],[Download],[Email],[Add],[Edit],[Delete],
		 [ProfileType],[ProfileID],[ProfileDeskID],[PermissionStatus],[GrantedUserID],[GrantedReson],[ActionTakeOn])
		OUTPUT INSERTED.ID INTO @WORKFLOWID
		VALUES 
		(@RequestedUserID,@RequestedUserDeskID,@RequestedReson,GETDATE(),@Time,@RequestType,
		 @View,@Print,@Download,@Email,@Add,@Edit,@Delete,
		 @ProfileType,@ProfileID,@ProfileDeskID,@PermissionStatus,@GrantedUserID,@GrantedReson,GETDATE())

		SET @WFID = (SELECT ID FROM @WORKFLOWID)


		--PASS WORKFLOW ID TO DOUSERS FOR THE APPROVAL
		IF(@ProfileType = 'person')
		BEGIN

			INSERT INTO SIS_General.dbo.WorkFlowApproval (DoUserID,WorkFlowRequestID,IsDone)
			SELECT en.UserID,@WFID,0
			  FROM SIS_General.dbo.vw_EnadocUserGroupUser en WITH(nolock)
			INNER JOIN (SELECT IIF(COUNT(*) > 0 AND @RequestType = 'view',
							(	
								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								WHERE pr.Level = 'SIS'								
							),
							(	
								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'Desk' AND pr.ID IN (	SELECT rl.RelationshipID
																		FROM SIS_General.dbo.RelationshipLevels rl WITH(nolock)
																		WHERE rl.[LevelID] = (SELECT  Desk
																						  FROM SIS_Person.dbo.SystemDetails WITH(nolock)
																						 WHERE PIC = @ProfileID)
																	)
								AND up.IsDeskOfficer = 1

								UNION ALL

								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'SIS' AND up.IsDeskOfficer = 1

							)) AS 'UserGroupID'
						FROM (SELECT PIC FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
							WHERE PIC = @ProfileID AND DirectorOnly = 1)p
					)x
					 
					ON x.UserGroupID = en.UserGroupID
		END
		ELSE IF (@ProfileType = 'organization')
		BEGIN

			INSERT INTO SIS_General.dbo.WorkFlowApproval (DoUserID,WorkFlowRequestID,IsDone)
			SELECT en.UserID,@WFID,0
			  FROM SIS_General.dbo.vw_EnadocUserGroupUser en WITH(nolock)
			INNER JOIN (SELECT IIF(COUNT(*) > 0 AND @RequestType = 'view',
							(	
								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								WHERE pr.Level = 'SIS'								
							),
							(
								SELECT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'Desk' AND pr.ID IN (	SELECT rl.RelationshipID
																		FROM SIS_General.dbo.RelationshipLevels rl WITH(nolock)
																		WHERE rl.[LevelID] = (SELECT  DeskTarget
																						  FROM SIS_Organization.dbo.SystemDetails WITH(nolock)
																						 WHERE OIC = @ProfileID)
																	)
								AND up.IsDeskOfficer = 1

								UNION ALL

								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'SIS' AND up.IsDeskOfficer = 1

							)) AS 'UserGroupID'
						FROM (SELECT PIC FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
							WHERE PIC = @ProfileID AND DirectorOnly = 1)p
					   )x
					ON x.UserGroupID = en.UserGroupID

		END
		ELSE IF (@ProfileType = 'activity')
		BEGIN

			INSERT INTO SIS_General.dbo.WorkFlowApproval (DoUserID,WorkFlowRequestID,IsDone)
			SELECT en.UserID,@WFID,0
			  FROM SIS_General.dbo.vw_EnadocUserGroupUser en WITH(nolock)
			INNER JOIN (SELECT IIF(COUNT(*) > 0 AND @RequestType = 'view',
							(	
								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								WHERE pr.Level = 'SIS'								
							),
							(
								SELECT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'Desk' AND pr.ID IN (	SELECT rl.RelationshipID
																		FROM SIS_General.dbo.RelationshipLevels rl WITH(nolock)
																		WHERE rl.[LevelID]= (SELECT  DeskTarget
																						  FROM SIS_Activity.dbo.SystemDetails WITH(nolock)
																						 WHERE AIC = @ProfileID)
																	)
								AND up.IsDeskOfficer = 1

								UNION ALL

								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'SIS' AND up.IsDeskOfficer = 1

							)) AS 'UserGroupID'
						FROM (SELECT PIC FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
							WHERE PIC = @ProfileID AND DirectorOnly = 1)p
					   )x
					ON x.UserGroupID = en.UserGroupID

		END
		ELSE IF (@ProfileType = 'item')
		BEGIN

			INSERT INTO SIS_General.dbo.WorkFlowApproval (DoUserID,WorkFlowRequestID,IsDone)
			SELECT en.UserID,@WFID,0
			  FROM SIS_General.dbo.vw_EnadocUserGroupUser en WITH(nolock)
			INNER JOIN (SELECT IIF(COUNT(*) > 0 AND @RequestType = 'view',
							(	
								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								WHERE pr.Level = 'SIS'								
							),
							(
								SELECT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'Desk' AND pr.ID IN (	SELECT rl.RelationshipID
																		FROM SIS_General.dbo.RelationshipLevels rl WITH(nolock)
																		WHERE rl.[LevelID] = (SELECT  DeskTarget
																						  FROM SIS_Item.dbo.SystemDetails WITH(nolock)
																						 WHERE IIC = @ProfileID)
																	)
								AND up.IsDeskOfficer = 1

								UNION ALL

								SELECT DISTINCT pr.UserGroupID
								FROM SIS_General.dbo.PermissionRelations pr WITH(nolock)
								INNER JOIN SIS_General.dbo.UserGroupPermissions up WITH(nolock)
								ON up.UserGroupID = pr.UserGroupID
								WHERE pr.Level = 'SIS' AND up.IsDeskOfficer = 1

							)) AS 'UserGroupID'
						FROM (SELECT PIC FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
							WHERE PIC = @ProfileID AND DirectorOnly = 1)p
					   )x
					ON x.UserGroupID = en.UserGroupID

		END

SELECT @WFID AS 'WFID'

COMMIT TRANSACTION @TR_CREATE_WORKFLOW
	
	END TRY
		
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION @TR_CREATE_WORKFLOW 
	
		 SELECT CONCAT(ERROR_MESSAGE(),ERROR_SEVERITY(),ERROR_STATE())
	END CATCH

END
--exec CREATE_WORKFLOW 1,0,'fff',12,'view',1,1,0,0,0,0,0,'person',49,2,'Pending',0,''
GO
