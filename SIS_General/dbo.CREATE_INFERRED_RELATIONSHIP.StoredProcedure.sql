USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_INFERRED_RELATIONSHIP]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CREATE_INFERRED_RELATIONSHIP](
@sourceProfileType NVARCHAR(MAX),
@sourceProfileId BIGINT,
@destinationProfileType NVARCHAR(MAX),
@destinationProfileId NVARCHAR(MAX)
)
AS
BEGIN

DECLARE @fromProfileType NVARCHAR(MAX) ='Activity'
DECLARE @toProfileType NVARCHAR(MAX)='Item'
DECLARE @fromProfileId BIGINT = 1
DECLARE @toProfileId BIGINT =12

INSERT INTO [SIS_Item].[dbo].RelatedActivity(IIC, AIC,IsInferred)
VALUES(@toProfileId, @fromProfileId, 1)

SELECT * FROM [SIS_Item].[dbo].RelatedActivity


-- THIS WILL CREATE A RELATIONSHIP FROM DESTINATION TO SOURCE
IF @sourceProfileType = 'Activity'
BEGIN
	PRINT 'SOURCE ACTIVITY'


	IF @destinationProfileType = 'Activity'
	BEGIN
		PRINT 'DESTINATION ACTIVITY'
	END
	ELSE IF @destinationProfileType ='Item'
	BEGIN
		PRINT 'DESTINATION ITEM'

		SELECT * FROM [SIS_Item].[dbo].RelatedActivity
	END
	ELSE IF @destinationProfileType ='Organization'
	BEGIN
		PRINT 'DESTINATION ORGANIZATION'
	END
	ELSE IF @destinationProfileType ='Person'
	BEGIN
		PRINT 'DESTINATION PERSON'
	END
END
ELSE IF @sourceProfileType ='Item'
BEGIN
	PRINT 'SOURCE ITEM'


	IF @destinationProfileType = 'Activity'
	BEGIN
		PRINT 'DESTINATION ACTIVITY'
	END
	ELSE IF @destinationProfileType ='Item'
	BEGIN
		PRINT 'DESTINATION ITEM'
	END
	ELSE IF @destinationProfileType ='Organization'
	BEGIN
		PRINT 'DESTINATION ORGANIZATION'
	END
	ELSE IF @destinationProfileType ='Person'
	BEGIN
		PRINT 'DESTINATION PERSON'
	END
END
ELSE IF @sourceProfileType ='Organization'
BEGIN
	PRINT 'SOURCE ORGANIZATION'


	IF @destinationProfileType = 'Activity'
	BEGIN
		PRINT 'DESTINATION ACTIVITY'
	END
	ELSE IF @destinationProfileType ='Item'
	BEGIN
		PRINT 'DESTINATION ITEM'
	END
	ELSE IF @destinationProfileType ='Organization'
	BEGIN
		PRINT 'DESTINATION ORGANIZATION'
	END
	ELSE IF @destinationProfileType ='Person'
	BEGIN
		PRINT 'DESTINATION PERSON'
	END
END
ELSE IF @sourceProfileType ='Person'
BEGIN
	PRINT 'SOURCE PERSON'


	IF @destinationProfileType = 'Activity'
	BEGIN
		PRINT 'DESTINATION ACTIVITY'
	END
	ELSE IF @destinationProfileType ='Item'
	BEGIN
		PRINT 'DESTINATION ITEM'
	END
	ELSE IF @destinationProfileType ='Organization'
	BEGIN
		PRINT 'DESTINATION ORGANIZATION'
	END
	ELSE IF @destinationProfileType ='Person'
	BEGIN
		PRINT 'DESTINATION PERSON'
	END
END

END
GO
