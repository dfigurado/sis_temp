USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_RELATIVES]    Script Date: 26/06/2023 10:49:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_UPDATE_PERSON_RELATIVES] @JSON NVARCHAR(MAX)
AS
BEGIN
	--Declared a temp table
	DECLARE @Temp TABLE (
		[ID] [bigint] NULL
	   ,[PIC] [bigint] NULL
	   ,[RelativesPIC] [nvarchar](MAX) NULL
	   ,[Name] [nvarchar](MAX) NULL
	   ,[Relationship] [nvarchar](MAX) NULL
	   ,[IdentifyingFeatures] [nvarchar](MAX) NULL
	);

	--Insert to the temp table
	INSERT INTO @Temp
		SELECT A.*
		FROM OPENJSON(@JSON) WITH
		(
			CC NVARCHAR(MAX) '$' AS JSON
		) AS i
		CROSS APPLY OPENJSON(i.CC) WITH
		(
			[ID] [bigint] '$.id',
			[PIC] [bigint] '$.pic',
			[RelativesPIC] [nvarchar](MAX) '$.relativesPIC',
			[Name] [nvarchar](MAX) '$.name',
			[Relationship] [nvarchar](MAX) '$.relationship',
			[IdentifyingFeatures] [nvarchar](MAX) '$.identifyingFeatures'
		) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC)
		                      FROM @Temp);

	IF (@RcowCount = 1
		AND EXISTS (SELECT [PIC]
			        FROM @Temp
			        WHERE [Name] IS NULL)
		)
		BEGIN
			DELETE FROM [dbo].[Realtives]
			WHERE [PIC] = (SELECT TOP 1 [PIC]
					       FROM @Temp)
		END
	ELSE
		BEGIN
			MERGE [dbo].[Realtives] ORI USING @Temp tmp
			ON (ORI.ID = tmp.ID)
			WHEN MATCHED
				THEN UPDATE
					SET ORI.PIC = tmp.PIC,
					    ORI.[RelativesPIC] = tmp.[RelativesPIC],
					    ORI.[Name] = tmp.[Name],
					    ORI.[Relationship] = tmp.[Relationship],
					    ORI.[IdentifyingFeatures] = tmp.[IdentifyingFeatures]
			WHEN NOT MATCHED BY TARGET
				THEN INSERT ([PIC],
					         [RelativesPIC],
					         [Name],
					         [Relationship],
					         [IdentifyingFeatures]
							 )
						VALUES (
								tmp.PIC, 
								tmp.[RelativesPIC],
								tmp.[Name],
								tmp.[Relationship], tmp.[IdentifyingFeatures]
							   )
			WHEN NOT MATCHED BY SOURCE
				AND ORI.PIC = (SELECT TOP 1
						PIC
					FROM @Temp)
				THEN DELETE;
		END

	--	REMOVING EXISTING INFERENCES
	DELETE FROM SIS_Person.dbo.[Realtives]
	WHERE IsInferred = 1
		AND RelativesPIC = (SELECT TOP 1
				PIC
			FROM @Temp)

	--  CR-1
	--	MAKE RELATIONS
	INSERT INTO SIS_Person.dbo.[Realtives] (
												PIC,
												RelativesPIC,
												IsInferred,
												Relationship,
												InferredTable,
												[Name]
											)
											SELECT RelativesPIC,
											       PIC,
												   1,
												   dbo.fn_GetRelationship(Relationship),
												   'SIS_Person.dbo.[Realtives]' AS InferredTable,
												   (SELECT ISNULL(Surname, '') + ' ' + ISNULL(FirstName, '') + ' ' + ISNULL(SecondName, '')
												    FROM SIS_Person.dbo.PersonInformation
												    WHERE PIC = r.PIC)
											FROM SIS_Person.dbo.[Realtives] r
											WHERE r.PIC IN (SELECT PIC
															FROM @Temp)

	--DELETE TEMP DATA
	DELETE FROM @Temp;
END