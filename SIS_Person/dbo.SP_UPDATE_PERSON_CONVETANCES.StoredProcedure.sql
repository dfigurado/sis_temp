USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_CONVETANCES]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_CONVETANCES]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_CO TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[IIC] [bigint] NULL,
		[IdentifyingFeature] [nvarchar](max) NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CO
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CO nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CO) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[IIC] [nvarchar](max) '$.iic',
		[IdentifyingFeature] [nvarchar](max) '$.identifyingFeature'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_CO);
    IF(@RcowCount = 1 AND EXISTS(SELECT PIC  FROM @TEMP_CO WHERE [IIC] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Conveyances] WHERE PIC = (SELECT TOP 1 PIC FROM @TEMP_CO)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[Conveyances] ORI
	USING @TEMP_CO TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[IIC] = TEMP.[IIC],
		 ORI.[IdentifyingFeature] = TEMP.[IdentifyingFeature]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [IIC], [IdentifyingFeature])
		 VALUES(TEMP.PIC,TEMP.[IIC],TEMP.[IdentifyingFeature])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CO)
	THEN DELETE;
	END

	-- REMOVING THIS PERSON FROM ALL THE ITEMS RELATED
	DELETE FROM SIS_Item.DBO.RelatedPersons
	WHERE IsInferred=1
	AND PIC=(SELECT TOP 1 PIC FROM @TEMP_CO)

	-- MAKE RELATIONS FROM CONVEYANCES
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT TOP(1) IIC, PIC, 1, 'SIS_Person.dbo.Conveyances' AS IsInferred FROM SIS_Person.DBO.Conveyances WHERE PIC=(SELECT TOP 1 PIC FROM @TEMP_CO)

	-- MAKE RELATIONS FROM RELATED ITEMS
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT TOP(1) IIC, PIC, 1, 'SIS_Person.dbo.RelatedItems' AS IsInferred FROM SIS_Person.DBO.RelatedItems WHERE PIC=(SELECT TOP 1 PIC FROM @TEMP_CO)

	--delete temp data
	DELETE FROM @TEMP_CO
END
GO
