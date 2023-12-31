USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_WORKFLOW_REQUEST]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UPDATE_WORKFLOW_REQUEST] (@WorkflowID AS BIGINT,@Time int,@View bit,@Print bit,@Download bit,@Email bit,@Add bit,
												@Edit bit,@Delete bit,@PermissionStatus nvarchar(max),@GrantedUserID int,@GrantedReson nvarchar(max))
AS
BEGIN

BEGIN TRANSACTION UPDATE_WORKFLOW_REQUEST

	--Approve or Reject Status Update
	UPDATE SIS_General.dbo.WorkFlowRequest
	SET [Time] = @Time,
		[View] = @View,
		[Print] = @Print,
		[Download] = @Download,
		[Email] = @Email,
		[Add] = @Add,
		[Edit] = @Edit,
		[Delete] = @Delete,
		[PermissionStatus] = @PermissionStatus,
		[GrantedUserID] = @GrantedUserID,
		[GrantedReson] = @GrantedReson,
		[ActionTakeOn] = GETDATE()
	WHERE [ID] = @WorkflowID

	--update workflow approval
	UPDATE SIS_General.dbo.WorkFlowApproval
	SET [IsDone] = 1		
	WHERE [WorkFlowRequestID] = @WorkflowID

	--Delete expired WorkFlow Permissions
	DELETE FROM WorkFlowPermissions WHERE EndTime < GETDATE() 

	IF(@PermissionStatus = 'Approved')
	BEGIN
		--Add New WorkFlow Permissions
		INSERT INTO WorkFlowPermissions (WorkFlowRequestID,UserID,ProfileType,ProfileID,ProfileDeskID,[View],[Print],Download,Email,[Add],Edit,[Delete],StartTime,EndTime)
		SELECT ID AS 'WorkFlowRequestID',
			   RequestedUserID AS 'UserID',
			   ProfileType,
			   ProfileID,
			   ProfileDeskID,
			   [View],
			   [Print],
			   Download,
			   Email,
			   [Add],
			   Edit,
			   [Delete],
			   ActionTakeOn AS 'StartTime',
			   DATEADD(HH,[Time],ActionTakeOn) AS 'EndTime'
		  FROM WorkFlowRequest WITH(nolock)
		 WHERE ID = @WorkflowID
	 END

COMMIT TRANSACTION UPDATE_WORKFLOW_REQUEST

END

--exec GET_WORKFLOWS_BY_USER 1,1,1,1
GO
