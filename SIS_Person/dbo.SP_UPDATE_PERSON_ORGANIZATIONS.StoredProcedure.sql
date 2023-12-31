USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_ORGANIZATIONS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_UPDATE_PERSON_ORGANIZATIONS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[OIC] [bigint] NULL,
		[Type] [nvarchar](max) NULL,
		[Position] [nvarchar](max) NULL,
		[Place] [nvarchar](max) NULL,
		[From] [datetime] NULL,
		[To] [datetime] NULL
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
		[OIC] [bigint] '$.oic',
		[Type] [nvarchar](max) '$.type',
		[Position] [nvarchar](max) '$.position',
		[Place] [nvarchar](max) '$.place',
		[From] [datetime] '$.from',
		[To] [datetime] '$.to'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [Type] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Organizations] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN

	--merge temp with original table
	MERGE [dbo].[Organizations] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[Type] = TEMP.[Type],
		 ORI.[Position] = TEMP.[Position],
		 ORI.[Place] = TEMP.[Place],
		 ORI.[From] = TEMP.[From],
		 ORI.[To] = TEMP.[To]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [OIC],[Type],[Position],[Place],[From],[To])
		 VALUES(TEMP.PIC,TEMP.[OIC],TEMP.[Type],TEMP.[Position],TEMP.[Place],TEMP.[From],TEMP.[To])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END

	-- new change
 	-- exec [SIS_Organization].[dbo].[SP_UPDATE_ORGANIZATION_RELATED_PERSONS]
 	-- @JSON=@JSON

    --REMOVING THIS PERSON FROM RELATED PERSON
    DELETE FROM [SIS_Organization].[dbo].[RelatedPersons]
	WHERE [IsInferred] =1 
	AND PIC=(SELECT TOP 1 PIC FROM @TEMP)

	--MAKE RELATION FROM RELATED PERSON
	INSERT INTO [SIS_Organization].[dbo].[RelatedPersons](OIC,PIC,IsInferred,InferredTable)
	SELECT OIC,PIC,1,'SIS_Person.dbo.RelatedOrganization' AS IsInferred FROM SIS_Person.DBO.Organizations WHERE PIC=(SELECT TOP 1 PIC FROM @TEMP)

    --delete temp data
	DELETE FROM @TEMP;
END
GO