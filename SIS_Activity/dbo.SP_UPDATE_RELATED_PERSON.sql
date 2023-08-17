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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_RELATED_PERSON]
	@JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[PIC] [bigint] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[PIC] [bigint] '$.pic'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
	IF(@RcowCount = 1 AND EXISTS(SELECT [PIC] FROM @TEMP WHERE [AIC] IS NULL))
		BEGIN
			DELETE FROM [dbo].[RelatedPerson] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
		END
	ELSE
		BEGIN
			--merge temp with original table
			MERGE [dbo].[RelatedPerson] ORI
			USING @TEMP TEMP
			ON (ORI.[AIC] = TEMP.[AIC] AND ORI.[PIC] = TEMP.[PIC])
			WHEN NOT MATCHED BY TARGET
				 THEN INSERT ([AIC], [PIC])
				 VALUES(TEMP.[AIC],TEMP.[PIC])
			WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
			THEN DELETE;
		END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
