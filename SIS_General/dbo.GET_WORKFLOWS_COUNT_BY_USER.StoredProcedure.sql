USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_WORKFLOWS_COUNT_BY_USER]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec GET_WORKFLOWS_BY_USER 1,1,2,4
CREATE PROCEDURE [dbo].[GET_WORKFLOWS_COUNT_BY_USER] (@UserID AS BIGINT)
AS
BEGIN
		SELECT COUNT(wr.ID)
				FROM SIS_General.dbo.WorkFlowRequest wr WITH(nolock)	
			INNER JOIN SIS_General.dbo.WorkFlowApproval wa WITH(nolock)
				ON wa.WorkFlowRequestID = wr.ID		
			WHERE wa.DoUserID = @UserID AND wr.PermissionStatus = 'Pending'
END

--EXEC GET_WORKFLOWS_COUNT_BY_USER 1
GO
