USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SUBJECT_DETAILS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SUBJECT_DETAILS](@ID INT)
AS
BEGIN

 SELECT s.*
    FROM SIS_General.[dbo].[Predefined_Subjects] s with(nolock)
    WHERE s.ID = @ID

END

--[GET_SUBJECT_DETAILS] 1
GO
