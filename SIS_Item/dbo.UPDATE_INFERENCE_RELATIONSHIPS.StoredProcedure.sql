USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]    Script Date: 7/26/2023 4:39:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]
(@fromIC BIGINT, @fromDESCRIPTION NVARCHAR(max))
AS
BEGIN 

	BEGIN TRANSACTION T1

	DELETE FROM SIS_Person.dbo.RelatedItems
	WHERE IsInferred = 1
	AND IIC = @fromIC

	INSERT INTO SIS_Person.dbo.RelatedItems(PIC, IIC, IsInferred, InferredTable)
		SELECT PIC,IIC,1,'SIS_Item.dbo.DetailsOfOwner' FROM SIS_Item.dbo.DetailsOfOwner
		WHERE IIC=@fromIC
		UNION SELECT PIC,IIC,1,'SIS_Item.dbo.RelatedPersons' FROM SIS_Item.dbo.RelatedPersons
		WHERE IIC=@fromIC

	--DELETE FROM SIS_Activity.dbo.ItemsUsed
	--WHERE IsInferred = 1
	--AND IIC=@fromIC

	--INSERT INTO SIS_Activity.dbo.ItemsUsed(AIC,IIC, IsInferred, InferredTable)
	--	SELECT AIC,IIC,1,'SIS_Item.dbo.RelatedActivity' FROM SIS_Item.dbo.RelatedActivity
	--	WHERE IIC=@fromIC

	DELETE FROM SIS_Item.dbo.RelatedItem
	WHERE IsInferred = 1
	AND [RelatedItems(IIC)] = @fromIC

	INSERT INTO SIS_Item.dbo.RelatedItem(IIC, [RelatedItems(IIC)], IsInferred, InferredTable)
		SELECT [RelatedItems(IIC)],IIC,1,'SIS_Item.dbo.RelatedItem' FROM SIS_Item.dbo.RelatedItem
		WHERE IIC=@fromIC

	--RelatedItems
	DELETE FROM SIS_Activity.dbo.ItemsUsed
	WHERE IsInferred = 1
	AND IIC = @fromIC

	INSERT INTO SIS_Activity.dbo.ItemsUsed( AIC,IIC,Description,IsInferred, InferredTable)
	SELECT AIC,IIC,@fromDESCRIPTION,1,'SIS_Item.RelatedActivity' FROM [SIS_Item].[dbo].[RelatedActivity]
	wHERE IIC = @fromIC
	 
	DELETE FROM SIS_Organization.dbo.RelatedItems
	WHERE IsInferred = 1
	AND [IIC] = @fromIC

	INSERT INTO SIS_Organization.dbo.RelatedItems(OIC,IIC,IsInferred, InferredTable)
	SELECT OIC,IIC,1,'SIS_Item.dbo.RelatedOrganizations' FROM SIS_Item.[dbo].[RelatedOrganizations]
	WHERE IIC=@fromIC
	 

	COMMIT TRANSACTION T1
END
