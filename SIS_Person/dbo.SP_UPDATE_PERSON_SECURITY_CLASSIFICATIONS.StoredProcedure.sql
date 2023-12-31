USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_SECURITY_CLASSIFICATIONS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_SECURITY_CLASSIFICATIONS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[SecurityClassification] [nvarchar](max) NULL,
		[RelatedCountry] [nvarchar](max) NULL,
		[DateFrom] [datetime] NULL,
		[DateTo] [datetime] NULL
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
		[SecurityClassification] [nvarchar](max) '$.securityClassification',
		[RelatedCountry] [nvarchar](max) '$.relatedCountry',
		[DateFrom] [datetime] '$.dateFrom',
		[DateTo] [datetime] '$.dateTo'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [SecurityClassification] IS NULL))
    BEGIN
        DELETE FROM [dbo].[SecurityClassifications] WHERE [PIC] = (SELECT TOP 1 [PIC] FROM @TEMP)
    END
	ELSE
	BEGIN

	--merge temp with original table
	MERGE [dbo].[SecurityClassifications] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[SecurityClassification] = TEMP.[SecurityClassification],
		 ORI.[RelatedCountry] = TEMP.[RelatedCountry],
		 ORI.[DateFrom] = TEMP.[DateFrom],
		 ORI.[DateTo] = TEMP.[DateTo]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [SecurityClassification],[RelatedCountry], [DateFrom], [DateTo])
		 VALUES(TEMP.PIC,TEMP.[SecurityClassification],TEMP.[RelatedCountry],TEMP.[DateFrom],TEMP.[DateTo])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
