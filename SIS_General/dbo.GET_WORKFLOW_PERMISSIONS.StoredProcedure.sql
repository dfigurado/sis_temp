USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_WORKFLOW_PERMISSIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_WORKFLOW_PERMISSIONS] (@UserID AS INT)
AS
BEGIN

	SELECT wp.UserID,
		   wp.ProfileType,
		   wp.ProfileDeskID,
		   wp.ProfileID,
		   CAST(IIF(SUM(CAST([View] AS INT)) > 0,1,0) AS bit) AS 'View',
		   CAST(IIF(SUM(CAST([Print] AS INT)) > 0,1,0) AS bit) AS 'Print',
		   CAST(IIF(SUM(CAST([Download] AS INT)) > 0,1,0) AS bit) AS 'Download',
		   CAST(IIF(SUM(CAST([Email] AS INT)) > 0,1,0) AS bit) AS 'Email',
		   CAST(IIF(SUM(CAST([Add] AS INT)) > 0,1,0) AS bit) AS 'Add',
		   CAST(IIF(SUM(CAST([Edit] AS INT)) > 0,1,0) AS bit) AS 'Edit',
		   CAST(IIF(SUM(CAST([Delete] AS INT)) > 0,1,0) AS bit) AS 'Delete'
	  FROM WorkFlowPermissions wp WITH(nolock)
	 WHERE CAST(EndTime AS smalldatetime) >= CAST(GETDATE() AS smalldatetime)
	   AND wp.UserID = @UserID
	GROUP BY wp.UserID,wp.ProfileType,wp.ProfileDeskID,wp.ProfileID

END
GO
