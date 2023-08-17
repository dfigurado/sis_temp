USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_USER_GROUP_FOR_CASE]    Script Date: 8/8/2023 11:04:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sachithra Dilshan>
-- Create date: <8/7/2023>
-- Description:	<Get Desk group From Case>
-- =============================================
CREATE PROCEDURE [dbo].[GET_USER_GROUP_FOR_CASE]
	@CASEID BIGINT
AS
BEGIN
SELECT(SELECT ID, [Name] FROM [dbo].[vw_EnadocUserGroup]
WHERE ID IN(SELECT [UserGroup] FROM [dbo].[Case] WHERE [ID] = @CASEID) FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER) AS UserGroup
END
