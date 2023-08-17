USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PARENT_SUBDIVISIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_PARENT_SUBDIVISIONS](@ID INT)
AS
BEGIN

 SELECT lv.*
    FROM SIS_General.dbo.Levels lv with(nolock)
    WHERE lv.ParentID = @ID

END

--[GET_PARENT_SUBDIVISIONS] 1
GO
