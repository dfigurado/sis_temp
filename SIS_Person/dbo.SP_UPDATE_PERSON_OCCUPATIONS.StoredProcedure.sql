USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_OCCUPATIONS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_OCCUPATIONS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Occupation] [nvarchar](max) NULL,
		[Type] [nvarchar](max) NULL,
		[PostOrJob] [nvarchar](max) NULL,
		[Category] [nvarchar](max) NULL,
		[Rank] [nvarchar](max) NULL,
		[RegimentalNo] [nvarchar](max) NULL,
		[PlaceOfWork] [nvarchar](max) NULL,
		[Address] [nvarchar](max) NULL,
		[Telephone] [nvarchar](max) NULL,
		[Mobile] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[PoliceStation] [nvarchar](max) NULL,
		[From] [datetime] NULL,
		[To] [datetime] NULL,
		[Status] [nvarchar](max) NULL
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
		[Occupation] [nvarchar](max) '$.occupation',
		[Type] [nvarchar](max) '$.type',
		[PostOrJob] [nvarchar](max) '$.postOrJob',
		[Category] [nvarchar](max) '$.category',
		[Rank] [nvarchar](max) '$.rank',
		[RegimentalNo] [nvarchar](max) '$.regimentalNo',
		[PlaceOfWork] [nvarchar](max) '$.placeOfWork',
		[Address] [nvarchar](max) '$.address',
		[Telephone] [nvarchar](max) '$.telephone',
		[Mobile] [nvarchar](max) '$.mobile',
		[Country] [nvarchar](max) '$.country',
		[PoliceStation] [nvarchar](max) '$.policeStation',
		[From] [datetime] '$.from',
		[To] [datetime] '$.to',
		[Status] [nvarchar](max) '$.status'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT([PIC]) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [Occupation] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Occupations] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[Occupations] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Occupation] = TEMP.[Occupation],
		 ORI.[Type] = TEMP.[Type],
		 ORI.[PostOrJob] = TEMP.[PostOrJob],
		 ORI.[Category] = TEMP.[Category],
		 ORI.[Rank] = TEMP.[Rank],
		 ORI.[RegimentalNo] = TEMP.[RegimentalNo],
		 ORI.[PlaceOfWork] = TEMP.[PlaceOfWork],
		 ORI.[Address] = TEMP.[Address],
		 ORI.[Telephone] = TEMP.[Telephone],
		 ORI.[Mobile] = TEMP.[Mobile],
		 ORI.[Country] = TEMP.[Country],
		 ORI.[PoliceStation] = TEMP.[PoliceStation],
		 ORI.[From] = TEMP.[From],
		 ORI.[To] = TEMP.[To],
		 ORI.[Status] = TEMP.[Status]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Occupation],[Type],[PostOrJob],[Category],[Rank],[RegimentalNo],[PlaceOfWork],[Address],[Telephone],[Mobile],[Country],[PoliceStation],[From],[To],[Status])
		 VALUES(TEMP.PIC,TEMP.[Occupation],TEMP.[Type],TEMP.[PostOrJob],TEMP.[Category],TEMP.[Rank],TEMP.[RegimentalNo],TEMP.[PlaceOfWork],TEMP.[Address],TEMP.[Telephone],TEMP.[Mobile],TEMP.[Country],TEMP.[PoliceStation],TEMP.[From],TEMP.[To],TEMP.[Status])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
