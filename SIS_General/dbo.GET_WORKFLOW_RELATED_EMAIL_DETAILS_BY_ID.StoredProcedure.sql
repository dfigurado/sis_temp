USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_WORKFLOW_RELATED_EMAIL_DETAILS_BY_ID]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GET_WORKFLOW_RELATED_EMAIL_DETAILS_BY_ID] (@RequestID INT)
AS 
BEGIN
DECLARE @JSON NVARCHAR(MAX)=(
SELECT	wrq.ProfileID AS profileId,	
		wrq.ProfileType AS profileType,	
		wrq.RequestType AS requestType,		
		CAST(wrq.[Time]as NVARCHAR(MAX)) + ' Hours' AS duration,
		wrq.RequestedReson AS comment,
		(SELECT u.ID AS id, 
				u.FirstName+' '+u.LastName AS [name], 
				u.Email AS email 
			FROM [dbo].[vw_EnadocUser] u 
			WHERE u.ID = wrq.RequestedUserID FOR JSON PATH) AS requestor,  
		(SELECT wap.DoUserID AS id, 
				u.FirstName+' '+u.LastName AS [name], 
				u.Email AS email 
			FROM [dbo].[WorkFlowApproval] wap
			INNER JOIN [dbo].[vw_EnadocUser] u
			ON wap.DoUserID = u.ID 
			WHERE wap.WorkFlowRequestID = @requestid FOR JSON PATH) as approvers		 
	FROM [SIS_General].[dbo].[WorkFlowRequest] wrq	
	WHERE wrq.ID = @requestid FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	SELECT @JSON
END
GO
