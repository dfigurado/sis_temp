USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_SYSTEM_DETAILS]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_SYSTEM_DETAILS]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[LastModifieduserName] [nvarchar](max) NULL,
		[DeskTarget] [nvarchar](max) NOT NULL,
		[Subject] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT * 
	FROM OPENJSON(@JSON)
	WITH  (
		[OIC] [bigint] '$.oic',
		[LastModifieduserName] [nvarchar](max) '$.lastModifiedUserName',
		[DeskTarget] [nvarchar](max)'$.deskTarget',
		[Subject] [nvarchar](max)'$.subject'
	);

	UPDATE [SystemDetails]
	SET
	  LastModifieduserName = TEMP.LastModifieduserName,
	  LastModifiedDate = GETDATE(),
	  DeskTarget = TEMP.DeskTarget,
	  [Subject] = TEMP.[Subject]
	FROM [dbo].[SystemDetails] ORI
		 INNER JOIN
	@TEMP TEMP
	ON ORI.[OIC] = TEMP.[OIC]
	WHERE  ORI.[OIC] = TEMP.[OIC]

	DELETE FROM @TEMP
END
GO
