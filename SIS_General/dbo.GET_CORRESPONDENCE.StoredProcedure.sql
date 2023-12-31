USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_CORRESPONDENCE]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_CORRESPONDENCE]
AS
BEGIN

	SELECT	C.ID,
			C.ReferenceNumber,
			PC.[Description] AS CorrespondenceType,
			C.RequestedFrom,
			C.RequestedBy,
			C.Purpose,
			C.RequestedDate,
			C.SubmittedDate,
			C.PreparedBy
		FROM [dbo].[Correspondence] C
	INNER JOIN [dbo].[Predefined_Correspondence] PC
	ON C.CorrespondenceType = PC.ID

END
GO
