USE [SIS_Activity]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]    Script Date: 7/19/2023 12:20:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[UPDATE_INFERENCE_RELATIONSHIPS]
(@fromIC BIGINT)
AS
BEGIN
	-- PERSONS
	-- RECREATING THE RELATIONSHIPS TO ITEMS

	BEGIN TRANSACTION T1

	--DECLARE @fromIC BIGINT = 1

	-- REMOVING THIS ACTIVITY FROM ALL THE ORGANIZATIONS
	DELETE FROM SIS_Organization.DBO.RelatedActivities
	WHERE IsInferred = 1
	AND AIC = @fromIC
	-- INSERTING BACK
	INSERT INTO SIS_Organization.DBO.RelatedActivities(AIC, OIC, ISINFERRED, INFERREDTABLE)
	SELECT AIC, OIC, 1, 'SIS_Activity.dbo.RelatedOrganization' FROM SIS_Activity.DBO.RelatedOrganization
	WHERE AIC=@fromIC

	-- REMOVING ACTIVITIES
	DELETE FROM SIS_Activity.dbo.RelatedActivities
	WHERE IsInferred = 1
	AND [RelatedActivity(AIC)] = @fromIC
	--INSERTING BACK
	INSERT INTO SIS_Activity.dbo.RelatedActivities([RelatedActivity(AIC)],AIC, IsInferred, InferredTable)
	SELECT AIC, [RelatedActivity(AIC)],1,'SIS_Activity.dbo.RelatedActivities' FROM SIS_Activity.dbo.RelatedActivities
	WHERE AIC=@fromIC

	-- REMOVING PERSONS RELATED ACTIVITIES
	DELETE FROM SIS_Person.dbo.RelatedActivities
	WHERE IsInferred=1
	AND AIC=@fromIC
	-- INSERTING BACK
	INSERT INTO SIS_Person.dbo.RelatedActivities(PIC,AIC,IsInferred, InferredTable)
		-- INSERTING DETAILS OF VICTIMS
		SELECT PIC, AIC, 1, 'FROM SIS_Activity.dbo.DetailsOfVictims' FROM SIS_Activity.dbo.DetailsOfVictims
		WHERE AIC = @fromIC
		-- INSERTING DETAILS OF SUSPECTS
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.DetailOfSuspect' FROM SIS_Activity.dbo.DetailOfSuspect
		WHERE AIC=@fromIC
		-- INSERTING DETAILS OF LOCAL CONTACTS
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.DetailsOfLocalContacts' FROM SIS_Activity.dbo.DetailsOfLocalContacts
		WHERE AIC=@fromIC
		-- INSERTING DETAILS OF INSTRUCTORS
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.DetailsOfInstructors' FROM SIS_Activity.dbo.DetailsOfInstructors
		WHERE AIC=@fromIC
		-- INSERTING DETAILS OF PRESIDED OVER BY
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.PresidedOverBy' FROM SIS_Activity.dbo.PresidedOverBy
		WHERE AIC=@fromIC
		-- INSERTING DETAILS OF MainSpeakers
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.MainSpeakers' FROM SIS_Activity.dbo.MainSpeakers
		WHERE AIC=@fromIC
		-- INSERTING DETAILS OF MainSpeakers
		UNION SELECT PIC,AIC,1,'SIS_Activity.dbo.ActiveOrganizers' FROM SIS_Activity.dbo.ActiveOrganizers
		WHERE AIC=@fromIC

	-- REMOVING ITEMS ON RELATED ITEMS
	DELETE FROM SIS_Item.dbo.RelatedActivity
	WHERE IsInferred=1
	AND AIC=@fromIC
	-- INSERTING
	INSERT INTO SIS_ITEM.dbo.RelatedActivity(IIC,AIC,Description,IsInferred,InferredTable)
		-- ITEMS USED
		SELECT IIC,AIC,Description,1,'SIS_Activity.dbo.ItemsUsed' FROM SIS_Activity.dbo.ItemsUsed
		WHERE AIC=@fromIC
		-- ITEMS DISMISSED
		UNION SELECT IIC,AIC,Description,1,'SIS_Activity.dbo.ItemsDismiss' FROM SIS_Activity.dbo.ItemsDismiss
		WHERE AIC=@fromIC

	COMMIT TRANSACTION T1
END
