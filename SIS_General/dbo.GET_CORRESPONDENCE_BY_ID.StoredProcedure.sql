USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_CORRESPONDENCE_BY_ID]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_CORRESPONDENCE_BY_ID](@ID BIGINT)
AS
BEGIN
DECLARE @JSON NVARCHAR(MAX) =(
	SELECT	C.ID,
			C.ReferenceNumber,
			PC.[Description] AS CorrespondenceType ,
			C.RequestedFrom,
			C.RequestedBy
		FROM [dbo].[Correspondence] C
	INNER JOIN [dbo].[Predefined_Correspondence] PC
	ON C.CorrespondenceType = PC.ID
	WHERE C.ID = @ID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES ) 

	SELECT @JSON

END
GO
