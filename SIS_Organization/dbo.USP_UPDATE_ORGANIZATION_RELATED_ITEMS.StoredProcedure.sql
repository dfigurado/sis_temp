USE [SIS_Organization]
GO

/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ITEMS]    Script Date: 25/07/2023 07:46:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_RELATED_ITEMS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[IIC] [bigint] NULL,
		[IdentifyingFeature] [nvarchar](max) NULL,
		[MainIdentifyingNumber] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[IIC] [bigint] '$.iic',
		[IdentifyingFeature] [nvarchar](max) '$.identifyingFeature',
		[MainIdentifyingNumber] [nvarchar](max) '$mainIdentifyingNumber'
	) A;


	--merge temp with original table
	MERGE [dbo].[RelatedItems] ORI
	USING @TEMP TEMP
	ON (ORI.[OIC] = TEMP.[OIC] AND ORI.[IIC] = TEMP.[IIC])
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [IIC],[IdentifyingFeature],[MainIdentifyingNumber])
		 VALUES(TEMP.[OIC],TEMP.[IIC],TEMP.[IdentifyingFeature],TEMP.[MainIdentifyingNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	DELETE FROM SIS_Item.dbo.RelatedOrganizations
    WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	INSERT INTO SIS_Item.dbo.RelatedOrganizations(OIC,IIC,IsInferred,InferredTable)
		SELECT OIC,IIC,1,'SIS_Organization.dbo.RelatedItems' FROM SIS_Organization.dbo.RelatedItems
		WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
GO


