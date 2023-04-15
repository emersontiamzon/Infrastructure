DECLARE @dbname VARCHAR(200) = $(sqldbname)

DECLARE @keyFacturatieExactOnlineAdministrationCode VARCHAR(100) = 'FacturatieExactOnlineAdministrationCode'
DECLARE @keyFacturatieExactOnlineApplicationKey VARCHAR(100) = 'FacturatieExactOnlineApplicationKey'
DECLARE @keyFacturatieExactOnlineClientID VARCHAR(100) = 'FacturatieExactOnlineClientID'
DECLARE @keyFacturatieExactOnlineClientSecret VARCHAR(100) = 'FacturatieExactOnlineClientSecret'
DECLARE @keyFacturatieExactOnlineConstantClientAccessToken VARCHAR(100) = 'FacturatieExactOnlineConstantClientAccessToken'
DECLARE @keyFacturatieExactOnlineConstantRefreshToken VARCHAR(100) = 'FacturatieExactOnlineConstantRefreshToken'
DECLARE @keyFacturatieExactOnlineConstantRefreshTokenDate VARCHAR(100) = 'FacturatieExactOnlineConstantRefreshTokenDate'
DECLARE @keyFacturatieExactOnlineGetAdministrationURL VARCHAR(100) = 'FacturatieExactOnlineGetAdministrationURL'
DECLARE @keyFacturatieExactOnlineIsActive VARCHAR(100) = 'FacturatieExactOnlineIsActive'
DECLARE @keyFacturatieExactOnlinePassword VARCHAR(100) = 'FacturatieExactOnlinePassword'
DECLARE @keyFacturatieExactOnlineSessionClientAccessToken VARCHAR(100) = 'FacturatieExactOnlineSessionClientAccessToken'
DECLARE @keyFacturatieExactOnlineSessionClientRefreshToken VARCHAR(100) = 'FacturatieExactOnlineSessionClientRefreshToken'
DECLARE @keyFacturatieExactOnlineSessionIsAuthenticated VARCHAR(100) = 'FacturatieExactOnlineSessionIsAuthenticated'
DECLARE @keyFacturatieExactOnlineSetAdministrationURL VARCHAR(100) = 'FacturatieExactOnlineSetAdministrationURL'
DECLARE @keyFacturatieExactOnlineUploadJournalizationURL VARCHAR(100) = 'FacturatieExactOnlineUploadJournalizationURL'
DECLARE @keyFacturatieExactOnlineURLAuthentication VARCHAR(100) = 'FacturatieExactOnlineURLAuthentication'
DECLARE @keyFacturatieExactOnlineURLToken VARCHAR(100) = 'FacturatieExactOnlineURLToken'
DECLARE @keyFacturatieExactOnlineUsername VARCHAR(100) = 'FacturatieExactOnlineUsername'
--per database
DECLARE @keyFacturatieExactOnlineAdministrationCodeValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineApplicationKeyValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineClientIDValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineClientSecretValue VARCHAR(100) = NULL
--default null
DECLARE @keyFacturatieExactOnlineConstantClientAccessTokenValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineConstantRefreshTokenValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineConstantRefreshTokenDateValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineSessionClientAccessTokenValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineSessionClientRefreshTokenValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineSessionIsAuthenticatedValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineUsernameValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlinePasswordValue VARCHAR(100) = NULL
--static
DECLARE @keyFacturatieExactOnlineGetAdministrationURLValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineIsActiveValue VARCHAR(100) = 'false'
DECLARE @keyFacturatieExactOnlineSetAdministrationURLValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineUploadJournalizationURLValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineURLAuthenticationValue VARCHAR(100) = NULL
DECLARE @keyFacturatieExactOnlineURLTokenValue VARCHAR(100) = NULL
DECLARE @servername VARCHAR(50) = @@servername

IF (@dbname = 'TempActure')
BEGIN
	SET @keyFacturatieExactOnlineAdministrationCodeValue = '2556272'
	SET @keyFacturatieExactOnlineApplicationKeyValue = '{749f6892-fe7d-e911-81f7-b74f466eb4d8}'
	SET @keyFacturatieExactOnlineClientIDValue = '{b6ed232b-5436-4606-83cc-923fae0303d5}'
	SET @keyFacturatieExactOnlineClientSecretValue = '80d6syxKGVPS'
END
ELSE IF (@dbname = 'TempActivasz')
BEGIN
	SET @keyFacturatieExactOnlineAdministrationCodeValue = '2556274'
	SET @keyFacturatieExactOnlineApplicationKeyValue = '{951b46c4-fe7d-e911-81f7-b74f466eb4d8}'
	SET @keyFacturatieExactOnlineClientIDValue = '{a7aa7988-c058-4a19-8140-0b2f794763a9}'
	SET @keyFacturatieExactOnlineClientSecretValue = 'TqXtyD48Nocg'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineAdministrationCode'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineAdministrationCode'
		,@keyFacturatieExactOnlineAdministrationCodeValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineAdministrationCodeValue
	WHERE [key] = 'FacturatieExactOnlineAdministrationCode'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineApplicationKey'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineApplicationKey'
		,@keyFacturatieExactOnlineApplicationKeyValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineApplicationKeyValue
	WHERE [key] = 'FacturatieExactOnlineApplicationKey'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineClientID'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineClientID'
		,@keyFacturatieExactOnlineClientIDValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineClientIDValue
	WHERE [key] = 'FacturatieExactOnlineClientID'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineClientSecret'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineClientSecret'
		,@keyFacturatieExactOnlineClientSecretValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineClientSecretValue
	WHERE [key] = 'FacturatieExactOnlineClientSecret'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineConstantClientAccessToken'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineConstantClientAccessToken'
		,@keyFacturatieExactOnlineConstantClientAccessTokenValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineConstantClientAccessTokenValue
	WHERE [key] = 'FacturatieExactOnlineConstantClientAccessToken'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineConstantRefreshToken'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineConstantRefreshToken'
		,@keyFacturatieExactOnlineConstantRefreshTokenValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineConstantRefreshTokenValue
	WHERE [key] = 'FacturatieExactOnlineConstantRefreshToken'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineConstantRefreshTokenDate'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineConstantRefreshTokenDate'
		,@keyFacturatieExactOnlineConstantRefreshTokenDateValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineConstantRefreshTokenDateValue
	WHERE [key] = 'FacturatieExactOnlineConstantRefreshTokenDate'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineGetAdministrationURL'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineGetAdministrationURL'
		,@keyFacturatieExactOnlineGetAdministrationURLValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineGetAdministrationURLValue
	WHERE [key] = 'FacturatieExactOnlineGetAdministrationURL'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineIsActive'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineIsActive'
		,@keyFacturatieExactOnlineIsActiveValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineIsActiveValue
	WHERE [key] = 'FacturatieExactOnlineIsActive'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlinePassword'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlinePassword'
		,@keyFacturatieExactOnlinePasswordValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlinePasswordValue
	WHERE [key] = 'FacturatieExactOnlinePassword'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineSessionClientAccessToken'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineSessionClientAccessToken'
		,@keyFacturatieExactOnlineSessionClientAccessTokenValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineSessionClientAccessTokenValue
	WHERE [key] = 'FacturatieExactOnlineSessionClientAccessToken'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineSessionClientRefreshToken'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineSessionClientRefreshToken'
		,@keyFacturatieExactOnlineSessionClientRefreshTokenValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineSessionClientRefreshTokenValue
	WHERE [key] = 'FacturatieExactOnlineSessionClientRefreshToken'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineSessionIsAuthenticated'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineSessionIsAuthenticated'
		,@keyFacturatieExactOnlineSessionIsAuthenticatedValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineSessionIsAuthenticatedValue
	WHERE [key] = 'FacturatieExactOnlineSessionIsAuthenticated'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineSetAdministrationURL'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineSetAdministrationURL'
		,@keyFacturatieExactOnlineSetAdministrationURLValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineSetAdministrationURLValue
	WHERE [key] = 'FacturatieExactOnlineSetAdministrationURL'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineUploadJournalizationURL'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineUploadJournalizationURL'
		,@keyFacturatieExactOnlineUploadJournalizationURLValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineUploadJournalizationURLValue
	WHERE [key] = 'FacturatieExactOnlineUploadJournalizationURL'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineURLAuthentication'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineURLAuthentication'
		,@keyFacturatieExactOnlineURLAuthenticationValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineURLAuthenticationValue
	WHERE [key] = 'FacturatieExactOnlineURLAuthentication'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineURLToken'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineURLToken'
		,@keyFacturatieExactOnlineURLTokenValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineURLTokenValue
	WHERE [key] = 'FacturatieExactOnlineURLToken'
END

IF (
		NOT EXISTS (
			SELECT *
			FROM Configuration
			WHERE [Key] = 'FacturatieExactOnlineUsername'
			)
		)
BEGIN
	INSERT INTO [dbo].[Configuration] (
		[Key]
		,[Value]
		)
	VALUES (
		'FacturatieExactOnlineUsername'
		,@keyFacturatieExactOnlineUsernameValue
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Configuration]
	SET [Value] = @keyFacturatieExactOnlineUsernameValue
	WHERE [key] = 'FacturatieExactOnlineUsername'
END