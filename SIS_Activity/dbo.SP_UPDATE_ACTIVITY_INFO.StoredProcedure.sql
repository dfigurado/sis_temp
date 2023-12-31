USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_INFO]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_INFO](@JSON NVARCHAR(MAX))
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[TypeOfActivity] [nvarchar](max) NULL,
		[MajorClassification] [nvarchar](max) NULL,
		[MinorClassification] [nvarchar](max) NULL,
		[DescriptionOfTheActivity] [nvarchar](max) NULL,
		[StartDateTime] [datetime] NULL,
		[EndDateTime] [datetime] NULL,
		[Place] [nvarchar](max) NULL,
		[AdministrativeDistrict] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[PoliceStation] [nvarchar](max) NULL,
		[Attendance] [nvarchar](max) NULL,
		[OutCome] [nvarchar](max) NULL,
		[GridLocationCode] [nvarchar](max) NULL,
		[GridRefName] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT * 
	FROM OPENJSON(@JSON)
	WITH  (
        [AIC] [bigint] '$.aic',
		[TypeOfActivity] [nvarchar](max)'$.typeOfActivity',
		[MajorClassification] [nvarchar](max) '$.majorClassification',
		[MinorClassification] [nvarchar](max) '$.minorClassification',
		[DescriptionOfTheActivity] [nvarchar](max) '$.descriptionOfTheActivity',
		[StartDateTime] [datetime] '$.startDateTime',
		[EndDateTime] [datetime] '$.endDateTime',
		[Place] [nvarchar](max) '$.place',
		[AdministrativeDistrict] [nvarchar](max) '$.administrativeDistrict',
		[Country] [nvarchar](max) '$.country',
		[PoliceStation] [nvarchar](max) '$.policeStation',
		[Attendance] [nvarchar](max) '$.attendance',
		[OutCome] [nvarchar](max) '$.outCome',
		[GridLocationCode] [nvarchar](max) '$.gridLocationCode',
		[GridRefName] [nvarchar](max) '$.gridRefName'
    );

	UPDATE [dbo].[ActivityInformation]
	SET
		[TypeOfActivity] = TEMP.[TypeOfActivity],
		[MajorClassification] = TEMP.[MajorClassification],
		[MinorClassification] = TEMP.[MinorClassification],
		[DescriptionOfTheActivity] = TEMP.[DescriptionOfTheActivity],
		[StartDateTime] = TEMP.[StartDateTime],
		[EndDateTime] = TEMP.[EndDateTime],
		[Place] = TEMP.[Place],
		[AdministrativeDistrict] = TEMP.[AdministrativeDistrict],
		[Country] = TEMP.[Country],
		[PoliceStation] = TEMP.[PoliceStation],
		[Attendance] = TEMP.[Attendance],
		[OutCome] = TEMP.[OutCome],
		[GridLocationCode] = TEMP.[GridLocationCode],
		[GridRefName] = TEMP.[GridRefName]
	FROM [dbo].[ActivityInformation] ORI
		 INNER JOIN
	@TEMP TEMP
	ON ORI.[AIC] = TEMP.[AIC]
	WHERE  ORI.[AIC] = TEMP.[AIC]

	DELETE FROM @TEMP
END
GO
