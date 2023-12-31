USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[AllProfileTypes_SIS_Report]    Script Date: 08/06/2023 13:06:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Amaan>
-- =============================================
CREATE PROCEDURE [dbo].[AllProfileTypes_SIS_Report] AS
BEGIN
DECLARE @profileTypeIIC char(10); 
DECLARE @profileTypeAIC char(10);
DECLARE @profileTypeOIC char(10);
DECLARE @profileTypePIC char(10); 

SET @profileTypeIIC = 'IIC';
SET @profileTypeAIC = 'AIC';
SET @profileTypeOIC = 'OIC';
SET @profileTypePIC = 'PIC';

SELECT 
	[IIC] AS 'Identification Code', 
	@profileTypeIIC AS 'Profile Type',
	[EnteredUserName],
    [EnteredDate],
    [DeskTarget],
	[SIS_General].[dbo].[Predefined_DeskTarget].[Description],
    [Subject],
	[SIS_General].[dbo].[Predefined_Subjects].[SubjectCode]
FROM 
	[SIS_Item].[dbo].[SystemDetails] 
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] ON [SIS_Item].[dbo].[SystemDetails].[DeskTarget] = [SIS_General].[dbo].[Predefined_DeskTarget].ID
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects] ON [SIS_Item].[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].ID

UNION ALL 

SELECT 
	[AIC] AS 'Identification Code', 
	@profileTypeAIC AS 'Profile Type',
	[EnteredUserName],
    [EnteredDate],
    [DeskTarget],
	[SIS_General].[dbo].[Predefined_DeskTarget].[Description],
    [Subject],
	[SIS_General].[dbo].[Predefined_Subjects].[SubjectCode]
FROM 
	[SIS_Activity].[dbo].[SystemDetails] 
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] ON [SIS_Activity].[dbo].[SystemDetails].[DeskTarget] = [SIS_General].[dbo].[Predefined_DeskTarget].ID
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects] ON [SIS_Activity].[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].ID

UNION ALL

SELECT 
	[OIC] AS 'Identification Code', 
	@profileTypeOIC AS 'Profile Type',
	[EnteredUserName],
    [EnteredDate],
    [DeskTarget],
	[SIS_General].[dbo].[Predefined_DeskTarget].[Description],
    [Subject],
	[SIS_General].[dbo].[Predefined_Subjects].[SubjectCode]
FROM 
	[SIS_Organization].[dbo].[SystemDetails] 
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] ON [SIS_Organization].[dbo].[SystemDetails].[DeskTarget] = [SIS_General].[dbo].[Predefined_DeskTarget].ID
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects] ON [SIS_Organization].[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].ID

UNION ALL

SELECT 
	[PIC] AS 'Identification Code', 
	@profileTypePIC AS 'Profile Type',
	[EnteredUserName],
    [EnteredDate],
    [Desk],
	[SIS_General].[dbo].[Predefined_DeskTarget].[Description],
    [Subject],
	[SIS_General].[dbo].[Predefined_Subjects].[SubjectCode]
FROM 
	[SIS_Person].[dbo].[SystemDetails] 
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] ON [SIS_Person].[dbo].[SystemDetails].[Desk] = [SIS_General].[dbo].[Predefined_DeskTarget].ID
	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects] ON [SIS_Person].[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].ID
END

GO
