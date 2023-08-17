USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_DIVISION_DETAILS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_DIVISION_DETAILS](@ID INT)
AS
BEGIN

 SELECT lv.*
    FROM SIS_General.dbo.Levels lv with(nolock)
    WHERE lv.ID = @ID

END

--[GET_DIVISION_DETAILS] 1
GO
