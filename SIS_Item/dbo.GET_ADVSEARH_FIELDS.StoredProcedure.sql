USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[GET_ADVSEARH_FIELDS]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_ADVSEARH_FIELDS](@USERID INT)
AS
BEGIN

	SELECT * FROM [dbo].[Advanced_Search_Criteria]
	WHERE UserID = @USERID

END
GO
