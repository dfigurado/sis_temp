USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_NARRATIVE_INFORMATIONS]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ITEM_NARRATIVE_INFORMATIONS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[Date] [datetime] NULL,
		[Information] [nvarchar](max) NULL,
		[FileReferenceNumber] [nvarchar](max) NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[IIC] [bigint] '$.iic',
		[Date] [datetime] '$.date',
		[Information] [nvarchar](max) '$.information',
		[FileReferenceNumber] [nvarchar](max) '$.fileReferenceNumber'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[NarrativeInformation] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC)
	WHEN MATCHED THEN
		UPDATE SET
		ORI.[Date] = TEMP.[Date],
		ORI.[Information] = TEMP.[Information],
		ORI.[FileReferenceNumber] = TEMP.[FileReferenceNumber]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[Date],[Information],[FileReferenceNumber])
		VALUES(TEMP.[IIC],TEMP.[Date],TEMP.[Information],TEMP.[FileReferenceNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
