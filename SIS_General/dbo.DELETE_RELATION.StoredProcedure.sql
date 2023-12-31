USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_RELATION]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DELETE_RELATION](@ID BIGINT)
AS
BEGIN

	DECLARE @TR NVARCHAR(MAX)

	BEGIN TRANSACTION @TR

	DELETE FROM [dbo].[RelationshipLevels] WHERE RelationshipID = @ID
	DELETE FROM [dbo].[PermissionRelations] WHERE ID = @ID
	
	--Update Desk User Permission	
	EXEC UPDATE_DESK_USER_PERMISSION

	COMMIT TRANSACTION @TR




END
GO
