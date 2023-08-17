USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_DESK_DETAILS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_DESK_DETAILS](@ID INT)
AS
BEGIN

 SELECT d.*
    FROM SIS_General.[dbo].[Predefined_DeskTarget] d with(nolock)
    WHERE d.ID = @ID

END

--[GET_DESK_DETAILS] 1
GO
