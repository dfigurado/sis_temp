USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_CASES]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_CASES](@USERID BIGINT, @Status NVARCHAR(20))
AS
BEGIN

	
IF EXISTS (SELECT * 
			 FROM vw_EnadocUserGroupUser ugu WITH(nolock)
		   INNER JOIN UserGroupPermissions ugp WITH(nolock) 
				   ON ugu.UserGroupID = ugp.UserGroupID
			WHERE ugu.UserID = @USERID AND ugp.IsRegistryGroup = 1 		   	   
    	  )
BEGIN

	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw', pr.ID, pr.[Level]
	into #PermissionRelation
	  FROM PermissionRelations pr WITH(nolock)
	INNER JOIN vw_EnadocUserGroupUser ugu WITH(nolock)
			ON ugu.UserGroupID = pr.UserGroupID
	INNER JOIN UserGroupPermissions ugp WITH(nolock)
			ON ugp.UserGroupID = pr.UserGroupID		
	 WHERE ugu.UserID = @USERID 
	   AND ugp.IsRegistryGroup = 1


	CREATE TABLE #desk (rw int ,ID int)		
	DECLARE @i int = 1
	WHILE((SELECT MAX(rw) FROM #PermissionRelation) >= @i)
	BEGIN 
	
		DECLARE @PRID int = (SELECT ID FROM #PermissionRelation WHERE rw = @i)
		DECLARE @PRLevel nvarchar(max)	 = (SELECT [Level] FROM #PermissionRelation WHERE rw = @i)
				
		IF (@PRLevel = 'SIS')
		BEGIN

			insert into #desk	
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',ID FROM Predefined_DeskTarget with(nolock)

		END
		ELSE IF(@PRLevel = 'Division')
		BEGIN

			insert into #desk
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy with(nolock) WHERE DivisionID IN (SELECT LevelID FROM [dbo].[RelationshipLevels] WITH(nolock) WHERE RelationshipID = @PRID )

		END
		ELSE IF (@PRLevel = 'Sub Division')
		BEGIN

			insert into #desk	
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw',Desk FROM Hierarchy with(nolock) WHERE SubDivisionID IN (SELECT LevelID FROM [dbo].[RelationshipLevels] WITH(nolock) WHERE RelationshipID = @PRID)

		END
		ELSE IF (@PRLevel = 'Desk')
		BEGIN

			insert into #desk
			SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0))'rw', LevelID FROM [dbo].[RelationshipLevels] WITH(nolock) WHERE RelationshipID = @PRID

		END

	SET @i = @i + 1
	END
	

	SELECT * FROM [dbo].[Case] c WITH(nolock)
	INNER JOIN (SELECT DISTINCT ID FROM #desk)d
	        ON d.ID = c.Desk
	 WHERE [Status] = @Status
	
END
ELSE
	BEGIN		
	
		SELECT TOP(10) * FROM [dbo].[Case] WITH(nolock)
		 WHERE InitiateBy = @UserId AND [Status] <> 'Closed'		

	END
END
GO
