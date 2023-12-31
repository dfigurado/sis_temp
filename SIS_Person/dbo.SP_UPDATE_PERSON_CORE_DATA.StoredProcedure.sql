USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_CORE_DATA]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_CORE_DATA]
	@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TR_UPDATE_PERSON NVARCHAR(MAX)
	DECLARE @SYSTEMDETAILS NVARCHAR(MAX)
	BEGIN TRANSACTION @TR_UPDATE_PERSON
		SET NOCOUNT ON
		--INSERTING JSON ARRAY TO TEMP TABLE
		IF OBJECT_ID('tempdb..#PARSED') IS NOT NULL
			DROP TABLE #PARSED

		SELECT * INTO #PARSED FROM OPENJSON(@JSON)

	
		DECLARE @PIC BIGINT = (SELECT [value] FROM #PARSED where [key] = 'pic')
	
		UPDATE ORI
		SET 
			ORI.LastModifiedUserName = TEMP.LastModifiedUserName,
			ORI.LastModifiedDate = getdate(),
			ORI.Desk = TEMP.Desk,
			ORI.[Subject]= TEMP.[Subject]
		
		FROM [dbo].[SystemDetails] ORI
			 INNER JOIN
		(SELECT * FROM OPENJSON(@JSON)
		WITH(
			PIC BIGINT '$.pic',
			LastModifiedUserName NVARCHAR(MAX) '$.lastModifiedUserName',
			LastModifiedDate DATE '$.lastModifiedDate',
			Desk NVARCHAR(MAX) '$.deskId',
			[Subject] NVARCHAR(MAX) '$.subjectId'
		)) TEMP
		ON ORI.PIC = @PIC
		WHERE ORI.PIC = @PIC

		DROP TABLE #PARSED
	COMMIT TRANSACTION @TR_UPDATE_PERSON
END
GO
