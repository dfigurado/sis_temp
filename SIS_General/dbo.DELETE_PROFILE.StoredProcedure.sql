USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_PROFILE]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DELETE_PROFILE](@ID BIGINT,@TYPE NVARCHAR(MAX),@USER INT)
AS
BEGIN

	IF @TYPE = 'Person'
	BEGIN
		UPDATE [SIS_Person].[dbo].[SystemDetails]
		SET [IsDeleted] = 1,
		[DeletedBy] = @USER
		WHERE PIC = @ID
	END
	ELSE IF @TYPE = 'Item'
	BEGIN
		UPDATE [SIS_Item].[dbo].[SystemDetails]
		SET [IsDeleted] = 1,
		[DeletedBy] = @USER
		WHERE IIC = @ID
	END
	ELSE IF @TYPE = 'Activity'
	BEGIN
		UPDATE [SIS_Activity].[dbo].[SystemDetails]
		SET [IsDeleted] = 1,
		[DeletedBy] = @USER
		WHERE AIC = @ID
	END
	ELSE
	BEGIN
		UPDATE [SIS_Organization].[dbo].[SystemDetails]
		SET [IsDeleted] = 1,
		[DeletedBy] = @USER
		WHERE OIC = @ID
	END

END
GO
