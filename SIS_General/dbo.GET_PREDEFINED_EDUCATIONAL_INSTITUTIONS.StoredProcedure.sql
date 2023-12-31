USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PREDEFINED_EDUCATIONAL_INSTITUTIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[GET_PREDEFINED_EDUCATIONAL_INSTITUTIONS] (@category nVARCHAR(MAX))
AS
BEGIN

	SELECT e.ID,e.Description,Category
	  FROM SIS_General.dbo.Predefined_EducationalInstitutions e WITH(nolock)
	INNER JOIN SIS_General.dbo.Predefined_EducationalInstitutionCategory ec WITH(nolock)
			ON e.EducationalInstitutionCategoryID = ec.ID
	 WHERE Category = @category
	ORDER BY 3,2

END
GO
