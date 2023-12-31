USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[SEARCH]    Script Date: 8/16/2023 10:27:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEARCH](@QUERY NVARCHAR(MAX))
AS
BEGIN

	SELECT top 20 a.* FROM [dbo].[ActivityInformation] a inner join [dbo].[SystemDetails] s on a.AIC=s.AIC
	WHERE s.IsDeleted=0 and 
	(a.[AIC] LIKE @QUERY+'%' OR
	a.[DescriptionOfTheActivity] LIKE @QUERY+'%')

END