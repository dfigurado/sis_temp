USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_ADDRESS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_ADDRESS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_ADDRESS TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Type] [nvarchar](max) NULL,
		[Address] [nvarchar](max) NULL,
		[From] [datetime] NULL,
		[To] [datetime] NULL,
		[Mobile] [nvarchar](max) NULL,
		[Telephone] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[PoliceStation] [nvarchar](max) NULL,
		[AddedDate] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_ADDRESS
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _address nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._address) WITH (
	   [ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Type] [nvarchar](max) '$.type',
		[Address] [nvarchar](max) '$.address',
		[From] [datetime] '$.from',
		[To] [datetime] '$.to',
		[Mobile] [nvarchar](max) '$.mobile',
		[Telephone] [nvarchar](max) '$.telephone',
		[Country] [nvarchar](max) '$.country',
		[PoliceStation] [nvarchar](max) '$.policeStation',
		[AddedDate] [datetime] '$.addedDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_ADDRESS);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_ADDRESS WHERE [Type] IS NULL))
    BEGIN
        DELETE FROM [dbo].Addresses WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_ADDRESS)
    END
	ELSE
	BEGIN


	--merge temp with original table
	MERGE [dbo].[Addresses] ORI
	USING @TEMP_ADDRESS TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Type] = TEMP.[Type],
		 ORI.[Address] = TEMP.[Address],
		 ORI.[From] = TEMP.[From],
		 ORI.[To] = TEMP.[To],
		 ORI.Mobile=TEMP.Mobile,
		 ORI.Telephone=TEMP.Telephone,
		 ORI.Country=TEMP.Country,
		 ORI.PoliceStation=TEMP.PoliceStation
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Type], [Address], [From], [To],[AddedDate], [Mobile], [Telephone], [Country], [PoliceStation])
		 VALUES(TEMP.PIC,TEMP.[Type],TEMP.[Address],TEMP.[From],TEMP.[To],getdate(),TEMP.[Mobile],TEMP.Telephone,TEMP.Country,TEMP.PoliceStation)
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_ADDRESS)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_ADDRESS
END
GO
