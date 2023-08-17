USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_EMPLOYEES]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_EMPLOYEES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Type] [nvarchar](max) NULL,
		[Country] [nvarchar](max) NULL,
		[District] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[OIC] [bigint] '$.oic',
		[PIC] [bigint] '$.relatedPIC',
		[Type] [nvarchar](max) '$.type',
		[Country] [nvarchar] '$.countryName',
		[District] [nvarchar] '$.districtName'
	) A;


	--merge temp with original table
	MERGE [dbo].[Employees] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[PIC] = TEMP.[PIC],
		 ORI.[District] = TEMP.[District],
		 ORI.[Type] = TEMP.[Type],
		 ORI.[Country] = TEMP.[Country]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [PIC], [Type], [Country], [District])
		 VALUES(TEMP.[OIC],TEMP.[PIC],TEMP.[Type],TEMP.[Country],TEMP.[District])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
