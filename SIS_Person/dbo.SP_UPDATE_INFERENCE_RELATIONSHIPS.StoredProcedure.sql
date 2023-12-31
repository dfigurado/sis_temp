USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]    Script Date: 26/06/2023 10:26:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]
(
	@fromIC BIGINT
)
AS
BEGIN
	-- PERSONS
	-- RECREATING THE RELATIONSHIPS TO ITEMS

	BEGIN TRANSACTION T1

	--DECLARE @fromIC BIGINT = 1
	--DECLARE @toIC BIGINT = 2

	-- REMOVING EXISTING INFERENCES
	DELETE FROM SIS_Person.dbo.[Realtives]
	WHERE IsInferred = 1
	AND RelativesPIC = @fromIC

	-- MAKE RELATIONS
	INSERT INTO SIS_Person.dbo.[Realtives](PIC,RelativesPIC,IsInferred,Relationship,InferredTable,[Name])
	SELECT RelativesPIC, 
		   PIC,
		   1,
		   dbo.fn_GetRelationship(Relationship),
		   'SIS_Person.dbo.[Realtives]' AS InferredTable, 
		   (SELECT ISNULL(Surname,'')+' '+ISNULL(FirstName,'')+' '+ISNULL(SecondName,'') FROM SIS_Person.dbo.PersonInformation WHERE PIC=r.PIC)
	FROM SIS_Person.dbo.[Realtives] r 
	WHERE PIC=@fromIC

	-- REMOVING THIS PERSON FROM ALL THE ITEMS RELATED
	DELETE FROM SIS_Item.DBO.RelatedPersons
	WHERE IsInferred=1
	AND PIC=@fromIC

	-- MAKE RELATIONS FROM CONVEYANCES
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT IIC, PIC, 1, 'SIS_Person.dbo.Conveyances' AS IsInferred FROM SIS_Person.DBO.Conveyances WHERE PIC=@fromIC

	-- MAKE RELATIONS FROM RELATED ITEMS
	INSERT INTO SIS_Item.DBO.RelatedPersons(IIC,PIC,IsInferred, InferredTable)
	SELECT IIC, PIC, 1, 'SIS_Person.dbo.RelatedItems' AS IsInferred FROM SIS_Person.DBO.RelatedItems WHERE PIC=@fromIC

	--REMOVING EXISTING RELATED PERSON IN ORGANIZATION DB
	DELETE FROM [SIS_Organization].[dbo].[RelatedPersons]
	WHERE [IsInferred] =1 
	AND PIC=@fromIC

	--MAKE RELATION FROM RELATED PERSON PERSON IN ORGANIZATION DB
	INSERT INTO [SIS_Organization].[dbo].[RelatedPersons](OIC,PIC,IsInferred,InferredTable)
	SELECT OIC,PIC,1,'SIS_Person.dbo.RelatedOrganization' AS IsInferred FROM SIS_Person.DBO.Organizations WHERE PIC=@fromIC


	COMMIT TRANSACTION T1
END
GO