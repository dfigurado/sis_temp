USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[SEARCH]    Script Date: 8/14/2023 12:48:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[SEARCH](@QUERY NVARCHAR(MAX))
AS
BEGIN

	--SELECT top 20 p.*,IdNumber FROM [dbo].[PersonInformation] p with(nolock)
	--LEFT OUTER JOIN(SELECT TOP 1 * FROM Identification ORDER BY AddedDate DESC)i
	--             ON i.PIC = p.PIC
	----WHERE p.[PIC] LIKE @QUERY+'%' 
	----   OR p.[Surname] LIKE @QUERY+'%' 
	----   OR p.FirstName LIKE @QUERY+'%' 
	----   OR p.SecondName LIKE @QUERY+'%' 
	--WHERE CONCAT(LTRIM(RTRIM(ISNULL(p.[PIC],' '))),LTRIM(RTRIM(ISNULL([Surname],' '))),LTRIM(RTRIM(ISNULL(REPLACE(Initials,' ',''),' '))),LTRIM(RTRIM(ISNULL(FirstName,' '))),LTRIM(RTRIM(ISNULL(SecondName,' '))),LTRIM(RTRIM(ISNULL(IdNumber,' ')))) LIKE REPLACE('%'+@QUERY+'%',' ','')
	--ORDER BY PIC



	SELECT top 20 p.*,'' IdNumber FROM [dbo].[PersonInformation] p with(nolock) INNER JOIN SystemDetails SD ON SD.PIC=p.[PIC]
	WHERE (p.[PIC] LIKE @QUERY+'%' 
	   OR p.[Surname] LIKE @QUERY+'%' 
	   OR p.FirstName LIKE @QUERY+'%' 
	   OR p.SecondName LIKE @QUERY+'%') 
	   AND (SD.IsDeleted=0)
	--WHERE CONCAT(LTRIM(RTRIM(ISNULL(p.[PIC],' '))),LTRIM(RTRIM(ISNULL([Surname],' '))),LTRIM(RTRIM(ISNULL(REPLACE(Initials,' ',''),' '))),LTRIM(RTRIM(ISNULL(FirstName,' '))),LTRIM(RTRIM(ISNULL(SecondName,' ')))) LIKE REPLACE('%'+@QUERY+'%',' ','')
	ORDER BY PIC



END
