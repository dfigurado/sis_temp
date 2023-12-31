USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_ALLTRAVELPARTICULARS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_ALLTRAVELPARTICULARS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_ATP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[FlightNo] [nvarchar](max) NULL,
		[CountryOfOrigin] [nvarchar](max) NULL,
		[PortOfOrigin] [nvarchar](max) NULL,
		[CountryOfDestination] [nvarchar](max) NULL,
		[PortOfDestination] [nvarchar](max) NULL,
		[PurposeOfVisit] [nvarchar](max) NULL,
		[PurposeInDetails] [nvarchar](max) NULL,
		[ArrivalDate] [datetime] NULL,
		[DepartureDate] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_ATP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   ATP nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.ATP) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[FlightNo] [nvarchar](max) '$.flightNo',
		[CountryOfOrigin] [nvarchar](max) '$.countryOfOrigin',
		[PortOfOrigin] [nvarchar](max) '$.portOfOrigin',
		[CountryOfDestination] [nvarchar](max) '$.countryOfDestination',
		[PortOfDestination] [nvarchar](max) '$.portOfDestination',
		[PurposeOfVisit] [nvarchar](max) '$.purposeOfVisit',
		[PurposeInDetails] [nvarchar](max) '$.purposeInDetails',
		[ArrivalDate] [datetime] '$.arrivalDate',
		[DepartureDate] [datetime] '$.departureDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_ATP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_ATP WHERE [FlightNo] IS NULL))
    BEGIN
        DELETE FROM [dbo].[AllTravelParticulars] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_ATP)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[AllTravelParticulars] ORI
	USING @TEMP_ATP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[FlightNo] = TEMP.[FlightNo],
		 ORI.[CountryOfOrigin] = TEMP.[CountryOfOrigin],
		 ORI.[PortOfOrigin] = TEMP.[PortOfOrigin],
		 ORI.[CountryOfDestination] = TEMP.[CountryOfDestination],
		 ORI.[PortOfDestination]=TEMP.[PortOfDestination],
		 ORI.[PurposeOfVisit]=TEMP.[PurposeOfVisit],
		 ORI.[PurposeInDetails]=TEMP.[PurposeInDetails],
		 ORI.[ArrivalDate]=TEMP.[ArrivalDate],
		 ORI.[DepartureDate]=TEMP.[DepartureDate]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [FlightNo], [CountryOfOrigin], [PortOfOrigin], [CountryOfDestination],[PortOfDestination], [PurposeOfVisit], [PurposeInDetails], [ArrivalDate], [DepartureDate])
		 VALUES(TEMP.PIC,TEMP.[FlightNo],TEMP.[CountryOfOrigin],TEMP.[PortOfOrigin],TEMP.[CountryOfDestination],TEMP.[PortOfDestination],TEMP.[PurposeOfVisit],TEMP.[PurposeInDetails],TEMP.[ArrivalDate],TEMP.[DepartureDate])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_ATP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_ATP
END
GO
