USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[CHECK_EXISTING_NIC]    Script Date: 08/06/2023 13:14:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[CHECK_EXISTING_NIC]
	@nic nvarchar(20)
AS
BEGIN
	SELECT TOP (1) [ID]
      ,[PIC]
      ,[IdNumber]
  FROM [SIS_Person].[dbo].[Identification]
  WHERE IdNumber = @nic
END
GO
