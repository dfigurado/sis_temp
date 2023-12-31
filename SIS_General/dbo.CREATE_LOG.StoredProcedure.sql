USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_LOG]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CREATE_LOG] (@eventCategory nVARCHAR(MAX),@eventUser bigint, @machineId nVARCHAR(MAX), @eventData nVARCHAR(MAX))
AS
BEGIN

	SET NOCOUNT ON;

    EXECUTE SIS_Log.[dbo].[CREATE_LOG] @eventCategory,@eventUser,@machineId,@eventData
END
GO
