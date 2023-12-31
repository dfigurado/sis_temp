USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_RELATED_ACTIVITY]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RELATED_ACTIVITY](@CASEID BIGINT)
AS
BEGIN

SELECT OI.*,
(SELECT (SELECT [Description] FROM SIS_General.DBO.Predefined_DeskTarget WHERE ID = S.DeskTarget) FROM SIS_Activity.DBO.SystemDetails S WHERE S.AIC=OI.AIC) AS DeskName 
 FROM [CASE] C
INNER JOIN [CaseActivity] O
ON C.ID = O.CaseID
INNER JOIN SIS_Activity.dbo.ActivityInformation OI
ON  O.AIC=OI.AIC
WHERE C.ID=@CASEID

END
GO
