USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_ROLE_WISE_ACCESS_RESTRICTIONS]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_ROLE_WISE_ACCESS_RESTRICTIONS]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[PIC] [bigint] NULL,
		[DirectorOnly] [bit] NULL,
		[DeskOfficerOnly] [bit] NULL
	);

	--insert to the temp table
	INSERT INTO @TEMP
	SELECT *
	FROM OPENJSON(@JSON) WITH (
		[PIC] [bigint] '$.pic',
		[DirectorOnly] [bit] '$.directorOnly',
		[DeskOfficerOnly] [bit] '$.deskOfficerOnly'
	);

	--merge temp with original table
	MERGE [dbo].[DirectAndRoleWiseAccessRestrictions] ORI
	USING @TEMP TEMP
	ON (ORI.[PIC] = TEMP.[PIC])
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[DirectorOnly] = TEMP.[DirectorOnly],
		 ORI.[DeskOfficerOnly] = TEMP.[DeskOfficerOnly]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC],[DirectorOnly],[DeskOfficerOnly])
		 VALUES(TEMP.[PIC],TEMP.[DirectorOnly],TEMP.[DeskOfficerOnly])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;

	--delete temp data
	DELETE FROM @TEMP;
END
GO
