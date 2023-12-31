USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_WORKFLOWS_BY_USER]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec GET_WORKFLOWS_BY_USER 1,1,1,1
CREATE PROCEDURE [dbo].[GET_WORKFLOWS_BY_USER] (@UserID AS BIGINT, @Category AS INT, @FilterType AS INT, @RequestType AS INT)
AS
BEGIN

	declare @Filter nvarchar(100)
	declare @Request nvarchar (100)

	IF(@FilterType = '1')	
		SET @Filter = ' ORDER BY CreatedTime  ASC'	
	ELSE	
		SET @Filter = ' ORDER BY CreatedTime  DESC'	

	IF(@RequestType = '1')
		SET @Request = ''	
	ELSE IF(@RequestType = '2')	
		SET @Request = ' AND wr.PermissionStatus = ''Approved'''
	ELSE IF(@RequestType = '3')	
		SET @Request = ' AND wr.PermissionStatus = ''Rejected'''
	ELSE IF(@RequestType = '4')	
		SET @Request = ' AND wr.PermissionStatus = ''Pending''' 

	IF(@Category = '1')
	BEGIN
		EXECUTE	('SELECT x.[ID] ,x.[RequestedUserID],x.[RequestedUserName],x.[RequestedUserDeskID],x.[RequestedReson],x.[CreatedTime],x.[Time]
					,x.[RequestType],x.[View],x.[Print],x.[Download],x.[Email],x.[Add],x.[Edit],x.[Delete],x.[ProfileType],x.[ProfileID],x.[ProfileDeskID]
					,CASE WHEN x.RequestedUserID = '+@UserID+' AND x.[PermissionStatus] = ''Pending''  THEN ''O_R'' ELSE x.[PermissionStatus] END AS ''PermissionStatus''
					,x.[GrantedUserID],x.[GrantedReson],x.[ActionTakeOn],	CONCAT(gu.FirstName, '' '' ,gu.LastName) ''GrantedUserName''
				FROM	(SELECT wr.*, CONCAT(eu.FirstName, '' '' ,eu.LastName) ''RequestedUserName''
						FROM SIS_General.dbo.vw_WorkFlowRequest wr
					INNER JOIN SIS_General.dbo.vw_EnadocUser eu WITH(nolock)
							ON wr.RequestedUserID = eu.ID
						WHERE wr.RequestedUserID = ' + @UserID + @Request + '

					UNION ALL

					SELECT wr.*, CONCAT(eu.FirstName, '' '' ,eu.LastName) ''RequestedUserName''
						FROM SIS_General.dbo.vw_WorkFlowRequest wr WITH(nolock)	
					INNER JOIN SIS_General.dbo.WorkFlowApproval wa WITH(nolock)
						ON wa.WorkFlowRequestID = wr.ID
					LEFT OUTER JOIN SIS_General.dbo.vw_EnadocUser eu WITH(nolock)
						ON wr.RequestedUserID = eu.ID			
					WHERE wa.DoUserID = ' + @UserID + @Request + ')x
					LEFT OUTER JOIN SIS_General.dbo.vw_EnadocUser gu WITH(nolock)
			        ON gu.ID = x.GrantedUserID' 
					+	@Filter)			
	END
	
	IF(@Category = '2')
	BEGIN
		EXECUTE	('SELECT x.[ID] ,x.[RequestedUserID],x.[RequestedUserName],x.[RequestedUserDeskID],x.[RequestedReson],x.[CreatedTime],x.[Time]
					,x.[RequestType],x.[View],x.[Print],x.[Download],x.[Email],x.[Add],x.[Edit],x.[Delete],x.[ProfileType],x.[ProfileID],x.[ProfileDeskID]
					,CASE WHEN x.RequestedUserID = '+@UserID+' AND x.[PermissionStatus] = ''Pending''  THEN ''O_R'' ELSE x.[PermissionStatus] END AS ''PermissionStatus''
					,x.[GrantedUserID],x.[GrantedReson],x.[ActionTakeOn],	CONCAT(gu.FirstName, '' '' ,gu.LastName) ''GrantedUserName''
			FROM (SELECT wr.*, CONCAT(eu.FirstName, '' '' ,eu.LastName) ''RequestedUserName''
					FROM SIS_General.dbo.vw_WorkFlowRequest wr
				INNER JOIN SIS_General.dbo.vw_EnadocUser eu WITH(nolock)
					    ON wr.RequestedUserID = eu.ID
					WHERE wr.RequestedUserID = ' + @UserID + @Request +					 
				')x
        LEFT OUTER JOIN SIS_General.dbo.vw_EnadocUser gu WITH(nolock)
			    ON gu.ID = x.GrantedUserID ' +
				@Filter)				
	END
	ELSE IF(@Category = '3')
		BEGIN
			EXECUTE	('SELECT x.[ID] ,x.[RequestedUserID],x.[RequestedUserName],x.[RequestedUserDeskID],x.[RequestedReson],x.[CreatedTime],x.[Time]
					,x.[RequestType],x.[View],x.[Print],x.[Download],x.[Email],x.[Add],x.[Edit],x.[Delete],x.[ProfileType],x.[ProfileID],x.[ProfileDeskID]
					,CASE WHEN x.RequestedUserID = '+@UserID+' AND x.[PermissionStatus] = ''Pending''  THEN ''O_R'' ELSE x.[PermissionStatus] END AS ''PermissionStatus''
					,x.[GrantedUserID],x.[GrantedReson],x.[ActionTakeOn],	CONCAT(gu.FirstName, '' '' ,gu.LastName) ''GrantedUserName''
			  FROM (SELECT wr.*, CONCAT(eu.FirstName, '' '' ,eu.LastName) ''RequestedUserName''
						FROM SIS_General.dbo.vw_WorkFlowRequest wr WITH(nolock)	
					INNER JOIN SIS_General.dbo.WorkFlowApproval wa WITH(nolock)
						ON wa.WorkFlowRequestID = wr.ID
					LEFT OUTER JOIN SIS_General.dbo.vw_EnadocUser eu WITH(nolock)
						ON wr.RequestedUserID = eu.ID	
					WHERE wa.DoUserID = ' + @UserID + @Request +	
					')x
            LEFT OUTER JOIN SIS_General.dbo.vw_EnadocUser gu WITH(nolock)
			        ON gu.ID = x.GrantedUserID ' +
				@Filter)
		END
END
GO
