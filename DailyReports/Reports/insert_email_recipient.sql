DECLARE @count_recipient INT
DECLARE @runemailrecipient varchar(500)
DECLARE @healthemailrecipient varchar(500)

SET @runemailrecipient = $(runemailrecipient)
SET @healthemailrecipient = $(healthemailrecipient)
SET @count_recipient = (SELECT COUNT(*) FROM dbo.Configuration WHERE [Key] = 'Daily_Runs_Email_Recipient')

IF (@count_recipient  = 0)
BEGIN
	INSERT INTO Configuration ([Key],Value)
	 VALUES('Daily_Runs_Email_Recipient',@runemailrecipient)

END


SET @count_recipient = (SELECT COUNT(*) FROM dbo.Configuration WHERE [Key] = 'Daily_Health_Email_Recipient')

IF (@count_recipient  = 0)
BEGIN
	INSERT INTO Configuration ([Key],Value)
	 VALUES('Daily_Health_Email_Recipient',@healthemailrecipient)

END




