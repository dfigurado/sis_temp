USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_DETAILS_OF_RECOVERIES]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ITEM_DETAILS_OF_RECOVERIES] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[IIC] [bigint] NULL,
		[Date] [datetime] NULL,
		[Place] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[PoliceStation] [nvarchar](max) NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[IIC] [bigint] '$.iic',
		[Date] [datetime] '$.date',
		[Place] [nvarchar](max) '$.place',
		[Country] [nvarchar](max) '$.country',
		[PoliceStation] [nvarchar](max) '$.policeStation'
	) A;

	--UPDATE OR MERGE TABLES
	MERGE [dbo].[DetailsOfRecovery] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID AND ORI.IIC = TEMP.IIC)
	WHEN MATCHED THEN
		UPDATE SET
		ORI.[Date] = TEMP.[Date],
		ORI.[Place] = TEMP.[Place],
		ORI.[Country] = TEMP.[Country],
		ORI.[PoliceStation] = TEMP.[PoliceStation]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([IIC],[Date],[Place],[Country],[PoliceStation])
		VALUES(TEMP.[IIC],TEMP.[Date],TEMP.[Place],TEMP.[Country],TEMP.[PoliceStation])
	WHEN NOT MATCHED BY SOURCE AND ORI.[IIC] = (SELECT TOP(1) [IIC] FROM @TEMP) THEN
		DELETE;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
