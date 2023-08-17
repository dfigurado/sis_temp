USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_CASE_USER_GROUP]    Script Date: 8/7/2023 3:00:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_CASE_USER_GROUP]
	@CASEID BIGINT, @GROUPID INT
AS
BEGIN
UPDATE [dbo].[Case]
SET [UserGroup] = @GROUPID
WHERE [ID] = @CASEID
END
