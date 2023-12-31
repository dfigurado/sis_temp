USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GetDocumentIndexPropertiesByCaption]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------


CREATE PROCEDURE [dbo].[GetDocumentIndexPropertiesByCaption] (@caption nVARCHAR(MAX), @Library_ID nVARCHAR(MAX))
AS
BEGIN
	SELECT * FROM [dbo].[DocumentIndexProperty] AS dp WHERE dp.IndexCaption = @caption AND dp.Library_ID = @Library_ID
END
GO
