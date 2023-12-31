USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_CURRENT_STATUS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_CURRENT_STATUS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP_CS TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Status] [nvarchar](max) NULL,
		[FromDate] [datetime] NULL,
		[ToDate] [datetime] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP_CS
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   CC nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i.CC) WITH (
		[ID] [bigint] '$.id',
		[PIC] [bigint] '$.pic',
		[Status] [nvarchar](max) '$.status',
		[FromDate] [datetime] '$.fromDate',
		[ToDate] [datetime] '$.toDate'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP_CS);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP_CS WHERE [Status] IS NULL))
    BEGIN
        DELETE FROM [dbo].[CurrentStatus] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP_CS)
    END
	ELSE
	BEGIN
	--merge temp with original table
	MERGE [dbo].[CurrentStatus] ORI
	USING @TEMP_CS TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Status] = TEMP.[Status],
		 ORI.[FromDate] = TEMP.[FromDate],
		 ORI.[ToDate] = TEMP.[ToDate]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Status], [FromDate], [ToDate])
		 VALUES(TEMP.PIC,TEMP.[Status],TEMP.[FromDate],TEMP.[ToDate])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP_CS)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP_CS
END
GO
