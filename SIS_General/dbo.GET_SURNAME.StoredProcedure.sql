USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SURNAME]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SURNAME]
AS
BEGIN

	SELECT [ID],UPPER([Description]) AS 'Description' FROM [dbo].[Predefined_Surname]
	

END
GO
