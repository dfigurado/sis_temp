USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PROFILE_ACCESSIBILITY_BACKUP]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_PROFILE_ACCESSIBILITY_BACKUP](@UserId BIGINT, @ProfileType NVARCHAR(MAX), @ProfileId BIGINT, @Action NVARCHAR(MAX), @DeskId NVARCHAR(Max))
AS
BEGIN
	DECLARE @Result NVARCHAR(MAX)
	--DECLARE @DeskId NVARCHAR(Max)
	--DOCUMENT ADD CHECK--
	IF(@Action = 'Add')
	BEGIN
		IF (SELECT COUNT(*)
				FROM SIS_General.dbo.DeskUserPermissionsSummary dup WITH(nolock)
				WHERE dup.DeskID = @DeskId
				AND dup.UserID = @UserId
				AND dup.[Add] = 1
		   ) > 0
		BEGIN
			SELECT 'True' AS 'Access'
			print 'can add'
			RETURN;
		END
		ELSE
		BEGIN
			SELECT 'True' AS 'Access'
			print 'cnt add'
			RETURN;
		END
	END

	--DOCUMENT DELETED CHECK
	IF(@ProfileType = 'person')
	BEGIN
		SELECT @Result = IIF(COUNT(*) = 0 , 'False' , 
				Max(IIF(x.IsDeleted = 1,'False','True')))				
		FROM (	
				SELECT *
				FROM SIS_Person.dbo.SystemDetails
				WHERE PIC = @ProfileId
			)x		
	END
	ELSE IF(@ProfileType = 'activity')
	BEGIN
		SELECT @Result = IIF(COUNT(*) = 0, 'False',
				Max(IIF(x.[IsDeleted] = 1,'False','True')))
		FROM (	SELECT * 
				FROM SIS_Activity.dbo.SystemDetails
				WHERE AIC = @ProfileId
			)x	
	END
	ELSE IF(@ProfileType = 'organization')
	BEGIN
		SELECT @Result = IIF(COUNT(*) = 0, 'False',
				Max(IIF(x.[IsDeleted] = 1,'False','True')))
		FROM (	SELECT * 
				FROM SIS_Organization.dbo.SystemDetails
				WHERE OIC = @ProfileId
			)x	
	END
	ELSE IF(@ProfileType = 'item')
	BEGIN
		SELECT @Result = IIF(COUNT(*) = 0, 'False',
				Max(IIF(x.[IsDeleted] = 1,'False','True')))
		FROM (	SELECT * 
				FROM SIS_Item.dbo.SystemDetails
				WHERE IIC = @ProfileId
			)x	
	END

	IF (@Result = 'False')
		BEGIN
			SELECT 'Deleted' AS 'Access'
			print 'deleted'
			RETURN;
		END
		


	IF (@Result = 'True')
	BEGIN
		SELECT @Result AS 'Access'
		print '3'
		RETURN;
	END	
	ELSE
	BEGIN
		--OWN PROFILE RESTRICTION ACCESS CHECK
		IF (SELECT COUNT(*)
			  FROM SIS_General.dbo.SystemUserRestrictedProfiles rp WITH(nolock)
			 WHERE rp.ProfileType = @ProfileType
			   AND rp.ProfileID = @ProfileId
			   AND rp.UserID = @UserId
		   ) > 0
		BEGIN
		   SELECT 'False' AS 'Access'
		   print '1'
		   RETURN;
		END

		--HIERARCHY RESTRICTION ACCESS CHECK
		SELECT @Result = IIF(
			(SELECT Max(IIF(x.[Level] = 'SIS',4,
				  IIF(x.[Level] = 'Division',3,
					IIF(x.[Level] = 'Sub Division',2,
					  IIF(x.[Level] = 'Desk',1,0
						 ) 
					   ) 
					 )
				  ))
				FROM(SELECT DISTINCT pr.[Level]
					FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
						INNER JOIN SIS_General.dbo.PermissionRelations pr
						ON pr.UserGroupID = gu.UserGroupID	   
					WHERE gu.UserID = @UserId
					)x
				) >= (
			  SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
				  IIF(x.[Level] = 'Division',3,
					IIF(x.[Level] = 'Sub Division',2,
					  IIF(x.[Level] = 'Desk',1,0
						 ) 
					   ) 
					 )
				  )),0)
				FROM(SELECT DISTINCT pr.[Level]
					FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
						INNER JOIN SIS_General.dbo.PermissionRelations pr
						ON pr.UserGroupID = gu.UserGroupID	
						INNER JOIN SIS_General.dbo.SystemUserRestrictedProfiles rp
						ON gu.UserID = rp.UserID
					WHERE rp.ProfileID = @ProfileId
			  )x
			),'True','False')

		IF (@Result = 'False')
		BEGIN
			SELECT @Result AS 'Access'
			print '2'
			RETURN;
		END

		--DIRECTOR & DESK OFFICE ACCESS CHECK
		IF(@ProfileType = 'person')
		BEGIN
			IF EXISTS (SELECT * FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE PIC = @ProfileId AND DirectorOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
							WHERE gu.UserID = @UserID
							)x
						) != 4 ,'False','True')
						FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE PIC = @ProfileId AND DirectorOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					print '1dsdasd'
					RETURN;
				END
			END
			ELSE IF EXISTS (SELECT * FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions 
							 WHERE PIC = @ProfileId AND DeskOfficerOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
								INNER JOIN SIS_General.dbo.UserGroupPermissions ugp
								ON gu.UserGroupID = ugp.UserGroupID
							WHERE gu.UserID = @UserID AND ugp.IsDeskOfficer = 1

							--UNION ALL 

							--SELECT DISTINCT pr.[Level]
							--FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
							--	INNER JOIN SIS_General.dbo.PermissionRelations pr
							--	ON pr.UserGroupID = gu.UserGroupID 	   
							--WHERE gu.UserID = @UserID
							)x
						) NOT IN (1,4) ,'False','True')
						FROM SIS_Person.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE PIC = @ProfileId AND DeskOfficerOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
		END
		ELSE IF(@ProfileType = 'activity')
		BEGIN
			IF EXISTS (SELECT * FROM SIS_Activity.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE AIC = @ProfileId AND DirectorOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
							WHERE gu.UserID = @UserID
							)x
						) != 4 ,'False','True')
						FROM SIS_Activity.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE AIC = @ProfileId AND DirectorOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
			ELSE IF EXISTS (SELECT * FROM SIS_Activity.dbo.DirectAndRoleWiseAccessRestrictions 
							 WHERE AIC = @ProfileId AND DeskOfficerOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
								INNER JOIN SIS_General.dbo.UserGroupPermissions ugp
								ON gu.UserGroupID = ugp.UserGroupID
							WHERE gu.UserID = @UserID AND ugp.IsDeskOfficer = 1

							--UNION ALL 

							--SELECT DISTINCT pr.[Level]
							--FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
							--	INNER JOIN SIS_General.dbo.PermissionRelations pr
							--	ON pr.UserGroupID = gu.UserGroupID 	   
							--WHERE gu.UserID = @UserID
							)x
							) NOT IN (1,4) ,'False','True')
						FROM SIS_Activity.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE AIC = @ProfileId AND DeskOfficerOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
		END
		ELSE IF(@ProfileType = 'organization')
		BEGIN
			IF EXISTS (SELECT * FROM SIS_Organization.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE OIC = @ProfileId AND DirectorOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
							WHERE gu.UserID = @UserID
							)x
						) != 4 ,'False','True')
						FROM SIS_Organization.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE OIC = @ProfileId AND DirectorOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
			ELSE IF EXISTS (SELECT * FROM SIS_Organization.dbo.DirectAndRoleWiseAccessRestrictions 
							 WHERE OIC = @ProfileId AND DeskOfficerOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
								INNER JOIN SIS_General.dbo.UserGroupPermissions ugp
								ON gu.UserGroupID = ugp.UserGroupID
							WHERE gu.UserID = @UserID AND ugp.IsDeskOfficer = 1

							--UNION ALL 

							--SELECT DISTINCT pr.[Level]
							--FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
							--	INNER JOIN SIS_General.dbo.PermissionRelations pr
							--	ON pr.UserGroupID = gu.UserGroupID 	   
							--WHERE gu.UserID = @UserID
							)x
							) NOT IN (1,4) ,'False','True')
						FROM SIS_Organization.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE OIC = @ProfileId AND DeskOfficerOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
		END
		ELSE IF(@ProfileType = 'item')
		BEGIN
			IF EXISTS (SELECT * FROM SIS_Item.dbo.DirectAndRoleWiseAccessRestrictions			 
						WHERE IIC = @ProfileId AND DirectorOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
							WHERE gu.UserID = @UserID
							)x
						) != 4 ,'False','True')
						FROM SIS_Item.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE IIC = @ProfileId AND DirectorOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
			ELSE IF EXISTS (SELECT * FROM SIS_Item.dbo.DirectAndRoleWiseAccessRestrictions 
							 WHERE IIC = @ProfileId AND DeskOfficerOnly = 1)
			BEGIN
				SELECT @Result = IIF(COUNT(*) > 0 AND (SELECT IIF(COUNT(x.[Level]) > 0, Max(IIF(x.[Level] = 'SIS',4,
						  IIF(x.[Level] = 'Division',3,
							IIF(x.[Level] = 'Sub Division',2,
							  IIF(x.[Level] = 'Desk',1,0
								 ) 
							   ) 
							 )
						  )),0)
						FROM(SELECT DISTINCT pr.[Level]
							FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
								INNER JOIN SIS_General.dbo.PermissionRelations pr
								ON pr.UserGroupID = gu.UserGroupID 	   
								INNER JOIN SIS_General.dbo.UserGroupPermissions ugp
								ON gu.UserGroupID = ugp.UserGroupID
							WHERE gu.UserID = @UserID AND ugp.IsDeskOfficer = 1

							--UNION ALL 

							--SELECT DISTINCT pr.[Level]
							--FROM SIS_General.dbo.vw_EnadocUserGroupUser gu
							--	INNER JOIN SIS_General.dbo.PermissionRelations pr
							--	ON pr.UserGroupID = gu.UserGroupID 	   
							--WHERE gu.UserID = @UserID
							)x
							) NOT IN (1,4) ,'False','True')
						FROM SIS_Item.dbo.DirectAndRoleWiseAccessRestrictions			
						WHERE IIC = @ProfileId AND DeskOfficerOnly = 1
	
				IF (@Result = 'False')
				BEGIN
					SELECT @Result AS 'Access'
					RETURN;
				END
			END
		END		

		--DESK USER PERMISSION ACCESS CHECK	
		IF(@ProfileType = 'activity')
		BEGIN

			SELECT @Result = IIF(COUNT(*) > 0,'True','False')
			  FROM(SELECT [View],[Print],Download,Email,[Add],Edit,[Delete] 
					 FROM (SELECT *
							 FROM SIS_General.dbo.DeskUserPermissionsSummary WITH(nolock)
							WHERE UserID = @UserId
						  )dp
				  INNER JOIN (SELECT DeskTarget
								FROM SIS_Activity.dbo.SystemDetails WITH(nolock)
							   WHERE AIC = @ProfileId
							 )sd 
						ON sd.DeskTarget = dp.DeskID
				  )q
			UNPIVOT (Granted FOR Access IN ([View],[Print],Download,Email,[Add],Edit,[Delete])) as v
			 WHERE Access = @Action
			   AND Granted = 1

		END
		ELSE IF(@ProfileType = 'person')
		BEGIN

			SELECT @Result = IIF(COUNT(*) > 0,'True','False')
			  FROM(SELECT [View],[Print],Download,Email,[Add],Edit,[Delete] 
					 FROM (SELECT *
							 FROM SIS_General.dbo.DeskUserPermissionsSummary WITH(nolock)
							WHERE UserID = @UserId
						  )dp
				  INNER JOIN (SELECT Desk
								FROM SIS_Person.dbo.SystemDetails WITH(nolock)
							   WHERE PIC = @ProfileId
							 )sd 
						ON sd.Desk = dp.DeskID
				  )q
			UNPIVOT (Granted FOR Access IN ([View],[Print],Download,Email,[Add],Edit,[Delete])) as v
			 WHERE Access = @Action
			   AND Granted = 1

		END
		ELSE IF(@ProfileType = 'item')
		BEGIN

			SELECT @Result = IIF(COUNT(*) > 0,'True','False')
			  FROM(SELECT [View],[Print],Download,Email,[Add],Edit,[Delete] 
					 FROM (SELECT *
							 FROM SIS_General.dbo.DeskUserPermissionsSummary WITH(nolock)
							WHERE UserID = @UserId
						  )dp
				  INNER JOIN (SELECT DeskTarget
								FROM SIS_Item.dbo.SystemDetails WITH(nolock)
							   WHERE IIC = @ProfileId
							 )sd 
						ON sd.DeskTarget = dp.DeskID
				  )q
			UNPIVOT (Granted FOR Access IN ([View],[Print],Download,Email,[Add],Edit,[Delete])) as v
			 WHERE Access = @Action
			   AND Granted = 1

		END
		ELSE IF(@ProfileType = 'organization')
		BEGIN

			SELECT @Result = IIF(COUNT(*) > 0,'True','False')
			  FROM(SELECT [View],[Print],Download,Email,[Add],Edit,[Delete] 
					 FROM (SELECT *
							 FROM SIS_General.dbo.DeskUserPermissionsSummary WITH(nolock)
							WHERE UserID = @UserId
						  )dp
				  INNER JOIN (SELECT DeskTarget
								FROM SIS_Organization.dbo.SystemDetails WITH(nolock)
							   WHERE OIC = @ProfileId
							 )sd 
						ON sd.DeskTarget = dp.DeskID
				  )q
			UNPIVOT (Granted FOR Access IN ([View],[Print],Download,Email,[Add],Edit,[Delete])) as v
			 WHERE Access = @Action
			   AND Granted = 1

		END
				
		SELECT @Result AS 'Access'
		print '4'
		RETURN;

	END


--WORKFLOW ACCESS CHECK
	IF(@Result = 'False')
	BEGIN
			
		SELECT @Result = IIF(COUNT(*) > 0,'True','False')
		  FROM (SELECT [View],[Print],Download,Email,[Add],Edit,[Delete] 
				  FROM WorkFlowPermissions wp WITH(nolock)
				 WHERE wp.UserID = @UserId
				   AND wp.ProfileType = @ProfileType
				   AND wp.ProfileID = @ProfileId
				   AND wp.EndTime > GETDATE()
			   ) p
		UNPIVOT (Granted FOR Access IN ([View],[Print],Download,Email,[Add],Edit,[Delete])) as v
		 WHERE Access = @Action
		   AND Granted = 1
	END

	SELECT @Result AS 'Access'
	RETURN;


END


GO
