USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_INSTITUTIONS_AFFECTEDS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_INSTITUTIONS_AFFECTEDS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[AIC] [bigint] NULL,
		[NameofInstitution] [nvarchar](max) NULL,
		[MajorType] [nvarchar](max) NULL,
		[MinorType] [nvarchar](max) NULL,
		[HowAffected] [nvarchar](max) NULL,
		[Place] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[AIC] [bigint] '$.aic',
		[NameofInstitution] [nvarchar](max) '$.nameofInstitution',
		[MajorType] [nvarchar](max) '$.majorType',
		[MinorType] [nvarchar](max) '$.minorType',
		[HowAffected] [nvarchar](max) '$.howAffected',
		[Place] [nvarchar](max) '$.place'
	) A;

	--merge temp with original table
	MERGE [dbo].[InstitutionsAffected] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.AIC = TEMP.AIC)
	WHEN MATCHED 
		 THEN UPDATE SET 
		 ORI.[NameofInstitution] = TEMP.[NameofInstitution],
		 ORI.[MajorType] = TEMP.[MajorType],
		 ORI.[MinorType] = TEMP.[MinorType],
		 ORI.[HowAffected] = TEMP.[HowAffected],
		 ORI.[Place] = TEMP.[Place]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([AIC], [NameofInstitution],[MajorType],[MinorType],[HowAffected],[Place])
		 VALUES (TEMP.[AIC],TEMP.[NameofInstitution],TEMP.[MajorType],TEMP.[MinorType],TEMP.[HowAffected],TEMP.[Place])
	WHEN NOT MATCHED BY SOURCE AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP

END
GO
