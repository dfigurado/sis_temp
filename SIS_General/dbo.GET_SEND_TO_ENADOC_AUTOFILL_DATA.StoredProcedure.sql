USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_SEND_TO_ENADOC_AUTOFILL_DATA]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SEND_TO_ENADOC_AUTOFILL_DATA](@CASEID BIGINT)
AS
BEGIN
--sfno, casedesk, relatednames
	DECLARE @RELATEDPROFILES TABLE([Name] NVARCHAR(MAX),[Id] BIGINT)
	--DECLARE @CASEID BIGINT = 2
	--select * from [case] where id=10117
	DECLARE @CASEDATA NVARCHAR(MAX) = (SELECT SFNo as sfNo, desk.ID as DeskId, desk.Description as DeskName, subjects.SubjectCode as SubjectCode, subjects.[Description] as SubjectName FROM [CASE] c 
	INNER JOIN Predefined_DeskTarget desk
	ON desk.ID=c.Desk 
	INNER JOIN predefined_subjects subjects
	ON subjects.ID= c.[Subject]
	WHERE c.ID=@CASEID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES )

	SET @CASEDATA = ISNULL(@CASEDATA,'{}')
	--SELECT @CASEDATA

	INSERT INTO @RELATEDPROFILES([Id],[Name])
	--SELECT * FROM
	--(
	--	SELECT 1 AS Id, 'Kamal' AS [Name]
	--	UNION
	--	SELECT 2 AS Id, 'Another' AS [Name]
	--) p
	SELECT pinfo.PIC as Id, ISNULL(REPLACE(RTRIM(LTRIM((ISNULL(pinfo.FirstName,'')+ ' '+ISNULL(pinfo.SecondName,'')+' '+ISNULL(pinfo.Surname,'')))),'  ',' '),'PIC-'+CONVERT(NVARCHAR(MAX),pinfo.PIC)) as Name FROM [CASE] c
	INNER JOIN CasePerson cp
	ON cp.CaseID=c.ID
	INNER JOIN SIS_Person.DBO.PersonInformation pinfo
	ON cp.PIC = pinfo.PIC
	WHERE c.ID = @CASEID

	DECLARE @RELATIONS NVARCHAR(MAX) = (SELECT * FROM @RELATEDPROFILES FOR JSON AUTO)
	--SELECT @RELATIONS
	SELECT '{"relatedPeople":'+ISNULL(@RELATIONS,'[]')+',"caseInfo":'+@CASEDATA+'}'

END
GO
