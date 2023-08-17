USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SUBJECT_BY_DESK]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_SUBJECT_BY_DESK] (@DeskTargetID bigint)

AS
BEGIN

	SET NOCOUNT ON;

	SELECT ps.* FROM SIS_General.dbo.Predefined_Subjects ps where ps.DeskTargetID=@DeskTargetID
	ORDER BY ps.SubjectCode
	--  with(nolock)
	--INNER JOIN SIS_General.dbo.DeskSubject ds with(nolock)
	--		ON ds.SubjectID = ps.ID
	-- WHERE ds.DeskTargetID = @DeskTargetID
	--ORDER BY ps.[Description]


END
GO
