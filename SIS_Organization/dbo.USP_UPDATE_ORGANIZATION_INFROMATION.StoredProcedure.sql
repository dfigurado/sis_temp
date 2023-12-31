USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_INFROMATION]    Script Date: 08/06/2023 13:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_INFROMATION]
	(
		@JSON NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @TEMP TABLE(
		[OIC] [bigint] NULL,
		[TypeOfOrganization] [nvarchar](max) NULL,
		[SubClassificationI] [nvarchar](max) NULL,
		[SubClassificationII] [nvarchar](max) NULL,
		[OrganizationName] [nvarchar](max) NULL,
		[RegistrationNumber] [nvarchar](max) NULL,
		[OrganizationCountry] [nvarchar](max) NULL
	);

	INSERT INTO @TEMP
	SELECT * 
	FROM OPENJSON(@JSON)
	WITH  (
		[OIC] [bigint] '$.oic',
		[TypeOfOrganization] [nvarchar](max)'$.typeOfOrganization',
		[SubClassificationI] [nvarchar](max)'$.subClassificationI',
		[SubClassificationII] [nvarchar](max)'$.subClassificationII',
		[OrganizationName] [nvarchar](max)'$.organizationName',
		[RegistrationNumber] [nvarchar](max) '$.registrationNumber',
		[OrganizationCountry] [nvarchar](max) '$.organizationCountry'
	);

	UPDATE [OrganizationInformation]
	SET
	  TypeOfOrganization = TEMP.TypeOfOrganization,
	  SubClassificationI = TEMP.SubClassificationI,
	  SubClassificationII = TEMP.SubClassificationII,
	  OrganizationName = TEMP.OrganizationName,
	  RegistrationNumber = TEMP.RegistrationNumber,
	  OrganizationCountry = TEMP.OrganizationCountry
	FROM [dbo].[OrganizationInformation] ORI
		 INNER JOIN
	@TEMP TEMP
	ON ORI.[OIC] = TEMP.[OIC]
	WHERE  ORI.[OIC] = TEMP.[OIC]

	DELETE FROM @TEMP
END
GO
