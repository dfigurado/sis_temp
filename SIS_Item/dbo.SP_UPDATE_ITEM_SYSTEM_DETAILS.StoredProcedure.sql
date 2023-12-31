USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_ITEM_SYSTEM_DETAILS]    Script Date: 08/06/2023 13:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_ITEM_SYSTEM_DETAILS] @JSON NVARCHAR(MAX)
AS
BEGIN
	--DECLARE TEMP TABLE ACCORGING TO TARGET
	DECLARE @TEMP TABLE(
		[IIC] [bigint] NULL,
		[LastModifieduserName] [nvarchar](max) NULL,
		[DeskTarget] [int] NULL,
		[Subject] [nvarchar](max) NULL
	);

	--INSER DATA TO TEMP TABLE FROM JSON
	INSERT INTO @TEMP
	SELECT * FROM OPENJSON(@JSON) WITH(
		[IIC] [bigint] '$.iic',
		[LastModifieduserName] [nvarchar](max) '$.lastModifieduserName',
		[DeskTarget] [int] '$.deskTarget',
		[Subject] [nvarchar](max) '$.subject'
	);

	--UPDATE OR MERGE TABLES
	UPDATE ORI
	SET
		ORI.[LastModifieduserName] = TEMP.[LastModifieduserName],
		ORI.[LastModifiedDate] = GETDATE(),
		ORI.[DeskTarget] = TEMP.[DeskTarget],
		ORI.[Subject] = TEMP.[Subject]
	FROM [dbo].[SystemDetails] ORI
	INNER JOIN @TEMP TEMP
	ON ORI.IIC = TEMP.IIC
	WHERE ORI.IIC = TEMP.IIC;

	--DELETE TEMP DATA
	DELETE FROM @TEMP;
END
GO
