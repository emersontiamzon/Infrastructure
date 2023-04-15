---if not Exist Database Create
IF DB_ID('BSNAnonymize') IS NULL
BEGIN
	CREATE DATABASE [BSNAnonymize]
END
GO

USE [BSNAnonymize]
GO

IF EXISTS (
		SELECT name
		FROM [BSNAnonymize].sys.objects
		WHERE name = 'fnAnonSofi'
		)
	DROP FUNCTION [dbo].[fnAnonSofi]
GO

CREATE FUNCTION [dbo].[fnAnonSofi] (@vid INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @aret VARCHAR(20)
	DECLARE @sofi1 VARCHAR(20)
	DECLARE @sofi2 VARCHAR(20)

	SET @sofi1 = '99' + cast(FORMAT(@vid, '000000') AS VARCHAR(10))

	DECLARE @atemp TABLE (
		id INT
		,sofi VARCHAR(20)
		,val INT
		)
	DECLARE @cnt INT

	SET @cnt = 0

	WHILE @cnt <= 9
	BEGIN
		DECLARE @aval INT

		SET @sofi2 = @sofi1 + cast(@cnt AS VARCHAR(10))

		SELECT @aval = dbo.fnIsValidSofi(@sofi2)

		INSERT INTO @atemp (
			id
			,sofi
			,val
			)
		VALUES (
			@cnt
			,@sofi2
			,@aval
			)

		SET @cnt = @cnt + 1
	END

	IF (
			NOT EXISTS (
				SELECT *
				FROM @atemp
				WHERE val = 1
				)
			)
	BEGIN
		SET @sofi1 = '98' + cast(FORMAT(@vid, '000000') AS VARCHAR(10))

		DELETE
		FROM @atemp

		SET @cnt = 0

		WHILE @cnt <= 9
		BEGIN
			DECLARE @aval1 INT

			SET @sofi2 = @sofi1 + cast(@cnt AS VARCHAR(10))

			SELECT @aval1 = dbo.fnIsValidSofi(@sofi2)

			INSERT INTO @atemp (
				id
				,sofi
				,val
				)
			VALUES (
				@cnt
				,@sofi2
				,@aval1
				)

			SET @cnt = @cnt + 1
		END
	END

	SELECT @aret = sofi
	FROM @atemp
	WHERE val = 1

	RETURN @aret
END
GO

IF EXISTS (
		SELECT name
		FROM [BSNAnonymize].sys.objects
		WHERE name = 'fnIsValidSofi'
		)
	DROP FUNCTION [dbo].[fnIsValidSofi]
GO

CREATE FUNCTION [dbo].[fnIsValidSofi] (@Bank VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @aResult BIT
	DECLARE @avar INT
	DECLARE @bvar INT
	DECLARE @aRes INT
	DECLARE @temptable TABLE (
		id INT identity
		,val INT
		,mult INT
		,prod AS (val * mult)
		)

	SET @aResult = 0
	SET @aRes = 0
	SET @avar = len(@bank)
	SET @bvar = 1

	IF len(@bank) = 9
		WHILE @avar <> 0
		BEGIN
			INSERT INTO @temptable (
				val
				,mult
				)
			VALUES (
				cast(substring(@bank, @bvar, 1) AS INT)
				,@avar
				)

			SET @avar = @avar - 1
			SET @bvar = @bvar + 1
		END

	UPDATE @temptable
	SET mult = - 1
	WHERE id = 9

	SELECT @aRes = sum(prod) % 11
	FROM @temptable

	IF @aRes = 0
		SET @aResult = 1

	RETURN @aResult
END
GO

IF EXISTS (
		SELECT name
		FROM [BSNAnonymize].sys.objects
		WHERE name = 'Split'
		)
	DROP FUNCTION [dbo].[Split]
GO

CREATE FUNCTION [dbo].[Split] (
	@RowData NVARCHAR(max)
	,@SplitOn NVARCHAR(5)
	)
RETURNS @RtnValue TABLE (
	Id INT identity(1, 1)
	,Data NVARCHAR(100)
	)
AS
BEGIN
	DECLARE @Cnt INT

	SET @Cnt = 1

	WHILE (Charindex(@SplitOn, @RowData) > 0)
	BEGIN
		INSERT INTO @RtnValue (data)
		SELECT Data = ltrim(rtrim(Substring(@RowData, 1, Charindex(@SplitOn, @RowData) - 1)))

		SET @RowData = Substring(@RowData, Charindex(@SplitOn, @RowData) + 1, len(@RowData))
		SET @Cnt = @Cnt + 1
	END

	INSERT INTO @RtnValue (data)
	SELECT Data = ltrim(rtrim(@RowData))

	RETURN
END
GO


