USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_ROLEWISE_ACCESS_RESTRICTIONS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_ROLEWISE_ACCESS_RESTRICTIONS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[DirectorOnly] [bit] NULL,
		[DeskOfficerOnly] [bit] NULL
	);

	INSERT INTO @TEMP
	SELECT *
	FROM OPENJSON(@JSON) WITH (
		[AIC] [bigint] '$.aic',
		[DirectorOnly] [bit] '$.directorOnly',
		[DeskOfficerOnly] [bit] '$.deskOfficerOnly'
	);

	MERGE [dbo].[DirectAndRoleWiseAccessRestrictions] ORI
	USING @TEMP TEMP
	ON (ORI.[AIC] = TEMP.[AIC])
	WHEN MATCHED THEN
	UPDATE SET
		ORI.[DirectorOnly] = TEMP.[DirectorOnly],
		ORI.[DeskOfficerOnly] = TEMP.[DeskOfficerOnly]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT([AIC],[DirectorOnly],[DeskOfficerOnly])
		VALUES(TEMP.[AIC],TEMP.[DirectorOnly], TEMP.[DeskOfficerOnly])
	WHEN NOT MATCHED BY SOURCE  AND ORI.[AIC] = (SELECT TOP 1 [AIC] FROM @TEMP)
	THEN DELETE;


	--delete temp data
	DELETE FROM @TEMP

END
GO
