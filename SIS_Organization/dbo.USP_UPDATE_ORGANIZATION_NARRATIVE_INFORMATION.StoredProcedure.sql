USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_NARRATIVE_INFORMATION]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_NARRATIVE_INFORMATION]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[Date] [date] NULL,
		[Information] [nvarchar](max) NULL,
		[FileReferenceNumber] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[OIC] [bigint] '$.oic',
		[Date] [date] '$.date',
		[Information] [nvarchar](max) '$.information',
		[FileReferenceNumber] [nvarchar](max) '$.fileReferenceNumber'
	) A;


	--merge temp with original table
	MERGE [dbo].[NarrativeInformation] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[Date] = TEMP.[Date],
		 ORI.[Information] = TEMP.[Information],
		 ORI.[FileReferenceNumber] = TEMP.[FileReferenceNumber]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [Date], [Information], [FileReferenceNumber])
		 VALUES(TEMP.[OIC],TEMP.[Date],TEMP.[Information],TEMP.[FileReferenceNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
