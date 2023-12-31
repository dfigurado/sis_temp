USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GENERATE_USER_PREFERENCES]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GENERATE_USER_PREFERENCES](@USERID INT)
AS
BEGIN

IF NOT EXISTS (SELECT * FROM [SIS_Person].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)
BEGIN

	-- PEOPLE
	INSERT INTO [SIS_Person].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
	VALUES(@USERID,'PIC',4,null,1,'PersonInformation','PIC','peopleAutoComplete',0),
		  (@USERID,'First Name',1,null,1,'PersonInformation','FirstName',null,0), 
		  (@USERID,'Other Names',1,null,1,'PersonInformation','SecondName',null,0),
		  (@USERID,'Aliases',1,null,1,'Aliases','Alias',null,0),
	      (@USERID,'Surname',4,null,1,'PersonInformation','Surname','surnameAutoComplete',0),
		  (@USERID,'Security Classification',3,'Predefined_SecurityClassification',1,'SecurityClassifications','SecurityClassification',null,0),
          (@USERID,'NIC',1,null,1,'Identification','IdNumber',null,0),
		  (@USERID,'Passport',1,null,1,'Identification','IdNumber',null,0),
		  (@USERID,'Driving License',1,null,1,'Identification','IdNumber',null,0),
		  (@USERID,'Address',1,null,1,'Addresses','Address',null,0),
		  (@USERID,'Occupation',3,'Predefined_Occupations',1,'Occupations','Occupation',null,0),
		  (@USERID,'Date Of Birth',2,null,1,'PersonInformation','DateOfBirth',null,0),
		  (@USERID,'Main Organization',4,null,1,'Organizations','OIC','organizationsAutoComplete',0),
		  (@USERID,'File References',1,null,1,'FileReferences','FileReference',null,0),
		  (@USERID,'Prime Designation',1,null,1,'Organizations','Position',null,0),
		  (@USERID,'Rank',3,'Predefined_Ranks',1,'Occupations','Rank',null,0),
		  (@USERID,'Regimental No',1,null,1,'Occupations','RegimentalNo',null,0),
		  (@USERID,'Initials',1,null,1,'PersonInformation','Initials',null,0),
		  (@USERID,'Race',1,null,1,'PersonInformation','Race',null,0),
		  (@USERID,'Nationality',3,'Predefined_Countries',1,'Nationality','Nation',null,0)

		 

END

IF NOT EXISTS (SELECT * FROM [SIS_Item].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)
BEGIN

	-- ITEM
	INSERT INTO [SIS_Item].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
	VALUES(@USERID,'IIC',4,null,1,'ItemInformation','IIC','itemAutoComplete',0),
		  (@USERID,'Type',3,'Predefined_TypeOfItem',1,'ItemInformation','TypeOfItem',null,0),
          (@USERID,'Major Classification',3,'Predefined_ItemMajorClassification',1,'ItemInformation','SubClassificationI',null,0),
          (@USERID,'Minor Classification',3,'Predefined_ItemMinorClassification',1,'ItemInformation','SubClassificationII',null,0),
          (@USERID,'Main Identifying No',1,null,1,'ItemInformation','MainIdentifyingNumber',null,0),
		  (@USERID,'Other Identifying No',1,null,1,'OtherIdentifyingNumbers','IdentifyingNumber',null,0),
          (@USERID,'Country of Manufacturer',3,'Predefined_Countries',1,'ItemInformation','CountryOfManufacture',null,0),
          (@USERID,'Recovery Place',1,null,1,'DetailsOfRecovery','Place',null,0),
		  (@USERID,'Recovery Date(From)',2,null,1,'DetailsOfRecovery','Date',null,0),
		  (@USERID,'Recovery Date(To)',2,null,1,'DetailsOfRecovery','Date',null,0),
		  (@USERID,'Recovery Police Station',3,'Predefined_PoliceStations',1,'DetailsOfRecovery','PoliceStation',null,0)
END

IF NOT EXISTS (SELECT * FROM [SIS_Organization].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)
BEGIN

	-- ORGANIZATION
	INSERT INTO [SIS_Organization].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
	VALUES(@USERID,'OIC',4,null,1,'OrganizationInformation','OIC','organizationsAutoComplete',0),
		  (@USERID,'Name',1,null,1,'OrganizationInformation','OrganizationName',null,0),
	      (@USERID,'Registration Number',1,null,1,'OrganizationInformation','RegistrationNumber',null,0),
		  (@USERID,'Sub Classification I',3,'Predefined_SubClassification1',1,'OrganizationInformation','SubClassificationI',null,0),
		  (@USERID,'Sub Classification II',3,'Predefined_SubClassification2',1,'OrganizationInformation','SubClassificationII',null,0),
		  (@USERID,'Organization Type',3,'Predefined_TypeOfOrganisation',1,'OrganizationInformation','TypeOfOrganization',null,0),
		  (@USERID,'Aliases',1,null,1,'Aliases','AliasName',null,0),
		  (@USERID,'Address',1,null,1,'Addresses','Address',null,0)
END

IF NOT EXISTS (SELECT * FROM [SIS_Activity].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)

BEGIN
	-- ACTIVITY
	INSERT INTO [SIS_Activity].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
	VALUES(@USERID,'AIC',4,null,1,'ActivityInformation','AIC','activityAutoComplete',0),
		  (@USERID,'Description',1,null,1,'ActivityInformation','DescriptionOfTheActivity',null,0),
	      (@USERID,'Place',1,null,1,'ActivityInformation','Place',null,0),
		  (@USERID,'From Date',5,null,1,'ActivityInformation','StartDateTime',null,0),
		  (@USERID,'To Date',5,null,1,'ActivityInformation','EndDateTime',null,0),
		  (@USERID,'Major Classification',3,'Predefined_ActivityMajorClassification',1,'ActivityInformation','MajorClassification',null,0),
		  (@USERID,'Minor Classification',3,'Predefined_ActivityMinorClassification',1,'ActivityInformation','MinorClassification',null,0),
          (@USERID,'Administrative District',3,'Predefined_District',1,'ActivityInformation','AdministrativeDistrict',null,0),
          (@USERID,'Modus Operandi',3,'Predefined_ModusOperandi',1,'ModusOperandi','ModusOperandi',null,0),
          (@USERID,'Institution Affected - Major',3,'Predefined_InstitutionsAffectedMajor',1,'InstitutionsAffected','MajorType',null,0),
          (@USERID,'Institution Affected - Minor',3,'Predefined_InstitutionsAffectedMinor',1,'InstitutionsAffected','MinorType',null,0),
		  (@USERID,'Police station',3,'Predefined_PoliceStations',1,'ActivityInformation','PoliceStation',null,0)

END

END


--[GENERATE_USER_PREFERENCES] 1
GO
