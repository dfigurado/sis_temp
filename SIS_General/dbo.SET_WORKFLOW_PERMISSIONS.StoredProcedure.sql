USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[SET_WORKFLOW_PERMISSIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SET_WORKFLOW_PERMISSIONS] (@workFlowRequestID AS INT,@grantedUserID AS INT,@permissionStatus AS bit,@grantedReson AS nVARCHAR(MAX))
AS
BEGIN

	DECLARE @TR_SET_PERMISSIONS nVARCHAR(MAX)

BEGIN TRANSACTION @TR_SET_PERMISSIONS
	BEGIN TRY
	
	--UPDATE WORKFLOW REQUEST AND WorkFlowApproval STATUS
	UPDATE WorkFlowRequest
	   SET PermissionStatus = @permissionStatus,
		   GrantedUserID = @grantedUserID,
		   GrantedReson = @grantedReson
	 WHERE ID = @workFlowRequestID

	UPDATE WorkFlowApproval
	   SET IsDone = 1
	 WHERE WorkFlowRequestID = @workFlowRequestID


	--INSERT PERMISSIONS TO WorkFlowPermissions WHEN REQUEST APPROVED
	IF (@permissionStatus = 1)
	BEGIN
	
		DELETE FROM WorkFlowPermissions 
		 WHERE CAST(EndTime AS smalldatetime) < CAST(GETDATE() AS smalldatetime)
	

		INSERT INTO WorkFlowPermissions ([UserID],[ProfileType],[ProfileID],[ProfileDeskID],[View],[Print],[Download],[Email],[Add],[Edit],[Delete],[StartTime],[EndTime])
		SELECT wr.RequestedUserID AS 'UserID',
			   wr.ProfileType,wr.ProfileID,wr.ProfileDeskID,[View],[Print],[Download],[Email],[Add],[Edit],[Delete],
			   GETDATE() AS 'StartTime',
			   DATEADD(HH,wr.Time,GETDATE())'EndTime'
		  FROM WorkFlowRequest wr WITH(nolock)
		 WHERE ID = @workFlowRequestID

	END

COMMIT TRANSACTION @TR_SET_PERMISSIONS

	END TRY	
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION @TR_SET_PERMISSIONS 

			 SELECT CONCAT(ERROR_MESSAGE(),ERROR_SEVERITY(),ERROR_STATE())
		END CATCH
END

GO
