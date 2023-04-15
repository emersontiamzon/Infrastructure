IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'vnGenerateRandomAnon'
		)
	DROP VIEW [dbo].[vnGenerateRandomAnon]
GO

CREATE VIEW [dbo].[vnGenerateRandomAnon]
AS
SELECT RAND() Random
GO

IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'fnAnonymizeString'
		)
	DROP FUNCTION [dbo].[fnAnonymizeString]
GO

CREATE FUNCTION [dbo].[fnAnonymizeString] (@string NVARCHAR(max))
RETURNS NVARCHAR(max)
AS
BEGIN
	IF @string IS NULL
		RETURN @string

	DECLARE @newstring NVARCHAR(max)

	SET @newstring = ''

	DECLARE @cnt INT

	SET @cnt = 1

	WHILE @cnt <= len(@string)
	BEGIN
		DECLARE @subs CHAR
		DECLARE @nsubs CHAR

		SET @subs = substring(@string, @cnt, 1)
		SET @nsubs = @subs

		IF (
				(ascii(@subs) BETWEEN 65 AND 90)
				OR (ascii(@subs) BETWEEN 97 AND 122)
				)
		BEGIN
			DECLARE @r INT
			DECLARE @random FLOAT

			SELECT @random = random
			FROM vnGenerateRandomAnon

			IF CHARINDEX(lower(@subs), 'aeiouy') > 0
			BEGIN
				SET @r = FLOOR(@random * (5 - 1 + 1)) + 1;
				SET @nsubs = CHOOSE(@r, 'a', 'e', 'i', 'o', 'u')
			END
			ELSE
			BEGIN
				SET @r = FLOOR(@random * (19 - 1 + 1)) + 1;
				SET @nsubs = CHOOSE(@r, 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'z')
			END

			IF (ascii(@subs) BETWEEN 65 AND 90)
				SET @nsubs = UPPER(@nsubs)
		END

		SET @newstring = @newstring + @nsubs
		SET @cnt = @cnt + 1
	END

	RETURN ltrim(rtrim(@newstring))
END
GO

IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'fnAnonymizeStringAndNo'
		)
	DROP FUNCTION [dbo].[fnAnonymizeStringAndNo]
GO

CREATE FUNCTION [dbo].[fnAnonymizeStringAndNo] (@string NVARCHAR(max))
RETURNS NVARCHAR(max)
AS
BEGIN
	IF @string IS NULL
		RETURN @string

	DECLARE @newstring NVARCHAR(max)

	SET @newstring = ''

	DECLARE @cnt INT

	SET @cnt = 1

	WHILE @cnt <= len(@string)
	BEGIN
		DECLARE @subs CHAR
		DECLARE @nsubs CHAR
		DECLARE @r INT
		DECLARE @random FLOAT

		SET @subs = substring(@string, @cnt, 1)
		SET @nsubs = @subs

		IF (
				(ascii(@subs) BETWEEN 65 AND 90)
				OR (ascii(@subs) BETWEEN 97 AND 122)
				)
		BEGIN
			SELECT @random = random
			FROM vnGenerateRandomAnon

			IF CHARINDEX(lower(@subs), 'aeiouy') > 0
			BEGIN
				SET @r = FLOOR(@random * (5 - 1 + 1)) + 1;
				SET @nsubs = CHOOSE(@r, 'a', 'e', 'i', 'o', 'u')
			END
			ELSE
			BEGIN
				SET @r = FLOOR(@random * (19 - 1 + 1)) + 1;
				SET @nsubs = CHOOSE(@r, 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'z')
			END

			IF (ascii(@subs) BETWEEN 65 AND 90)
				SET @nsubs = UPPER(@nsubs)
		END
		ELSE IF (ascii(@subs) BETWEEN 48 AND 57)
		BEGIN
			SELECT @random = random
			FROM vnGenerateRandomAnon

			SET @r = FLOOR(@random * (10 - 1 + 1)) + 1;
			SET @nsubs = CHOOSE(@r, '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
		END

		SET @newstring = @newstring + @nsubs
		SET @cnt = @cnt + 1
	END

	RETURN ltrim(rtrim(@newstring))
END
GO

IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'fnReplaceString'
		)
	DROP FUNCTION [dbo].[fnReplaceString]
GO

CREATE FUNCTION [dbo].[fnReplaceString] (
	@source VARCHAR(max)
	,@replacewith VARCHAR(max)
	,@separator CHAR
	)
RETURNS VARCHAR(max)
AS
BEGIN
	IF @source IS NULL
		RETURN @source

	IF len(@source) = 0
		RETURN @source

	DECLARE @aret VARCHAR(max) = ''
	DECLARE @cnt INT

	SET @cnt = (len(@source) - len(replace(@source, @separator, ''))) + 1
	SET @aret = replicate(@replacewith + @separator, @cnt)

	RETURN substring(@aret, 1, (len(@aret) - 1))
END
GO

IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'fnIfNotNull'
		)
	DROP FUNCTION [dbo].[fnIfNotNull]
GO

CREATE FUNCTION [dbo].[fnIfNotNull] (
	@field NVARCHAR(max)
	,@value NVARCHAR(max)
	)
RETURNS NVARCHAR(max)
AS
BEGIN
	IF @field IS NULL
		RETURN @field

	RETURN @value
END
GO

IF EXISTS (
		SELECT name
		FROM sys.objects
		WHERE name = 'fnIfNotNullDate'
		)
	DROP FUNCTION [dbo].[fnIfNotNullDate]
GO

CREATE FUNCTION [dbo].[fnIfNotNullDate] (@field DATETIME)
RETURNS NVARCHAR(max)
AS
BEGIN
	IF @field IS NULL
		RETURN @field

	RETURN DATEFROMPARTS(YEAR(@field), MONTH(@field), 1)
END
GO


