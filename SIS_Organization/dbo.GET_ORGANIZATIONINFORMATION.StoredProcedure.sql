USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[GET_ORGANIZATIONINFORMATION]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_ORGANIZATIONINFORMATION]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT * FROM OrganizationInformation
END
GO
