USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ROLE_WISE_ACCESS_RESTRICTIONS]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ROLE_WISE_ACCESS_RESTRICTIONS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[DirectorOnly] [bit] NULL,
		[DeskOfficerOnly] [bit] NULL
	);

	INSERT INTO @TEMP
	SELECT * 
	FROM OPENJSON(@JSON)
	WITH  (
		[OIC] [bigint] '$.oic',
		[DirectorOnly] [bit] '$.directorOnly',
		[DeskOfficerOnly] [bit]'$.deskOfficerOnly'
	);

	UPDATE [DirectAndRoleWiseAccessRestrictions]
	SET
	  [DirectorOnly] = TEMP.[DirectorOnly],
	  [DeskOfficerOnly] = TEMP.[DeskOfficerOnly]
	FROM [dbo].[DirectAndRoleWiseAccessRestrictions] ORI
		 INNER JOIN
	@TEMP TEMP
	ON ORI.[OIC] = TEMP.[OIC]
	WHERE  ORI.[OIC] = TEMP.[OIC]

	DELETE FROM @TEMP
END
GO
