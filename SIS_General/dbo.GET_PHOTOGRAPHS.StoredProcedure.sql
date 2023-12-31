USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PHOTOGRAPHS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_PHOTOGRAPHS](@ID INT,@TYPE NVARCHAR(MAX))
AS
BEGIN

IF(@TYPE = 'person')
BEGIN
	SELECT [Path]
	FROM [SIS_Person].[dbo].[Photographs]
	WHERE ID = @ID
END
ELSE IF(@TYPE = 'activity')
BEGIN
	SELECT [Path]
	FROM [SIS_Activity].[dbo].[Photographs]
	WHERE ID = @ID
END
ELSE IF(@TYPE = 'item')
BEGIN
	SELECT [Path]
	FROM [SIS_Item].[dbo].[Photographs]
	WHERE ID = @ID
END
ELSE
BEGIN
	SELECT [Path]
	FROM [SIS_Organization].[dbo].[Photographs]
	WHERE ID = @ID
END

END
GO
