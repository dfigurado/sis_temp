USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PARENT_DESKS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_PARENT_DESKS](@ID INT)
AS
BEGIN

 SELECT dt.*
    FROM SIS_General.dbo.Predefined_DeskTarget dt with(nolock)
  LEFT OUTER JOIN SIS_General.dbo.Hierarchy hi with(nolock)
               ON dt.ID = hi.Desk
   WHERE hi.DivisionID = @ID

END
GO
