USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_HIERARCHY2]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_HIERARCHY2]
AS
BEGIN
DECLARE @JSON nVARCHAR(MAX) = (
	SELECT DISTINCT DivisionID,div.[Name],
		 (SELECT DISTINCT d.SubDivisionID,sd.[Name],
					(SELECT DISTINCT h.Desk AS 'DeskID',a.Desk AS 'DeskName',a.SubjectID AS 'SubjectID',a.Subjects AS 'Subject'
					   FROM Hierarchy h WITH(nolock)
					  INNER JOIN (SELECT dt.ID AS 'DeskID',dt.Description AS 'Desk',ps.ID AS 'SubjectID',ps.Description AS 'Subjects'
									FROM Predefined_DeskTarget dt WITH(nolock)
								  INNER JOIN Predefined_Subjects ps WITH(nolock)
										  ON ps.DeskTargetID = dt.ID
								 )a
							  ON a.DeskID = h.Desk
					  WHERE SubDivisionID = d.SubDivisionID
					FOR JSON PATH			
					)'DeskSubject'
			 FROM Hierarchy d WITH(nolock)
			 INNER JOIN (SELECT ID,[Name] FROM Levels WITH(nolock) WHERE [Type] = 'SubDivision')sd
					 ON sd.ID = d.SubDivisionID
			 WHERE DivisionID = h.DivisionID
			FOR JSON PATH
		 )'SubDivision'
	  FROM Hierarchy h WITH(nolock)
	INNER JOIN (SELECT ID,[Name] FROM Levels WITH(nolock) WHERE [Type] = 'Division')div
			ON div.ID = h.DivisionID
	FOR JSON PATH)

SELECT @JSON

END
GO
