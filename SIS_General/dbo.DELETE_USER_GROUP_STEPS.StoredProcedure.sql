USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_USER_GROUP_STEPS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DELETE_USER_GROUP_STEPS](@ID INT)
AS
BEGIN
	
	DECLARE @TR NVARCHAR(MAX)
	-- DON'T DELETE IF IT'S AN ADMINISTRATOR GROUP
	IF EXISTS (SELECT * FROM DBO.vw_EnadocUserGroup WHERE ID = @ID AND [NAME]='Administrators')
	BEGIN
		SELECT 0
	END
	ELSE
	BEGIN 
				SELECT UserID INTO #TEMP FROM [dbo].[vw_EnadocUserGroupUser] WHERE UserGroupID = @ID
	
				DELETE FROM [dbo].[vw_EnadocUserGroupUser] WHERE UserGroupID = @ID
	
				DELETE FROM [dbo].[vw_EnadocUserGroupPortal] WHERE UserGroupID = @ID
	
				DELETE FROM [dbo].[vw_EnadocUserGroup] WHERE ID = @ID
	
				DELETE FROM [dbo].[vw_EnadocUser]
				WHERE ID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))
	
				DELETE FROM [dbo].[vw_EipUser]
				WHERE ID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))

				DELETE FROM [dbo].[vw_EipUserLoginType]
				WHERE UserID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))

				DELETE FROM [SIS_Person].[dbo].[Advanced_Search_Criteria]
				WHERE UserID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))

				DELETE FROM [SIS_Activity].[dbo].[Advanced_Search_Criteria]
				WHERE UserID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))

				DELETE FROM [SIS_Item].[dbo].[Advanced_Search_Criteria]
				WHERE UserID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))

				DELETE FROM [SIS_Organization].[dbo].[Advanced_Search_Criteria]
				WHERE UserID IN (SELECT UserID FROM #TEMP WHERE UserID NOT IN (SELECT UserID FROM [dbo].[vw_EnadocUserGroupUser]))
		
	END

END
GO
