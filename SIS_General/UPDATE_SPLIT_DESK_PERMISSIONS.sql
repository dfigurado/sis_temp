-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sachithra Dilshan>
-- Create date: <2023-07-19>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_SPLIT_DESK_PERMISSIONS]
	(
		@OriginalDeskId INT,
		@DeskToMoveId INT
	)
AS
BEGIN
	-- udpate [DeskUserPermissions]
	INSERT INTO [dbo].[DeskUserPermissions]
           ([DeskID]
           ,[UserID]
           ,[PermissionsRelationID]
           ,[View]
           ,[Print]
           ,[Download]
           ,[Email]
           ,[Add]
           ,[Edit]
           ,[Delete])
	SELECT @DeskToMoveId
      ,[UserID]
      ,[PermissionsRelationID]
      ,[View]
      ,[Print]
      ,[Download]
      ,[Email]
      ,[Add]
      ,[Edit]
      ,[Delete]
  FROM [dbo].[DeskUserPermissions]
  WHERE DeskID = @OriginalDeskId

  -- update [DeskUserPermissionsSummary]
  INSERT INTO [dbo].[DeskUserPermissionsSummary]
           ([UserID]
           ,[DeskID]
           ,[View]
           ,[Print]
           ,[Download]
           ,[Email]
           ,[Add]
           ,[Edit]
           ,[Delete])
  SELECT [UserID]
      ,@DeskToMoveId
      ,[View]
      ,[Print]
      ,[Download]
      ,[Email]
      ,[Add]
      ,[Edit]
      ,[Delete]
  FROM [dbo].[DeskUserPermissionsSummary]
  WHERE [DeskID] = @OriginalDeskId

  -- update [Hierarchy]
  INSERT INTO [dbo].[Hierarchy]
           ([DivisionID]
           ,[SubDivisionID]
           ,[Desk]
		   ,[CreatedDate])
  SELECT [DivisionID]
      ,[SubDivisionID]
      ,@DeskToMoveId
      ,GETDATE()
  FROM [dbo].[Hierarchy]
  WHERE [Desk] = @OriginalDeskId;
END
GO
