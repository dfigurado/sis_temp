USE [SIS_General]
GO
/****** Object:  StoredProcedure [dbo].[UPDATE_ENADOC_TOKENS]    Script Date: 08/06/2023 13:06:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UPDATE_ENADOC_TOKENS](@USERID INT,
					@EnadocAccessToken NVARCHAR(MAX),
					@EnadocRefreshToken NVARCHAR(MAX),
					@EnadocExpireTime INT) AS
BEGIN

--DECLARE @USERID INT = 7
--DECLARE @EnadocAccessToken NVARCHAR(MAX) = 'AT2tuyety' 
--DECLARE @EnadocRefreshToken NVARCHAR(MAX) = 'RT2rtuyrtu'
--DECLARE @EnadocExpireTime INT=500
IF EXISTS (SELECT * FROM USERSETTINGS WHERE UserID = @USERID)
	BEGIN
		UPDATE USERSETTINGS SET
			UserID = @USERID,
			EnadocAccessToken = @EnadocAccessToken,
			EnadocRefreshToken = @EnadocRefreshToken,
			EnadocTokenExpireTime = @EnadocExpireTime,
			EnadocTokenRefreshedTime = GETDATE()
		WHERE USERID = @USERID
	END
ELSE
	BEGIN
		INSERT INTO USERSETTINGS(UserID,ISACTIVE,EnadocAccessToken, EnadocRefreshToken, EnadocTokenExpireTime, EnadocTokenRefreshedTime)
		VALUES (@USERID,1,@EnadocAccessToken,@EnadocRefreshToken,@EnadocExpireTime,GETDATE())
	END
END
GO
