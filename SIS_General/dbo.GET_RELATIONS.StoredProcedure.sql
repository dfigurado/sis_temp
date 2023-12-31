USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_RELATIONS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RELATIONS]
AS
BEGIN

	DECLARE @REALTIONS NVARCHAR(MAX)

	SET @REALTIONS = (
	SELECT PR.ID,PR.[View],PR.[Add],PR.[Edit],PR.[Delete],PR.[Print],PR.[Email],PR.[Download],PR.[Level],PR.UserGroupID,
	(SELECT UG.[Name] FROM [dbo].[vw_EnadocUserGroup] UG WHERE UG.ID = PR.UserGroupID) 'UserGroupName',
	JSON_QUERY(CASE
		WHEN PR.[Level] = 'Division' THEN ISNULL(JSON_QUERY((SELECT L.ID,L.[Name] AS 'LevelName' FROM [dbo].[RelationshipLevels] RL INNER JOIN [dbo].[Levels] L ON RL.LevelID = L.ID WHERE RL.RelationshipID = PR.ID AND L.[Type] = 'Division' FOR JSON AUTO)),'[]')
		WHEN PR.[Level] = 'Sub Division' THEN ISNULL(JSON_QUERY((SELECT L.ID,L.[Name] AS 'LevelName' FROM [dbo].[RelationshipLevels] RL INNER JOIN [dbo].[Levels] L ON RL.LevelID = L.ID WHERE RL.RelationshipID = PR.ID AND L.[Type] = 'SubDivision' FOR JSON AUTO)),'[]')
		WHEN PR.[Level] = 'Desk' THEN ISNULL(JSON_QUERY((SELECT D.ID,D.[Description] AS 'LevelName' FROM [dbo].[RelationshipLevels] RL INNER JOIN [dbo].[Predefined_DeskTarget] D ON RL.LevelID = D.ID WHERE RL.RelationshipID = PR.ID FOR JSON AUTO)),'[]')
		ELSE '[{"ID":1,"LevelName":"Access Granted for all Divisions"}]'
	END) AS 'Levels'
	FROM [dbo].[PermissionRelations] PR
	FOR JSON AUTO)

	SELECT @REALTIONS
END
GO
