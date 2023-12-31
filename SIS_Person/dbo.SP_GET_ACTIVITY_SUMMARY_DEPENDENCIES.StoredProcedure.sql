USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[GETActivitySummaryDependencies]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Author
-- Create date: 14th Of January 2019
-- =============================================
ALTER PROCEDURE [dbo].[GETActivitySummaryDependencies]
AS
BEGIN
	SELECT DISTINCT 
		[MajorClassification],
		[MinorClassification],
		[Place],
		[AdministrativeDistrict],
		[Country],
		[PoliceStation]
	FROM 
		[SIS_Activity].[dbo].[ActivityInformation]
	--WHERE DATALENGTH([MajorClassification]) > 0
	--	AND [MajorClassification] <> '' 
END

GO
