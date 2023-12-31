USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[SEARCH]    Script Date: 8/16/2023 9:37:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEARCH](@orgName nvarchar(max))
AS
BEGIN
  select top 20 o.OIC, o.OrganizationName from ([OrganizationInformation] o inner join [dbo].[SystemDetails] s on o.OIC=s.OIC)
  where 
     s.IsDeleted=0 and 
    (o.[OrganizationName] like @orgName+'%' or
	 o.[OIC] like @orgName+'%')
end
