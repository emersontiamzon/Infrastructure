DECLARE @tenant VARCHAR(200) = $(tenant)
DECLARE @environment VARCHAR(200) = $(environment)
DECLARE @documentservername VARCHAR(200) = $(documentservername)

UPDATE Gebruiker
SET [Gebruiker_Wachtwoord] = 'XXWTNs0IaWLo85UKGa+Hx7lS1Y0ag47x6lZ3IjOmc9xAAUbDoQ+aUtOO+NPxSSF764Cojwg0XK3n2Ro9w13hyfSBD7g=' --MV4Bs1wnoV222ov1i59dzA5Q3jfA
where [Gebruiker_ID] in (select Gebruiker_ID from Gebruikers_Rol where [Rol_ID] = 32) 


UPDATE Gebruiker
SET [Gebruiker_Actief_datum_from] = '2010-07-04 00:00:00.000'

UPDATE Gebruiker
SET [Gebruiker_Actief_datum_to] = '2030-01-01 23:59:00.000'

UPDATE [Gebruiker_Tijdschema]
SET [Tijdvenster_Start] = '00:00:00.0000000'

UPDATE [Gebruiker_Tijdschema]
SET [Tijdvenster_Einde] = '23:59:00.0000000'

UPDATE Configuration
SET value = 'info@klout7.nl'
WHERE [key] = 'EmailAdressForBankAccountInReflex'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Art3031WeekCorrectieMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Dagloon_WebForm_FromAddress'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DailyWageRequestUVWMailAddress'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DigipoortEmailRecepient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DigipoortEmailRecepientBCC'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DigipoortEmailRecepientCC'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DigipoortEmailSender'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'EmailAdressForBankAccountInReflex'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'ErrorLogLoonheffingEmailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'InvalidIbanEmail'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Invoice_EndAutoincassoMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Invoice_EndFacturatieMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Invoice_EndJournalizationMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'LoonsombeheerEmailCC'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'MaatregelWeekCorrectieMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'MaatregelWeekCorrectieMailRecipientFinance'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'MaatregelWeekCorrectieMailRecipientProcess'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'ReiskostenCorrectieMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'SickleaveWebFormMailAddress'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'USG_DigiZSMReflexNotificationMailTo'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'VoorschotCorrectieMailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'WeekbriefjeFailureReportEmailAddress'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'WeekbriefjeZW_Excel_Recepient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'WGA_Contract_PreWGAEmailCC'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'WGA_Contract_PreWGAEmailFrom'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'XMLUBIFileUploadMailTo'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'LogNotifMailFrom'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'LogNotifMailTo'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Daily_Health_Email_Recipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Daily_Runs_Email_Recipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'SchedulePayslip_MailSender'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'ScheduledScriptsEmailRecepient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'ScheduledScriptsEmailSender'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'SchedulePayslip_MailRecipient'

UPDATE Configuration
SET value = 'prechartklout7@gmail.com'
WHERE [key] = 'Invoice_EndDocumentUploadMailRecipient'

UPDATE Verlonings_Run
SET Verlonings_Run_Validatie_bestand = NULL
	,Verlonings_Run_Specificaties_bestand = NULL
	,Verlonings_Run_Journaalbestand = NULL
	,Verlonings_Run_Betalings_Bestand = NULL

UPDATE Klant_Factuur
SET FactuurZW_Koppeling = NULL

UPDATE InvoiceRun
SET InvoiceRun_Incassobestand_B2B = NULL
	,InvoiceRun_Incassobestand_CORE = NULL
	,InvoiceRun_Journaalbestand = NULL
	,InvoiceRun_Postbestand = NULL
	,InvoiceRun_Factuurbestand = NULL

UPDATE Exact_Document_Upload_Log
SET EDU_Log_Filepath = NULL

UPDATE Digipoort_Tax_Filed_Run_Nummer
SET Tax_Filed_Run_Paymentbestand = ''

IF (
		@environment = 'Acceptance'
		AND @tenant = 'Acture'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'accacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAB/lj7QJIENdJugled4KEMLu3NbZqjnkCyCNVAU08HEs'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Yaz58525

	UPDATE Configuration
	SET value = 'accacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://acture-acc.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://acture-acc.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://acture-hotfix.klout7.nl/', 'https://acture-acc.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acture-hotfix.klout7.nl/', 'https://acture-acc.klout7.nl/')
END
ELSE IF (
		@environment = 'Acceptance'
		AND @tenant = 'Activasz'
		)
BEGIN

	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'accacturebedrijven@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAACE3wWkyXUrosOXvmSmnYeCK9erS4TVm9vKIYjZbu7KX'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Law33979

	UPDATE Configuration
	SET value = 'accacturebedrijven@klout7.nl'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://activasz-acc.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://activasz-acc.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-acc.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-acc.klout7.nl/')
END
ELSE IF (
		@environment = 'Test'
		AND @tenant = 'Acture'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'stagingacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAITOAfJxoXt2T/kHH8XA5Z0lrLgDJtqHDRX+1gLglwsT'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Xoy79233

	UPDATE Configuration
	SET value = 'prechartklout7@gmail.com'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://acture-tst.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://acture-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://acture-hotfix.klout7.nl/', 'https://acture-tst.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acture-hotfix.klout7.nl/', 'https://acture-tst.klout7.nl/')
END
ELSE IF (
		@environment = 'Test'
		AND @tenant = 'Activasz'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'stagingactivasz@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAFaIzkSAB/Q7Pk+QpLf44HY/jGC9IFH3hLM9Uez6nMIq'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Mot03361

	UPDATE Configuration
	SET value = 'prechartklout7@gmail.com'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')
END
ELSE IF (
		@environment = 'Hotfix'
		AND @tenant = 'Acture'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	/*Updating Folder Structure to ActureHotFix*/
	UPDATE Configuration
	SET value = Value + 'ActureHotFix'
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) = 4

	UPDATE Configuration
	SET value = replace(Value, 'Verloning', 'VerloningActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%verloning%'

	UPDATE Configuration
	SET value = replace(Value, 'Belastingdienst', 'BelastingdienstActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%Belastingdienst%'

	UPDATE Configuration
	SET value = replace(Value, 'DigiZSM', 'DigiZSMActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%DigiZSM%'

	UPDATE Configuration
	SET value = replace(Value, 'InvoiceRun', 'InvoiceRunActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%InvoiceRun%'

	UPDATE Configuration
	SET value = replace(Value, 'IndexationProcess', 'IndexationProcessActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%IndexationProcess%'

	UPDATE Configuration
	SET value = replace(Value, 'TwoFactorInstruction', 'TwoFactorInstructionActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%TwoFactorInstruction%'

	UPDATE Configuration
	SET value = replace(Value, 'WGAUkoExcel', 'WGAUkoExcelActureHotFix')
	WHERE Value LIKE '%\\%'
		AND lEN(value) - LEN(REPLACE(value, '\', '')) <> 4
		AND Value LIKE '%WGAUkoExcel%'

END
ELSE IF (
		@environment = 'Hotfix'
		AND @tenant = 'Activasz'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'



	/*Updating Folder Structure to ActivaszHotFix*/
	UPDATE configuration
	SET Value = REPLACE(Value, 'Bedrijven', 'BedrijvenHotfix')


END
ELSE IF (
		@environment = 'Development'
		AND @tenant = 'Acture'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'stagingacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAITOAfJxoXt2T/kHH8XA5Z0lrLgDJtqHDRX+1gLglwsT'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Xoy79233

	UPDATE Configuration
	SET value = 'prechartklout7@gmail.com'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://acture-tst.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://acture-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://acture-hotfix.klout7.nl/', 'https://acture-tst.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acture-hotfix.klout7.nl/', 'https://acture-tst.klout7.nl/')
END
ELSE IF (
		@environment = 'Development'
		AND @tenant = 'Activasz'
		)
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = 'stagingactivasz@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAFaIzkSAB/Q7Pk+QpLf44HY/jGC9IFH3hLM9Uez6nMIq'
	WHERE [key] = 'DigiZSMReflexMailPassword' ---Mot03361

	UPDATE Configuration
	SET value = 'prechartklout7@gmail.com'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://activasz-tst.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://activasz-hotfix.klout7.nl/', 'https://activasz-tst.klout7.nl/')
END
ELSE
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'SERVERNAME', @documentservername)
	WHERE value LIKE '%SERVERNAME%'

	UPDATE Configuration
	SET value = ''
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = ''
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = ''
	WHERE [key] = 'DigiZSMReflexMailPassword' --BYHxBp6Ej4I3uNvNgCf2xa2a  

	UPDATE Configuration
	SET value = ''
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET value = 'preprod-dgp2.procesinfrastructuur.nl.crt'
	WHERE [key] = 'Digipoort_ServiceCert'

	UPDATE Configuration
	SET Value = 'https://localhost/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://localhost/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://acture-hotfix.klout7.nl/', 'https://localhost/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acture-hotfix.klout7.nl/', 'https://localhost/')
END

UPDATE Configuration
SET value = 'preprod-dgp2.procesinfrastructuur.nl.crt'
WHERE [key] = 'Digipoort_ServiceCert'

UPDATE Configuration
SET value = 'https://preprod-dgp2.procesinfrastructuur.nl/wus/2.0/aanleverservice/1.2'
WHERE [key] = 'DigipoortTaxFileEndpoint_Address1'

UPDATE Configuration
SET value = 'https://preprod-dgp2.procesinfrastructuur.nl/wus/2.0/statusinformatieservice/1.2'
WHERE [key] = 'DigipoortTaxFileEndpoint_Address2'

UPDATE Configuration
SET value = 'preprod-dgp2.procesinfrastructuur.nl'
WHERE [key] = 'DigipoortTaxFileEndpoint_Identity'

UPDATE Configuration
SET value = 'www_klout7_nl.pfx'
WHERE [key] = 'Digipoort_ClientCert'

UPDATE Configuration
SET value = 'Klout7'
WHERE [key] = 'Digipoort_ClientCert_PassWord'



IF (@tenant = 'Acture')
BEGIN
	UPDATE Configuration
	SET [value] = '00:30:00'
	WHERE [key] = 'NetDaysCalculationStartTime'
END
ELSE
BEGIN
	UPDATE Configuration
	SET [value] = '00:05:00'
	WHERE [key] = 'NetDaysCalculationStartTime'
END