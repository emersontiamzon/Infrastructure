DECLARE @dbname VARCHAR(200) = $(sqldbname)

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


update Configuration
set [Value] = 'https://acc2.webapi.usgpeople.nl/api/Service/Acture/GetDayWage'
where [Key] = 'USG_RestClientPath'

update Configuration
set [Value] = '0p8.5N?w)SNav629[rhE'
where [Key] = 'USG_MySolDagloonRequest_Password'

update Configuration
set [Value] = '100+USG+People\juli101'
where [Key] = 'USG_MySolDagloonRequest_User'

update Configuration
set [Value] = 'BASIC'
where [Key] = 'USG_RestAPIAuthMethod'


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

UPDATE Digipoort_Tax_Filed_Run_Nummer
SET Tax_Filed_Run_Paymentbestand = ''

IF (@dbname = 'TempActure')
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'klout7productionfiles.file.core.windows.net\document-prod-acture', 'SERVERNAME')
	WHERE value LIKE '%klout7productionfiles.file.core.windows.net%'

	UPDATE Configuration
	SET value = 'prodacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAGhFQ8AXEYwkUZ/knEWNKXAOIMzUM6Q5oHFmX8exH6V1'
	WHERE [key] = 'DigiZSMReflexMailPassword' --Bap70814

	UPDATE Configuration
	SET value = 'prodacture@klout7.nl'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET Value = 'https://acture-hotfix.klout7.nl/SickleaveWageRequestForm?'
	WHERE [Key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://acture-hotfix.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://acture.klout7.nl/', 'https://acture-hotfix.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acture.klout7.nl/', 'https://acture-hotfix.klout7.nl/')
END
ELSE IF (@dbname = 'TempActivasz')
BEGIN
	UPDATE Configuration
	SET value = replace(value, 'klout7productionfiles.file.core.windows.net\document-prod-activasz', 'SERVERNAME')
	WHERE value LIKE '%klout7productionfiles.file.core.windows.net%'

	UPDATE Configuration
	SET value = 'accactivasz@klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailUserName'

	UPDATE Configuration
	SET value = 'Klout7.nl'
	WHERE [key] = 'DigiZSMReflexMailDomain'

	UPDATE Configuration
	SET value = 'EAAAAP0JLqEDOmm0raj5/S4+4STKNQYDi2TaiwNoxOsz5+Nnndu8pdOYwRIaiEj/SGjIhg=='
	WHERE [key] = 'DigiZSMReflexMailPassword' --Aa9pai9waechae5nahgh

	UPDATE Configuration
	SET value = 'accactivasz@klout7.nl'
	WHERE [key] = 'DigiZSMReflexValidationErrorMailAddress'

	UPDATE Configuration
	SET value = 'https://activasz-hotfix.klout7.nl/SickleaveWageRequestForm?'
	WHERE [key] = 'Dagloon_WebForm_Link'

	UPDATE Configuration
	SET Value = 'https://activasz-hotfix.klout7.nl/Poortwachter?'
	WHERE [Key] = 'Poortwachter_Link'

	UPDATE Poortwachter_Link
	SET PoortwachterLink_URL = REPLACE(PoortwachterLink_URL, 'https://activasz.klout7.nl/', 'https://activasz-hotfix.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://activasz.klout7.nl/', 'https://activasz-hotfix.klout7.nl/')

	UPDATE Webformlink
	SET Webformlink_url = REPLACE(Webformlink_url, 'https://acturebedrijven.klout7.nl/', 'https://activasz-hotfix.klout7.nl/')
END
