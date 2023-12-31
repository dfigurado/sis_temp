USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_DISTRICT_LEADERS]    Script Date: 7/21/2023 8:25:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_DISTRICT_LEADERS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[PIC] [bigint] NULL,
		[District] [nvarchar](max) NULL,
		[DateFrom] [datetime] NULL,
		[DateTo] [datetime] NULL
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
		[District] [nvarchar](max) '$.district',
		[DateFrom] [datetime] '$.dateFrom',
		[DateTo] [datetime] '$.dateTo'
	) A;


	--merge temp with original table
	MERGE [dbo].[DistrictLeaders] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[PIC] = TEMP.[PIC],
		 ORI.[District] = TEMP.[District],
		 ORI.[DateFrom] = TEMP.[DateFrom],
		 ORI.[DateTo] = TEMP.[DateTo]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [PIC], [District], [DateFrom], [DateTo])
		 VALUES(TEMP.[OIC],TEMP.[PIC],TEMP.[District],TEMP.[DateFrom],TEMP.[DateTo])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	DELETE FROM SIS_Person.dbo.Organizations
	WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)
	AND [InferredTable]='SIS_Organization.dbo.DistrictLeaders'

	
   INSERT INTO SIS_Person.dbo.Organizations(OIC,PIC,[IsInferred],[InferredTable])
   SELECT OIC,PIC, 1,'SIS_Organization.dbo.DistrictLeaders' FROM SIS_Organization.dbo.DistrictLeaders
   WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
