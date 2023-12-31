USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SERIAL_REFERENCES]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SERIAL_REFERENCES](@PROFILETYPE NVARCHAR(MAX), @PROFILEID BIGINT)
AS
BEGIN


IF @PROFILETYPE = 'people'
	BEGIN 

		SELECT *
		  FROM (
				SELECT FileReference FROM SIS_Person.dbo.FileReferences with(NOLOCK) WHERE PIC = @PROFILEID
				UNION
				SELECT FileReferenceNumber AS FileReference FROM SIS_Person.dbo.NarrativeInformation with(NOLOCK) WHERE PIC = @PROFILEID 
				)x
		  WHERE FileReference IS NOT NULL
		    AND LEN(FileReference) > 0

	END
ELSE IF @PROFILETYPE = 'activity'
	BEGIN 

		SELECT *
		  FROM (
				SELECT FileReference FROM SIS_Activity.dbo.FileReferences with(NOLOCK) WHERE AIC = @PROFILEID
				UNION
				SELECT FileReferenceNo AS FileReference FROM SIS_Activity.dbo.NarrativeInformation with(NOLOCK) WHERE AIC = @PROFILEID
				)y
		  WHERE FileReference IS NOT NULL
		    AND LEN(FileReference) > 0

	END
ELSE IF @PROFILETYPE = 'organization'
	BEGIN

		SELECT *
		  FROM (	
				SELECT FileReference FROM SIS_Organization.dbo.FileReferences with(NOLOCK) WHERE OIC = @PROFILEID
				UNION
				SELECT FileReferenceNumber AS FileReference FROM SIS_Organization.dbo.NarrativeInformation with(NOLOCK) WHERE OIC = @PROFILEID 
				)z
		  WHERE FileReference IS NOT NULL
		    AND LEN(FileReference) > 0

	END
ELSE IF @PROFILETYPE = 'item'
	BEGIN 

		SELECT *
		  FROM (	
				SELECT FileReference FROM SIS_Item.dbo.FileReferences with(NOLOCK) WHERE IIC = @PROFILEID
				UNION
				SELECT FileReferenceNumber AS FileReference FROM SIS_Item.dbo.NarrativeInformation with(NOLOCK) WHERE IIC = @PROFILEID 
				)a
		  WHERE FileReference IS NOT NULL
		    AND LEN(FileReference) > 0

	END

--SELECT 'A/B/C/D/V1/S3'+CONVERT(NVARCHAR(MAX),@PROFILEID) AS FileReference
--UNION
--SELECT 'A/B/C/D'
--UNION
--SELECT 'A/B/C/D/V3/S5'

END

-- [dbo].[GET_SERIAL_REFERENCES] 'people' ,22
GO
