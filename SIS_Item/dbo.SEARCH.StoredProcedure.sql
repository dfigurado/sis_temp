USE [SIS_Item]
GO
/****** Object:  StoredProcedure [dbo].[SEARCH]    Script Date: 8/16/2023 11:07:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEARCH](@QUERY NVARCHAR(MAX))
AS
BEGIN

	SELECT top 20 i.* FROM [dbo].[ItemInformation] i inner join [dbo].[SystemDetails] s on i.IIC=s.IIC
	WHERE s.IsDeleted=0 and
	(i.[IIC] LIKE @QUERY+'%' OR [DescriptionOfItem] LIKE @QUERY+'%')

END