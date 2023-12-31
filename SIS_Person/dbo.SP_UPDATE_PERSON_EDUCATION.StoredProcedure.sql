USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_EDUCATION]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_EDUCATION]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[EducationLevel] [nvarchar](max) NULL,
		[CollageType] [nvarchar](max) NULL,
		[CollageName] [nvarchar](max) NULL,
		[Course] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[From] [datetime] NULL,
		[To] [datetime] NULL,
		[Place] [nvarchar](max) NULL
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
		[EducationLevel] [nvarchar](max) '$.educationLevel',
		[CollageType] [nvarchar](max) '$.collageType',
		[CollageName] [nvarchar](max) '$.collageName',
		[Course] [nvarchar](max) '$.course',
		[Country] [nvarchar](max) '$.country',
		[From] [datetime] '$.from',
		[To] [datetime] '$.to',
		[Place] [nvarchar](max) '$.place'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [EducationLevel] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Education] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN

	--merge temp with original table
	MERGE [dbo].[Education] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[EducationLevel] = TEMP.[EducationLevel],
		 ORI.[CollageType] = TEMP.[CollageType],
		 ORI.[CollageName] = TEMP.[CollageName],
		 ORI.[Course] = TEMP.[Course],
		 ORI.[Country] = TEMP.[Country],
		 ORI.[From] = TEMP.[From],
		 ORI.[To] = TEMP.[To],
		 ORI.[Place] = TEMP.[Place]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [EducationLevel], [CollageType], [CollageName], [Course], [Country], [From], [To], [Place])
		 VALUES(TEMP.PIC,TEMP.[EducationLevel],TEMP.[CollageType],TEMP.[CollageName],TEMP.[Course],TEMP.[Country],TEMP.[From],TEMP.[To],TEMP.[Place])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
