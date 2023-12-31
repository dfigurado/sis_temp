USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_COURIES]    Script Date: 7/21/2023 8:24:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_COURIES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NOT NULL,
		[PIC] [bigint] NOT NULL,
		[ID] [bigint] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[OIC] [bigint] '$.oic',
		[PIC] [bigint] '$.relatedPIC',
		[ID] [bigint] '$.id'
	) A;


	--merge temp with original table
	MERGE [dbo].[Couriers] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[OIC] = TEMP.[OIC],
		 ORI.[PIC] = TEMP.[PIC]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC], [PIC])
		 VALUES(TEMP.[OIC],TEMP.[PIC])
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

	DELETE FROM SIS_Person.dbo.Organizations
	WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)
	AND [InferredTable]='SIS_Organization.dbo.Couriers'

	
   INSERT INTO SIS_Person.dbo.Organizations(OIC,PIC,[IsInferred],[InferredTable])
   SELECT OIC,PIC, 1,'SIS_Organization.dbo.Couriers' FROM SIS_Organization.dbo.Couriers
   WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

	--delete temp data
	DELETE FROM @TEMP;
END
