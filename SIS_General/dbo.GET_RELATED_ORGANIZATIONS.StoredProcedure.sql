USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_RELATED_ORGANIZATIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RELATED_ORGANIZATIONS](@CASEID BIGINT)
AS
BEGIN

SELECT OI.*, 
(SELECT (SELECT [Description] FROM SIS_General.DBO.Predefined_DeskTarget WHERE ID = S.DeskTarget) FROM SIS_Organization.DBO.SystemDetails S WHERE S.OIC=OI.OIC) AS DeskName,
(SELECT aliasname + ', '
FROM  SIS_Organization.dbo.Aliases WHERE OIC = OI.OIC
FOR XML PATH('')) as Aliases

FROM [CASE] C
INNER JOIN [CaseOrganization] O
ON C.ID = O.CaseID
INNER JOIN SIS_Organization.dbo.OrganizationInformation OI
ON  O.OIC=OI.OIC
WHERE C.ID=@CASEID

END
GO
