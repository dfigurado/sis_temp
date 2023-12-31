USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ACTIVITY_SYSTEM_DETAILS]    Script Date: 08/06/2023 12:56:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ACTIVITY_SYSTEM_DETAILS]
@JSON NVARCHAR(MAX)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[AIC] [bigint] NULL,
		[LastModifiedUserName] [nvarchar](max) NULL,
		[DeskTarget] [int] NULL,
		[Subject] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT *
	FROM OPENJSON(@JSON) WITH (
	   [AIC] [bigint] '$.aic',
		[LastModifiedUserName] [nvarchar](max) '$.lastModifiedUserName',
		[DeskTarget] [int] '$.deskTarget',
		[Subject] [nvarchar](max) '$.subject'
	);

	UPDATE [dbo].[SystemDetails] SET
		[LastModifieduserName] = TEMP.[LastModifiedUserName],
		[LastModifiedDate] = GETDATE(),
		[DeskTarget] = TEMP.[DeskTarget],
		[Subject] = TEMP.[Subject]
	FROM [dbo].[SystemDetails] ORI
	INNER JOIN @TEMP TEMP
	ON ORI.AIC = TEMP.AIC 
	WHERE ORI.AIC = TEMP.AIC 


	--delete temp data
	DELETE FROM @TEMP

END
GO
