USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_DETAILS_OF_OWNERS]    Script Date: 26/07/2023 15:36:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_DETAILS_OF_OWNERS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Information] [nvarchar](max) NULL,
		[FromDate] [datetime] NULL,
		[ToDate] [datetime] NULL
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
		[PIC] [bigint] '$.pic',
		[Information] [nvarchar](max) '$.information',
		[FromDate] [datetime] '$.fromDate',
		[ToDate] [datetime] '$.toDate'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[DetailsOfOwner] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC)
	WHEN MATCHED THEN
		UPDATE SET
		ORI.[PIC] = TEMP.[PIC],
		ORI.[Information] = TEMP.[Information],
		ORI.[FromDate] = TEMP.[FromDate],
		ORI.[ToDate] = TEMP.[ToDate]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[PIC],[Information],[FromDate],[ToDate])
		VALUES(TEMP.[IIC],TEMP.[PIC],TEMP.[Information],TEMP.[FromDate],TEMP.[ToDate])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

    DELETE FROM SIS_Person.dbo.RelatedItems
	WHERE InferredTable = 'SIS_Item.dbo.DetailsOfOwner'
	AND IIC = (SELECT TOP(1) [IIC] FROM @TEMP)

	INSERT INTO SIS_Person.dbo.RelatedItems(PIC, IIC, IsInferred, InferredTable)
	SELECT PIC,IIC,1,'SIS_Item.dbo.DetailsOfOwner' FROM SIS_Item.dbo.DetailsOfOwner
	WHERE IIC=(SELECT TOP(1) [IIC] FROM @TEMP)

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END