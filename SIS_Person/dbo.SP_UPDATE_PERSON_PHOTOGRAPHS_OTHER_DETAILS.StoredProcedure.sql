USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_PHOTOGRAPHS_OTHER_DETAILS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_PHOTOGRAPHS_OTHER_DETAILS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[Place] [nvarchar](max) NULL,
		[ReferenceNumber] [nvarchar](max) NULL
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
		[Place] [nvarchar](max) '$.place',
		[ReferenceNumber] [nvarchar](max) '$.referenceNumber'
	) A;

	--merge temp with original table
	MERGE [dbo].[PhotographsOtherDetails] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[Place] = TEMP.[Place],
		 ORI.[ReferenceNumber] = TEMP.[ReferenceNumber]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC], [Place],[ReferenceNumber])
		 VALUES(TEMP.PIC,TEMP.[Place],TEMP.[ReferenceNumber])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
