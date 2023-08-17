USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[testKeyWordSearch]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[testKeyWordSearch](@MIN INT,@MAX INT,@INPUT NVARCHAR(MAX))
AS
BEGIN

SELECT * FROM [dbo].[Keyword_Search]
WHERE ID BETWEEN @MIN AND @MAX
ORDER BY ID ASC

END
GO
