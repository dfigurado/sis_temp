USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_CORRESPONDENCE]    Script Date: 08/06/2023 13:06:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CREATE_CORRESPONDENCE](@JSON NVARCHAR(MAX))
AS

BEGIN

	DECLARE @ID AS nVARCHAR(MAX)  = (SELECT COALESCE(MAX(Id)+1,1) FROM [dbo].[Correspondence])
	DECLARE @ReferenceNumber AS nVARCHAR(MAX) = CAST(YEAR(GETDATE())AS nvarchar) +CAST(MONTH(GETDATE())AS nvarchar)+CAST(DAY(GETDATE())AS nvarchar)+'-' + CAST(@ID AS nvarchar)
	DECLARE @CorrespondenceType AS nVARCHAR(MAX)  = (SELECT [Value] FROM OPENJSON(@JSON)WHERE [Key] = 'correspondenceType')
	DECLARE @RequestedFrom AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'requestedFrom')
	DECLARE @RequestedBy AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'requestedBy')
	DECLARE @Purpose AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'purpose')
	DECLARE @RequestedDate AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'requestedDate')
	DECLARE @SubmittedDate AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'submittedDate')
	DECLARE @PreparedBy AS nVARCHAR(MAX) = (SELECT [Value] FROM OPENJSON(@JSON) WHERE [Key] = 'preparedBy')

	INSERT INTO [dbo].[Correspondence] ([ID], [ReferenceNumber], [CorrespondenceType], 
	[RequestedFrom], [RequestedBy], [Purpose], [RequestedDate], [SubmittedDate], [PreparedBy])
	OUTPUT CAST(INSERTED.ID AS BIGINT)
	VALUES(@ID, @ReferenceNumber, @CorrespondenceType, @RequestedFrom, @RequestedBy, @Purpose, @RequestedDate, @SubmittedDate, @PreparedBy)	
END
GO
