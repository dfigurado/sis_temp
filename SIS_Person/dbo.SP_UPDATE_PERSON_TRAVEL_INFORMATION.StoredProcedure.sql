USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_PERSON_TRAVEL_INFORMATION]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSON_TRAVEL_INFORMATION]
	 @JSON NVARCHAR(MAX)
AS
BEGIN
	--declared a temp table
	DECLARE @TEMP TABLE(
		[ID] [bigint] NULL,
		[PIC] [bigint] NULL,
		[ActionToBeTakenOnArrival] [nvarchar](max) NULL,
		[ActionToBeTakenOnDeparture] [nvarchar](max) NULL,
		[From] [datetime] NULL,
		[To] [datetime] NULL,
		[AddedDate] [datetime] NULL,
		[AuthorizedPerson] [nvarchar](max) NULL,
		[Reason] [nvarchar](max) NULL,
		[FileReferenceNo] [nvarchar](max) NULL
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
		[ActionToBeTakenOnArrival] [nvarchar](max) '$.actionToBeTakenOnArrival',
		[ActionToBeTakenOnDeparture] [nvarchar](max) '$.actionToBeTakenOnDeparture',
		[From] [datetime] '$.from',
		[To] [datetime] '$.to',
		[AddedDate] [datetime] '$.addedDate',
		[AuthorizedPerson] [nvarchar](max) '$.authorizedPerson',
		[Reason] [nvarchar](max) '$.reason',
		[FileReferenceNo] [nvarchar](max) '$.fileReferenceNo'
	) A;


	DECLARE @RcowCount INT = (SELECT COUNT(PIC) FROM @TEMP);
    IF(@RcowCount = 1 AND EXISTS(SELECT [PIC]  FROM @TEMP WHERE [ActionToBeTakenOnArrival] IS NULL))
    BEGIN
        DELETE FROM [dbo].[TravelInformation] WHERE [PIC] = (SELECT TOP 1 PIC FROM @TEMP)
    END
	ELSE
	BEGIN

	--merge temp with original table
	MERGE [dbo].[TravelInformation] ORI
	USING @TEMP TEMP
	ON (ORI.ID = TEMP.ID)
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.PIC = TEMP.PIC,
		 ORI.[ActionToBeTakenOnArrival] = TEMP.[ActionToBeTakenOnArrival],
		 ORI.[ActionToBeTakenOnDeparture] = TEMP.[ActionToBeTakenOnDeparture],
		 ORI.[From] = TEMP.[From],
		 ORI.[To]=TEMP.[To],
		 ORI.[AddedDate]=TEMP.[AddedDate],
		 ORI.[AuthorizedPerson]=TEMP.[AuthorizedPerson],
		 ORI.[Reason]=TEMP.[Reason],
		 ORI.[FileReferenceNo]=TEMP.[FileReferenceNo]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([PIC],[ActionToBeTakenOnArrival],[ActionToBeTakenOnDeparture],[From],[To],[AddedDate],[AuthorizedPerson],[Reason],[FileReferenceNo])
		 VALUES(TEMP.[PIC],TEMP.[ActionToBeTakenOnArrival],TEMP.[ActionToBeTakenOnDeparture],TEMP.[From],TEMP.[To],GETDATE(),TEMP.[AuthorizedPerson],TEMP.[Reason],TEMP.[FileReferenceNo])
	WHEN NOT MATCHED BY SOURCE AND ORI.PIC = (SELECT TOP 1 PIC FROM @TEMP)
	THEN DELETE;
	END
	--delete temp data
	DELETE FROM @TEMP;
END
GO
