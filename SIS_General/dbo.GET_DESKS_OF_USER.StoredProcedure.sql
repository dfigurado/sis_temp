USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_DESKS_OF_USER]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_DESKS_OF_USER](@USERID BIGINT)
AS
BEGIN

SELECT distinct desk.* 
  FROM Predefined_DeskTarget desk
INNER JOIN DeskUserPermissionsSummary ps
		ON ps.DeskID = desk.ID
 WHERE ps.UserID = @USERID
   AND [Add] = 1 
ORDER BY [Description]

END
--select * from DeskUserPermissionsSummary
GO
