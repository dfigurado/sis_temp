USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SUB_DIVISIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SUB_DIVISIONS]
AS
BEGIN

	SELECT * FROM [dbo].[Levels]
	WHERE Type = 'SubDivision'

END
GO
