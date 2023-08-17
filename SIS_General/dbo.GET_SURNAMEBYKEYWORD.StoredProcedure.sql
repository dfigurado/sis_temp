USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SURNAMEBYKEYWORD]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_SURNAMEBYKEYWORD]
@keyword nvarchar(250)
AS
BEGIN
	SELECT [ID],UPPER([Description]) AS 'Description' FROM [dbo].[Predefined_Surname] WHERE [Description] like ''+@keyword +'%'
END
GO
