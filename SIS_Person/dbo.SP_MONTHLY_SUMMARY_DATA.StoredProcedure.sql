USE [SIS_Person]
GO
/****** Object:  StoredProcedure [dbo].[MonthlySummaryData]    Script Date: 08/06/2023 13:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:    Amaan
-- Create date: 11th of January 2019
-- =============================================
ALTER PROCEDURE [dbo].[MonthlySummaryData](@CurrentYear varchar(4) ,@Month varchar(10))
AS
DECLARE @Command varchar(max);
SET @CurrentYear = DATEPART(yyyy,@CurrentYear)
DECLARE @MonthStatement varchar(250);
SET @MonthStatement = CASE 
	WHEN (@Month = NULL) THEN ''
	WHEN (@Month = 'January')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'February')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-02-01'' AND '''+@CurrentYear+'-03-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'March')		THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-03-01'' AND '''+@CurrentYear+'-04-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'April')		THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-04-01'' AND '''+@CurrentYear+'-05-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'May')		THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-05-01'' AND '''+@CurrentYear+'-06-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'June')		THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-06-01'' AND '''+@CurrentYear+'-07-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'July')		THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-07-01'' AND '''+@CurrentYear+'-08-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'August')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-08-01'' AND '''+@CurrentYear+'-09-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'September')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-09-01'' AND '''+@CurrentYear+'-10-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'October')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-10-01'' AND '''+@CurrentYear+'-11-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'November')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-11-01'' AND '''+@CurrentYear+'-12-01'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	WHEN (@Month = 'December')	THEN 'WHERE [SIS_Person].[dbo].[SystemDetails].[EnteredDate] BETWEEN '''+@CurrentYear+'-12-01'' AND '''+@CurrentYear+'-12-31'' OR [SIS_Person].[dbo].[SystemDetails].[LastModifiedDate] BETWEEN '''+@CurrentYear+'-01-01'' AND '''+@CurrentYear+'-02-01'' '
	END;
BEGIN

	SET @Command = 'SELECT
		[SIS_Person].[dbo].[PersonInformation].[PIC],
		([SIS_Person].[dbo].[PersonInformation].[FirstName] + [SIS_Person].[dbo].[PersonInformation].[Surname]) AS ''Full Name'',
		[SIS_Person].[dbo].[CardingDetails].[CardingDate],
		[SIS_Person].[dbo].[SecurityClassifications].[SecurityClassification],
	  	[SIS_Person].[dbo].[SecurityClassifications].[DateFrom],
	  	[SIS_Person].[dbo].[SecurityClassifications].[DateTo],
	  	[SIS_Person].[dbo].[Nationality].[Nation],
      	[SIS_Person].[dbo].[PersonInformation].[Sex],
      	[SIS_Person].[dbo].[AllTravelParticulars].[ArrivalDate],
      	[SIS_Person].[dbo].[AllTravelParticulars].[PurposeOfVisit],
      	[SIS_Person].[dbo].[CardingDetails].[Reason] AS ''Reason For Carding Connected File'',
      	[SIS_Person].[dbo].[NarrativeInformation].[Information]

	FROM
		[SIS_Person].[dbo].[SystemDetails] 
	  	LEFT OUTER JOIN [SIS_Person].[dbo].[SecurityClassifications]	ON [SIS_Person].[dbo].[SecurityClassifications].[PIC] = [SIS_Person].[dbo].[SystemDetails].[PIC]
     	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_DeskTarget]	ON [SIS_Person].[dbo].[SystemDetails].[Desk] = [SIS_General].[dbo].[Predefined_DeskTarget].[ID]
      	LEFT OUTER JOIN [SIS_General].[dbo].[Predefined_Subjects]     ON [SIS_Person].[dbo].[SystemDetails].[Subject] = [SIS_General].[dbo].[Predefined_Subjects].[ID]
      	LEFT OUTER JOIN [SIS_Person].[dbo].[CardingDetails]           ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[CardingDetails].[PIC]
      	LEFT OUTER JOIN [SIS_Person].[dbo].[Addresses]                ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[Addresses].[PIC]
      	LEFT OUTER JOIN [SIS_Person].[dbo].[AllTravelParticulars]     ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[AllTravelParticulars].[PIC]
      	LEFT OUTER JOIN [SIS_Person].[dbo].[Nationality]              ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[Nationality].[PIC]
      	LEFT OUTER JOIN [SIS_Person].[dbo].[NarrativeInformation]     ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[NarrativeInformation].[PIC]
	  	LEFT OUTER JOIN [SIS_Person].[dbo].[PersonInformation]		ON [SIS_Person].[dbo].[SystemDetails].[PIC] = [SIS_Person].[dbo].[PersonInformation].[PIC]
	'+@MonthStatement+''

PRINT @Command
EXEC  (@Command)
	
END
GO
