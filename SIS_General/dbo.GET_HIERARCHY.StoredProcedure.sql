USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_HIERARCHY]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_HIERARCHY]
AS
BEGIN
DECLARE @JSON nVARCHAR(MAX)=(
	SELECT DISTINCT div.ID as 'DivisionID',div.[Name],
		ISNULL((SELECT L.ID as 'SubDivisionID', L.Name as 'Name',DeskSubject.Desk AS 'DeskID',
				 (SELECT PD.[Description] FROM [dbo].[Predefined_DeskTarget] PD WHERE PD.ID = DeskSubject.Desk) 'DeskName',Sub.ID AS 'SubjectID',Sub.[Description] AS 'Subjects',Sub.SubjectCode AS 'SubjectCode'
				 FROM [dbo].[Levels] L LEFT OUTER JOIN [dbo].[Hierarchy] DeskSubject
				 ON L.ID = DeskSubject.SubDivisionID
				 LEFT OUTER JOIN [dbo].[Predefined_Subjects] Sub
				 ON DeskSubject.Desk = Sub.DeskTargetID
				 WHERE L.ParentID = div.ID
				 FOR JSON AUTO
		 ),'[]') 'SubDivision'
	FROM [dbo].[Levels] div
	WHERE [Type] = 'Division' 
		ORDER BY div.ID
	FOR JSON AUTO)
SELECT @JSON

END
GO
