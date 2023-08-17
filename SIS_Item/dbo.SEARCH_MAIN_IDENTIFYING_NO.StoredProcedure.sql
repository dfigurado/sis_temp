USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SEARCH]    Script Date: 7/31/2023 5:31:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEARCH_MAIN_IDENTIFYING_NO](@QUERY NVARCHAR(MAX))
AS
BEGIN

	SELECT top (20) SD.[IIC]
      ,[TypeOfItem]
      ,[SubClassificationI]
      ,[SubClassificationII]
      ,[DescriptionOfItem]
      ,[Model]
      ,[Make]
      ,[CountryOfManufacture]
      ,[Quantity]
      ,[AmountOrValue]
      ,[MainIdentifyingNumber] FROM [dbo].[ItemInformation]
	INNER JOIN [dbo].[SystemDetails] SD ON SD.IIC=ItemInformation.IIC
	WHERE ItemInformation.[MainIdentifyingNumber] LIKE @QUERY+'%' AND SD.IsDeleted=0

END
