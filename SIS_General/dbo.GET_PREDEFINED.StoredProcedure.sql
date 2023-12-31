USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[GET_PREDEFINED]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_PREDEFINED](@TABLE NVARCHAR(MAX))
AS
BEGIN

--DECLARE @TABLE NVARCHAR(MAX)='PREDEFINED_COURT'

DECLARE @SQLString NVARCHAR(MAX) =  N'SELECT [ID],UPPER([Description]) AS ''Description'' FROM SIS_General.dbo.'+@TABLE+' with(nolock) ORDER BY Description';  

EXECUTE sp_executesql @SQLString

END
GO
