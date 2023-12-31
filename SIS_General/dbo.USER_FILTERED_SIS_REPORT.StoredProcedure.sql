USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UserFilteredSIS_Report]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UserFilteredSIS_Report](@ProfileTypeCode varchar(5), @UserName varchar(50)) AS
DECLARE @SIS_Table varchar(50), @Command varchar(max), @DeskOrTarget varchar(50)
BEGIN
SET @SIS_Table =	CASE 
						WHEN @ProfileTypeCode LIKE 'IIC' THEN '[SIS_Item]'
						WHEN @ProfileTypeCode LIKE 'OIC' THEN '[SIS_Organization]'  
						WHEN @ProfileTypeCode LIKE 'PIC' THEN '[SIS_Person]' 
						WHEN @ProfileTypeCode LIKE 'AIC' THEN '[SIS_Activity]' 
					END

SET @DeskOrTarget = CASE 
						WHEN @ProfileTypeCode LIKE 'PIC' THEN '[Desk]'
						ELSE '[DeskTarget]'
					END

SET @Command = 'SELECT 
					['+@ProfileTypeCode+'] AS ''Identification Code'', 
					[EnteredUserName], 
					[EnteredDate], 
					[LastModifiedUserName],
					[LastModifiedDate],
					'+@DeskOrTarget+', 
					[SIS_General].[dbo].[Predefined_DeskTarget].[Description],
					[Subject],
					[SIS_General].[dbo].[Predefined_Subjects].[SubjectCode]
				FROM 
					'+@SIS_Table+'.[dbo].[SystemDetails]
					LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget] ON '+@SIS_Table+'.[dbo].[SystemDetails].'+@DeskOrTarget+' = [SIS_General].[dbo].[Predefined_DeskTarget].ID
					LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects] ON '+@SIS_Table+'.[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].ID
					WHERE [EnteredUserName] LIKE '''+@UserName+''' '

END
PRINT @Command
--PRINT @Command
exec (@Command)
GO
