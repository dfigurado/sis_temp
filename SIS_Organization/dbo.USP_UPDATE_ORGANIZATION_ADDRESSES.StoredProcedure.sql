USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_ADDRESSES]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_ADDRESSES]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[OIC] [bigint] NULL,
		[AddressType] [nvarchar](max) NULL,
		[OrganizationAddress] [nvarchar](max) NULL,
		[TelephoneNo] [nvarchar](max) NULL,
		[DateFrom] [date] NULL,
		[DateTo] [date] NULL
	);

	INSERT INTO @TEMP
	SELECT A.*
	FROM OPENJSON(@JSON) WITH (
	   _json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
		[ID] [bigint] '$.id',
		[OIC] [bigint] '$.oic',
		[AddressType] [nvarchar](max) '$.addressType',
		[OrganizationAddress] [nvarchar](max) '$.organizationAddress',
		[TelephoneNo] [nvarchar](max) '$.telephoneNo',
		[DateFrom] [date] '$.dateFrom',
		[DateTo] [date] '$.dateTo'
	) A;

	DECLARE @RcowCount INT = (SELECT COUNT([OIC]) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [OIC]  FROM @TEMP WHERE [OrganizationAddress] IS NULL))
    BEGIN
        DELETE FROM [dbo].[Addresses] WHERE [OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
    END
	ELSE
	BEGIN
		--merge temp with original table
		MERGE [dbo].[Addresses] ORI
		USING @TEMP TEMP
		ON (ORI.ID = TEMP.ID)
		WHEN MATCHED 
			 THEN UPDATE
			 SET
			 ORI.[OIC] = TEMP.[OIC],
			 ORI.[AddressType] = TEMP.[AddressType],
			 ORI.[OrganizationAddress] = TEMP.[OrganizationAddress],
			 ORI.[TelephoneNo] = TEMP.[TelephoneNo],
			 ORI.[DateFrom] = TEMP.[DateFrom],
			 ORI.[DateTo]=TEMP.[DateTo]
		WHEN NOT MATCHED BY TARGET
			 THEN INSERT ([OIC], [AddressType], [OrganizationAddress], [TelephoneNo], [DateFrom],[DateTo])
			 VALUES(TEMP.[OIC],TEMP.[AddressType],TEMP.[OrganizationAddress],TEMP.[TelephoneNo],TEMP.[DateFrom],TEMP.[DateTo])
		WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
		THEN DELETE;
	END

	--delete temp data
	DELETE FROM @TEMP;
END
GO
