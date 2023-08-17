USE [SIS_Organization]
GO
/****** Object:  StoredProcedure [dbo].[USP_UPDATE_ORGANIZATION_RELATED_PERSONS]    Script Date: 7/14/2023 12:45:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dilrukshan Figurado
-- Create date: 22-06-2023
-- Description:	<Description,,>
-- =============================================
ALTER   PROCEDURE [dbo].[USP_UPDATE_ORGANIZATION_RELATED_PERSONS]
(
	-- Add the parameters for the stored procedure here
	@JSON NVARCHAR(MAX)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TEMP TABLE (
		[ID] BIGINT NULL,
		[OIC] BIGINT NULL,
		[PIC] BIGINT NULL
	)

	INSERT INTO @TEMP 
	SELECT P.*
	FROM OPENJSON(@JSON) WITH (
		_json nvarchar(max) '$' AS JSON
	) AS i
	CROSS APPLY OPENJSON(i._json) WITH (
	    [ID] BIGINT '$.id',
		[OIC] BIGINT '$.oic',
		[PIC] BIGINT '$.relatedPIC'
	) P;

	--merge temp with relatedPerson of orginizationdb
	MERGE [dbo].[RelatedPersons] ORI
	USING @TEMP TEMP
	ON (ORI.[Id] = TEMP.[ID])
	WHEN MATCHED 
		 THEN UPDATE
		 SET
		 ORI.[PIC] = TEMP.[PIC],
		 ORI.[OIC] = TEMP.[OIC]
	WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([OIC],[PIC],[IsInferred],[InferredTable])
		 VALUES(TEMP.[OIC],TEMP.[PIC],1,'SIS_Person.dbo.Organizations')
	WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	THEN DELETE;

  --DELETE THIS ORGANIZATION FROM PERSON.ORGANIZATION
  DELETE FROM [SIS_Person].[dbo].[Organizations]
	WHERE IsInferred=1
	AND OIC=(SELECT TOP 1 [OIC] FROM @TEMP)
    
  --MAKE RELATION WITH PERSON.ORGANIZATION
  INSERT INTO [SIS_Person].[dbo].[Organizations](OIC,PIC,IsInferred,InferredTable)
		SELECT OIC,PIC,1,'SIS_Organization.dbo.RelatedPersons' FROM SIS_Organization.dbo.RelatedPersons
		WHERE OIC=(SELECT TOP 1 [OIC] FROM @TEMP)

 --  MERGE [SIS_Person].[dbo].[Organizations] ORI
	--USING @TEMP TEMP
	--ON (ORI.[OIC] = TEMP.[OIC] AND ORI.PIC=TEMP.PIC )
	--WHEN NOT MATCHED BY TARGET
	--	 THEN INSERT ([OIC],[PIC])
	--	 VALUES(TEMP.[OIC],TEMP.[PIC]);
	----WHEN NOT MATCHED BY SOURCE AND ORI.[OIC] = (SELECT TOP 1 [OIC] FROM @TEMP)
	----THEN DELETE;
	----delete temp data
	DELETE FROM @TEMP;
	
	DELETE FROM @TEMP
END
