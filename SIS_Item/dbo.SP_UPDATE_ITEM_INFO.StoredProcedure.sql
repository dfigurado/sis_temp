USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_INFO]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_ITEM_INFO] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[IIC] [bigint] NULL,
		[TypeOfItem] [nvarchar](max) NULL,
		[SubClassificationI] [nvarchar](max) NULL,
		[SubClassificationII] [nvarchar](max) NULL,
		[DescriptionOfItem] [nvarchar](max) NULL,
		[Model] [nvarchar](max) NULL,
		[Make] [nvarchar](max) NULL,
		[CountryOfManufacture] [nvarchar](max) NULL,
		[Quantity] [nvarchar](max) NULL,
		[AmountOrValue] [nvarchar](max) NULL,
		[Measurement] [nvarchar](max) NULL,
		[MainIdentifyingNumber] [nvarchar](max) NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT * FROM OPENJSON(@JSON) WITH(
		[IIC] [bigint] '$.iic',
		[TypeOfItem] [nvarchar](max) '$.typeOfItem',
		[SubClassificationI] [nvarchar](max) '$.subClassificationI',
		[SubClassificationII] [nvarchar](max) '$.subClassificationII',
		[DescriptionOfItem] [nvarchar](max) '$.descriptionOfItem',
		[Model] [nvarchar](max) '$.model',
		[Make] [nvarchar](max) '$.make',
		[CountryOfManufacture] [nvarchar](max) '$.countryOfManufacture',
		[Quantity] [nvarchar](max) '$.quantity',
		[AmountOrValue] [nvarchar](max) '$.amountOrValue',
		[Measurement] [nvarchar](max) '$.measurement',
		[MainIdentifyingNumber] [nvarchar](max) '$.mainIdentifyingNumber'
	);

	--UPDATE OR MERGE TABLES
	UPDATE ORI
	SET
		ORI.[TypeOfItem] = TEMP.[TypeOfItem],
		ORI.[SubClassificationI] = TEMP.[SubClassificationI],
		ORI.[SubClassificationII] = TEMP.[SubClassificationII],
		ORI.[DescriptionOfItem] = TEMP.[DescriptionOfItem],
		ORI.[Model] = TEMP.[Model],
		ORI.[Make] = TEMP.[Make],
		ORI.[CountryOfManufacture] = TEMP.[CountryOfManufacture],
		ORI.[Quantity] = TEMP.[Quantity],
		ORI.[AmountOrValue] = TEMP.[AmountOrValue],
		ORI.[Measurement] = TEMP.[Measurement],
		ORI.[MainIdentifyingNumber] = TEMP.[MainIdentifyingNumber]
	FROM [dbo].[ItemInformation] ORI
	INNER JOIN @TEMP TEMP
	ON ORI.IIC = TEMP.IIC
	WHERE ORI.IIC = TEMP.IIC;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
