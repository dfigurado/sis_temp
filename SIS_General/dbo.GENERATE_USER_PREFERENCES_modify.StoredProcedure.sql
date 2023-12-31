USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GENERATE_USER_PREFERENCES_modify]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[GENERATE_USER_PREFERENCES_modify](@USERID INT)
AS
BEGIN


IF  EXISTS (SELECT * FROM [SIS_Person].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)
BEGIN

       -- PEOPLE
       INSERT INTO [SIS_Person].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
       VALUES(@USERID,'Initials',1,null,1,'PersonInformation','Initials',null,0),
                 (@USERID,'Nationality',3,'Predefined_Countries',1,'Nationality','Nation',null,0),
				 (@USERID,'Race',1,null,1,'PersonInformation','Race',null,0)
END




IF  EXISTS (SELECT * FROM [SIS_Organization].[dbo].[Advanced_Search_Criteria] WHERE UserID = @USERID)
BEGIN

       -- ORGANIZATION
       INSERT INTO [SIS_Organization].[dbo].[Advanced_Search_Criteria]([UserID], [Caption], [ControllType], [PreDefinedValues_Table], [Priority], [DBTable], [DBColumnName], [AutoCompleteEntity], [IsSelected])
       VALUES(@USERID,'OrganizationAddress',1,null,1,'Addresses','OrganizationAddress',null,0)
END

END
GO
