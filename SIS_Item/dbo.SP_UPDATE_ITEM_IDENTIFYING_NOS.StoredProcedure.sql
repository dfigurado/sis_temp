USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_IDENTIFYING_NOS]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ITEM_IDENTIFYING_NOS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[IdentifyingNumber] [nvarchar](max) NULL
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
		[IdentifyingNumber] [nvarchar](max) '$.identifyingNumber'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[OtherIdentifyingNumbers] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC)
	WHEN MATCHED THEN UPDATE
		SET ORI.[IdentifyingNumber] = TEMP.[IdentifyingNumber]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[IdentifyingNumber])
		VALUES(TEMP.[IIC],TEMP.[IdentifyingNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
