USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_RELATED_ITEMS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RELATED_ITEMS](@CASEID BIGINT)
AS
BEGIN

SELECT OI.*,
(SELECT (SELECT [Description] FROM SIS_General.DBO.Predefined_DeskTarget WHERE ID = S.DeskTarget) FROM SIS_Item.DBO.SystemDetails S WHERE S.IIC=OI.IIC) AS DeskName 
 FROM [CASE] C
INNER JOIN [CaseItem] O
ON C.ID = O.CaseID
INNER JOIN SIS_Item.dbo.ItemInformation OI
ON  O.IIC=OI.IIC
WHERE C.ID=@CASEID

END
GO
