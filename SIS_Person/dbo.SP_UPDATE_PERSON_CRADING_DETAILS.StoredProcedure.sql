USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_CRADING_DETAILS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_CRADING_DETAILS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_CD TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Reason] [nvarchar](max) NULL,
		[CardingDate] [datetime] NULL,
		[AddedDate] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CD
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CD nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CD) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Reason] [nvarchar](max) '$.reason',
		[CardingDate] [datetime] '$.cardingDate',
		[AddedDate] [datetime] '$.addedDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_CD);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_CD WHERE [Reason] IS NULL))
    BEGIN
        DELETE FROM [dbo].[CardingDetails] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_CD)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[CardingDetails] ORI
	USING @TEMP_CD TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Reason] = TEMP.[Reason],
		 ORI.[CardingDate] = TEMP.[CardingDate],
		 ORI.[AddedDate] = TEMP.[AddedDate]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Reason], [CardingDate], [AddedDate])
		 VALUES(TEMP.PIC,TEMP.[Reason],TEMP.[CardingDate],TEMP.[AddedDate])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CD)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_CD
END
GO
