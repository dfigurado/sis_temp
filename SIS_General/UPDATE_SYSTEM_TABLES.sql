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
-- Description:	<UPDATE_SYSTEM_TABLES>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_SYSTEM_TABLES]
	(
		@originalDeskId BIGINT,
		@newDeskId BIGINT,
		@subjectIds NVARCHAR(MAX)
	)
AS
BEGIN
	UPDATE [SIS_Activity].[dbo].[SystemDetails]
	SET [DeskTarget] = @newDeskId
	WHERE [DeskTarget] = @originalDeskId AND Subject IN (SELECT VALUE FROM string_split(@subjectIds, ','))

	UPDATE [SIS_Item].[dbo].[SystemDetails]
	SET [DeskTarget] = @newDeskId
	WHERE [DeskTarget] = @originalDeskId AND Subject IN (SELECT VALUE FROM string_split(@subjectIds, ','))

	UPDATE [SIS_Organization].[dbo].[SystemDetails]
	SET [DeskTarget] = @newDeskId
	WHERE [DeskTarget] = @originalDeskId AND Subject IN (SELECT VALUE FROM string_split(@subjectIds, ','))

	UPDATE [SIS_Person].[dbo].[SystemDetails]
	SET [Desk] = @newDeskId
	WHERE [Desk] = @originalDeskId AND Subject IN (SELECT VALUE FROM string_split(@subjectIds, ','))
END
GO
