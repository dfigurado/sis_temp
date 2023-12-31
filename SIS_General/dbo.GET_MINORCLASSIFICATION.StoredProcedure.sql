USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_MINORCLASSIFICATION]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_MINORCLASSIFICATION] (@majorDescription nVARCHAR(MAX),@type AS nVARCHAR(MAX))
AS
BEGIN



IF(@type = 'Item')
BEGIN

	SELECT x.ID,x.Description      
	  FROM Predefined_ItemMajorClassification m
    INNER JOIN (SELECT CASE WHEN LEN(ID) = 3 THEN LEFT(ID,1)
							WHEN LEN(ID) = 4 THEN LEFT(ID,2)
							WHEN LEN(ID) = 5 THEN LEFT(ID,3)
					   END AS 'MinorID',
					   ID,
					   Description
				  FROM Predefined_ItemMinorClassification with(nolock)
			   )x ON x.MinorID = m.ID
	 WHERE m.Description = @majorDescription

END
ELSE IF (@type = 'Activity')
BEGIN     
	SELECT x.ID,x.Description       
	  FROM Predefined_ActivityMajorClassification m
    INNER JOIN (SELECT CASE WHEN LEN(ID) = 3 THEN LEFT(ID,1)
							WHEN LEN(ID) = 4 THEN LEFT(ID,2)
							WHEN LEN(ID) = 5 THEN LEFT(ID,3)
					   END AS 'MinorID',
					   ID,
					   Description
				  FROM Predefined_ActivityMinorClassification with(nolock)
			   )x ON x.MinorID = m.ID
	 WHERE m.Description = @majorDescription

END
ELSE IF (@type = 'InstitutionsAffected')
BEGIN
	SELECT x.ID,x.Description     
	  FROM Predefined_InstitutionsAffectedMajor m
    INNER JOIN (SELECT CASE WHEN LEN(ID) = 3 THEN LEFT(ID,1)
							WHEN LEN(ID) = 4 THEN LEFT(ID,2)
							WHEN LEN(ID) = 5 THEN LEFT(ID,3)
					   END AS 'MinorID',
					   ID,
					   Description
				  FROM Predefined_InstitutionsAffectedMinor with(nolock)
			   )x ON x.MinorID = m.ID
	 WHERE m.Description = @majorDescription
END



END
GO
