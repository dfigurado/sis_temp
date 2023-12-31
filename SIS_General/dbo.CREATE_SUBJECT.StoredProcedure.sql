USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_SUBJECT]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CREATE_SUBJECT](@JSON nVARCHAR(MAX))
AS
BEGIN

	--DECLARE @ID AS INT  = (SELECT [Value] FROM OPENJSON(@JSON)WHERE [Key] = 'no')
	DECLARE @deskTargetID AS INT = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'parentCategogyID')
	DECLARE @subjectCode AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'name')
	DECLARE @description AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'description')


	IF NOT EXISTS (SELECT * FROM [Predefined_Subjects] WHERE SubjectCode = @subjectCode)
	BEGIN

		INSERT INTO [Predefined_Subjects] ([SubjectCode],[Description],DeskTargetID) 
		OUTPUT CAST(INSERTED.ID AS bigint) 
			 VALUES (@subjectCode,@description,@deskTargetID)

	END
	ELSE
	BEGIN

		SELECT CAST(0 AS bigint) 

	END
		EXEC UPDATE_DESK_USER_PERMISSION
END



--
GO
