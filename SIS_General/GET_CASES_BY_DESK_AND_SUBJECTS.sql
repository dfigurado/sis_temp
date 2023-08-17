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
-- Description:	<GET_CASES_BY_DESK_AND_SUBJECTS>
-- =============================================
CREATE PROCEDURE [dbo].[GET_CASES_BY_DESK_AND_SUBJECTS]
	(
		@DeskId BIGINT,
		@SubjectId BIGINT
	)
AS
BEGIN
	SELECT [ID]
      ,[Desk]
      ,[Subject]
      ,[InitiateBy]
      ,[DateCreated]
      ,[LastEdited]
      ,[SerialNumber]
      ,[SerialAddedBy]
      ,[SerialAddedOn]
      ,[Summary]
      ,[Status]
      ,[SFNo]
  FROM [dbo].[Case]
  WHERE [Desk] = @DeskId AND [Subject] = @SubjectId;
END
GO
