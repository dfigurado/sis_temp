USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_CASE]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DELETE_CASE](@ID BIGINT)
AS
BEGIN

--DECLARE @ID INT = 112

DELETE FROM [CaseItem] WHERE CaseID=@ID
DELETE FROM [CaseActivity] WHERE CaseID=@ID
DELETE FROM [CaseOrganization] WHERE CaseID=@ID
DELETE FROM [CasePerson] WHERE CaseID=@ID
DELETE FROM [CASE] WHERE ID=@ID 

END
GO
