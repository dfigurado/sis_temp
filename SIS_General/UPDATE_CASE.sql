-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sachithra Dilshan>
-- Create date: <2023-07-19>
-- Description:	<UPDATE_CASE>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_CASE]
	(
		@Id BIGINT,
		@DeskId BIGINT,
		@SubjectId BIGINT
	)
AS
BEGIN
	UPDATE [dbo].[Case]
	SET [Desk] = @DeskId,
		[Subject] = @SubjectId
	WHERE [ID] = @Id;
END
GO
