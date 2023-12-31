USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_RELATED_ITEMS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_UPDATE_PERSON_RELATED_ITEMS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[IIC] [bigint] NULL,
		[IdentifyingFeature] [nvarchar](max) NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[IIC] [bigint] '$.iic',
		[IdentifyingFeature] [nvarchar](max) '$.identifyingFeature'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [IdentifyingFeature] IS NULL))
    BEGIN
        DELETE FROM [dbo].[RelatedItems] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[RelatedItems] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[IIC] = TEMP.[IIC],
		 ORI.[IdentifyingFeature] = TEMP.[IdentifyingFeature]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [IIC],[IdentifyingFeature])
		 VALUES(TEMP.PIC,TEMP.[IIC],TEMP.[IdentifyingFeature])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END

	----merge with related person of item db
	--MERGE [SIS_Item].[dbo].[RelatedPersons] ORI
	--USING @TEMP TEMP
	--ON (ORI.PIC = TEMP.PIC AND ORI.IIC=TEMP.IIC)
	--WHEN NOT MATCHED BY TARGET
	--	 THEN INSERT ([PIC], [IIC])
	--	 VALUES(TEMP.PIC,TEMP.[IIC]);
	----WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	----THEN DELETE;
	--END

	
	-- REMOVING THIS PERSON FROM ALL THE ITEMS RELATED
	DELETE FROM SIS_Item.DBO.RelatedPersons
	WHERE IsInferred=1
	AND PIC=(SELECT TOP 1 PIC FROM @TEMP)

	-- MAKE RELATIONS FROM CONVEYANCES
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT IIC, PIC, 1, 'SIS_Person.dbo.Conveyances' AS IsInferred FROM SIS_Person.DBO.Conveyances WHERE PIC=(SELECT TOP 1 PIC FROM @TEMP)

	-- MAKE RELATIONS FROM RELATED ITEMS
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT IIC, PIC, 1, 'SIS_Person.dbo.RelatedItems' AS IsInferred FROM SIS_Person.DBO.RelatedItems WHERE PIC=(SELECT TOP 1 PIC FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
GO
