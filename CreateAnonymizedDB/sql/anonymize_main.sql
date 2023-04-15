DECLARE @dbname VARCHAR(200) = $(sqldbname);

DISABLE TRIGGER [trigVerzekerde]
    ON [Verzekerde];


-- create anonymize table
IF NOT EXISTS (
		SELECT 1
		FROM [BSNAnonymize].sys.tables
		WHERE name = 'verzek_anonym'
		)
	CREATE TABLE [BSNAnonymize].dbo.verzek_anonym (
		dbname NVARCHAR(100)
		,verzekerde_id INT
		,bsn NVARCHAR(10)
		,newbsn NVARCHAR(10)
		,achternaam NVARCHAR(30)
		,achternaamvv NVARCHAR(30)
		,achternaamp NVARCHAR(30)
		,achternaampvv NVARCHAR(30)
		,voornaam NVARCHAR(30)
		,CONSTRAINT verzek_anonym_pk PRIMARY KEY (
			dbname
			,verzekerde_id
			)
		)

-- insert new verzekerden
INSERT INTO [BSNAnonymize].dbo.verzek_anonym (
	dbname
	,verzekerde_id
	,bsn
	,newbsn
	,achternaam
	,achternaamvv
	,achternaamp
	,achternaampvv
	,voornaam
	)
SELECT @dbname AS dbname
	,verzekerde.Verzekerde_ID
	,Verzekerde_Sofinummer
	,[BSNAnonymize].dbo.fnAnonSofi(verzekerde.Verzekerde_ID)
	,dbo.[FNAnonymizeString](Verzekerde_Achternaam)
	,dbo.[FNAnonymizeString](Verzekerde_Achternaam_Voorvoegsels)
	,dbo.[FNAnonymizeString](Verzekerde_Achternaam_Partner)
	,dbo.[FNAnonymizeString](Verzekerde_Achternaam_Voorvoegsels_Partner)
	,dbo.[FNAnonymizeString](Verzekerde_Voornaam)
FROM verzekerde
LEFT JOIN [BSNAnonymize].dbo.verzek_anonym anon
	ON verzekerde.Verzekerde_ID = anon.verzekerde_id
		AND anon.dbname = @dbname
WHERE anon.verzekerde_id IS NULL


-- update customernames with anonymized

-- create anonymize table klant
IF NOT EXISTS (
		SELECT 1
		FROM [BSNAnonymize].sys.tables
		WHERE name = 'klant_anonym'
		)
	CREATE TABLE [BSNAnonymize].dbo.klant_anonym (
		dbname NVARCHAR(100)
		,Klant_id INT
		,Klant_Naam VARCHAR(50)
		,Klant_Naam_new VARCHAR(50)
		,Klant_Fiscaalnummer CHAR(9)
		,Klant_BTWnummer VARCHAR(12)		
		,Klant_KvK_nummer VARCHAR(10)
		,CONSTRAINT klant_anonym_pk PRIMARY KEY (
			dbname
			,Klant_id
			)
		)

-- insert new klanten
INSERT INTO [BSNAnonymize].dbo.klant_anonym (
	dbname
	,Klant_id
	,klant_naam
	,klant_naam_new
	,klant_Fiscaalnummer
	,Klant_BTWnummer
	,Klant_KvK_nummer
	)
SELECT @dbname AS dbname
	,klant.Klant_id
	,klant.klant_naam
	, 'Klant_' + CONVERT(nvarchar(10), klant.Klant_id)
	,dbo.[fnAnonymizeStringAndNo](klant.klant_Fiscaalnummer)
	,dbo.[fnAnonymizeStringAndNo](klant.Klant_BTWnummer)
	,dbo.[fnAnonymizeStringAndNo](klant.Klant_KvK_nummer)
FROM klant
LEFT JOIN [BSNAnonymize].dbo.klant_anonym anon
	ON Klant.Klant_id = anon.Klant_id
		AND anon.dbname = @dbname
WHERE anon.Klant_id IS NULL

-- create anonymize table insurer
IF NOT EXISTS (
		SELECT 1
		FROM [BSNAnonymize].sys.tables
		WHERE name = 'verzekeraar_anonym'
		)
	CREATE TABLE [BSNAnonymize].dbo.verzekeraar_anonym (
		dbname NVARCHAR(100)
		,Verzekeraar_id INT
		,Verzekeraar_naam NVARCHAR(50)
		,Verzekeraar_naam_new NVARCHAR(60)
		,Verzekeraar_KvK_nummer FLOAT
		,Verzekeraar_BTWnummer NVARCHAR(30)
		,CONSTRAINT verzekeraar_anonym_pk PRIMARY KEY (
			dbname
			,Verzekeraar_id
			)
		)

-- insert new verzekeraars
INSERT INTO [BSNAnonymize].dbo.verzekeraar_anonym (
	dbname
	,verzekeraar_Id
	,verzekeraar_naam
	,verzekeraar_naam_new
	,Verzekeraar_KvK_nummer
	,Verzekeraar_BTWnummer
	)
SELECT @dbname AS dbname
	,verzekeraar.verzekeraar_Id
	,verzekeraar.verzekeraar_naam
	, 'Verzekeraar_' + CONVERT(nvarchar(10), verzekeraar.verzekeraar_Id)
	, CONVERT(float, LEFT(CONVERT(nvarchar(10), verzekeraar.verzekeraar_Id) + '00123', 7))
	,dbo.[FNAnonymizeString](verzekeraar.verzekeraar_BTWnummer)
FROM verzekeraar
LEFT JOIN [BSNAnonymize].dbo.verzekeraar_anonym anon
	ON verzekeraar.verzekeraar_Id = anon.verzekeraar_Id
		AND anon.dbname = @dbname
WHERE anon.verzekeraar_id IS NULL


-- create anonymize table Werkgever
IF NOT EXISTS (
		SELECT 1
		FROM [BSNAnonymize].sys.tables
		WHERE name = 'Werkgever_anonym'
		)
	CREATE TABLE [BSNAnonymize].dbo.Werkgever_anonym (
		dbname NVARCHAR(100)
		,Werkgever_id INT
		,Werkgever_code CHAR(7)
		,Werkgever_Naam VARCHAR(70)
		,Werkgever_Naam_new VARCHAR(70)
		,CONSTRAINT Werkgever_anonym_pk PRIMARY KEY (
			dbname
			,Werkgever_id
			)
		)

-- insert new werkgevers
INSERT INTO [BSNAnonymize].dbo.werkgever_anonym (
	dbname
	,Werkgever_id
	,Werkgever_code
	,Werkgever_naam
	,Werkgever_naam_new
	)
SELECT @dbname AS dbname
	,Werkgever.Werkgever_id
	,Werkgever.Werkgever_code
	,Werkgever.Werkgever_naam
	,'Werkgever' + CONVERT(nvarchar(10), Werkgever.Werkgever_id)
FROM Werkgever
LEFT JOIN [BSNAnonymize].dbo.Werkgever_anonym anon
	ON Werkgever.Werkgever_id = anon.Werkgever_id
		AND anon.dbname = @dbname
WHERE anon.Werkgever_id IS NULL


UPDATE a
SET Verzekerde_Sofinummer = b.newbsn
	,Verzekerde_Achternaam = b.achternaam
	,Verzekerde_Achternaam_Voorvoegsels = b.achternaamvv
	,Verzekerde_Achternaam_Partner = b.achternaamp
	,Verzekerde_Achternaam_Voorvoegsels_Partner = b.achternaampvv
	,Verzekerde_Voornaam = b.voornaam
FROM verzekerde a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Verzekerde_id = b.verzekerde_id
WHERE b.dbname = @dbname

-- update BSN numbers with anonymized
UPDATE a
SET Verzekerde_Sofinummer = b.newbsn
FROM DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Verzekerde_Sofinummer = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE a.Verzekerde_Sofinummer IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Verzekerde_Sofinummer = b.newbsn
FROM WGA_MaandBriefjes a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Verzekerde_Sofinummer = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Verzekerde_Sofinummer IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Vakantiebriefje_Verzekerde_Sofinummer = b.newbsn
FROM WGA_MaandBriefjes_Vakantiebijslag a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Vakantiebriefje_Verzekerde_Sofinummer = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Vakantiebriefje_Verzekerde_Sofinummer IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Verzekerde_Sofinummer = b.newbsn
,a.[Verzekerde_Naam] = b.achternaam + ' (' + left(b.voornaam,1) + ')' 
FROM WeekbriefjeZW_Uitgesloten a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Verzekerde_ID = b.verzekerde_id 
WHERE [Verzekerde_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET DigiWGA_Verzekerde_Sofinummer = b.newbsn
FROM WGA_DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.DigiWGA_Verzekerde_Sofinummer = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE DigiWGA_Verzekerde_Sofinummer IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Ziekmeld_Correctie_Sofinummer_Oud = b.newbsn
FROM DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Ziekmeld_Correctie_Sofinummer_Oud = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Ziekmeld_Correctie_Sofinummer_Oud IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Ziekmeld_Intrekking_Sofinummer_Oud = b.newbsn
FROM DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Ziekmeld_Intrekking_Sofinummer_Oud = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Ziekmeld_Intrekking_Sofinummer_Oud IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Ziekmeld_Intrekking_Herstelmelding_Sofinummer_Oud = b.newbsn
FROM DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Ziekmeld_Intrekking_Herstelmelding_Sofinummer_Oud = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Ziekmeld_Intrekking_Sofinummer_Oud IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Verzekerde_Sofinummer = b.newbsn
FROM DigiZSM_Message a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Verzekerde_Sofinummer = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Ziekmeld_Intrekking_Sofinummer_Oud IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET DagloonZW_Verzekerde_BSN = b.newbsn
FROM Dagloon_ZW a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.DagloonZW_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE DagloonZW_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET TFE_Emp_BSN = b.newbsn
FROM Tax_Filed_Employee a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.TFE_Emp_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE TFE_Emp_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET TFV_BSN = b.newbsn
FROM Tax_Filed_Verzekerde a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.TFV_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE TFV_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET Terugbrug_Schadelast_BSN = b.newbsn
FROM Terugbrug_Schadelast a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.Terugbrug_Schadelast_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE Terugbrug_Schadelast_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET DossierWGA_Verzekerde_BSN = b.newbsn
FROM WGA_Dossier a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.DossierWGA_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE DossierWGA_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET WGA_Dossierkosten_Verzekerde_BSN = b.newbsn
FROM WGA_Dossierkosten a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.WGA_Dossierkosten_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE WGA_Dossierkosten_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET WGAUitkeringsorder_Verzekerde_BSN = b.newbsn
FROM WGA_Uitkeringsorder a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.WGAUitkeringsorder_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE WGAUitkeringsorder_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET WGA_Verrichtingen_BSN = b.newbsn
FROM WGA_Verrichtingen a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.WGA_Verrichtingen_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE WGA_Verrichtingen_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET ZM_PLD_Verzekerde_BSN = b.newbsn
FROM ZM_Percentage_Loonsom_Detail a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.ZM_PLD_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE ZM_PLD_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET ZM_PUD_Verzekerde_BSN = b.newbsn
FROM ZM_Percentage_Uitkering_Detail a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.ZM_PUD_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE ZM_PUD_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET ZM_Uitvoeringskosten_Verzekerde_BSN = b.newbsn
FROM ZM_Vastbedrag a
JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.ZM_Uitvoeringskosten_Verzekerde_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE ZM_Uitvoeringskosten_Verzekerde_BSN IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET ZM_Verrichtingen_BSN = b.newbsn
,  [ZM_Verrichtingen_Gebruiker_Naam] = dbo.[FNAnonymizeString](ZM_Verrichtingen_Gebruiker_Naam)
FROM ZM_Verrichtingen a
LEFT OUTER JOIN [BSNAnonymize].dbo.verzek_anonym b
	ON a.ZM_Verrichtingen_BSN = b.bsn collate SQL_Latin1_General_CP1_CI_AS
WHERE ZM_Verrichtingen_BSN IS NOT NULL
	AND b.dbname = @dbname
GO

UPDATE verzekerde
SET Verzekerde_Telefoonnummer_Mobiel = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_Mobiel, '0699999999')
	,Verzekerde_Telefoonnummer_Vast = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_Vast, '0248909470')
	,Verzekerde_Telefoonnummer_Buitenland = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_Buitenland, '0032-36631953')
	,Verzekerde_Geboortedatum = [dbo].[fnIfNotNullDate](Verzekerde_Geboortedatum)
	,Verzekerde_Woonadres_Straatnaam = dbo.fnIfNotNull(Verzekerde_Woonadres_Straatnaam, 'Testwoonstraat')
	,Verzekerde_Woonadres_Huisnummer = dbo.fnIfNotNull(Verzekerde_Woonadres_Huisnummer, '1')
	,Verzekerde_Woonadres_Huisnummer_Toevoeging = dbo.fnIfNotNull(Verzekerde_Woonadres_Huisnummer_Toevoeging, '-a')
	,Verzekerde_Woonadres_Postcode = dbo.fnIfNotNull(Verzekerde_Woonadres_Postcode, '9999 WW')
	,Verzekerde_Woonadres_Plaatsnaam = dbo.fnIfNotNull(Verzekerde_Woonadres_Plaatsnaam, 'Testwoonplaatsnaam')
	,Verzekerde_Bewindvoerder_Bankrekening_Tenaamstelling = dbo.fnIfNotNull(Verzekerde_Bewindvoerder_Bankrekening_Tenaamstelling, '')
	,Verzekerde_Bewindvoerder_Bankrekening_Betalingsreferentie = dbo.fnIfNotNull(Verzekerde_Bewindvoerder_Bankrekening_Betalingsreferentie, '')
	,Verzekerde_Emailadres = (dbo.fnReplaceString(Verzekerde_Emailadres, 'prechartklout7@gmail.com', ';'))

SELECT 'verzekerde done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);


UPDATE a
SET klant_naam = b.klant_naam_new
	,klant_Fiscaalnummer = b.klant_Fiscaalnummer
	,klant_BTWnummer = b.klant_BTWnummer
	,klant_KvK_nummer = b.klant_KvK_nummer
FROM klant a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.klant_id = b.klant_id
WHERE b.dbname = @dbname

IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'dbo.DossierkostenWga')
)
    BEGIN
		UPDATE a
		SET klantnaam = b.klant_naam_new
		FROM DossierkostenWga a
		JOIN [BSNAnonymize].dbo.klant_anonym b
			ON a.klantNaam = b.klant_naam collate SQL_Latin1_General_CP1_CI_AS
		WHERE a.klantnaam IS NOT NULL
			AND b.dbname = @dbname
END

UPDATE a
SET klant_naam = b.klant_naam_new
FROM [KlantImport] a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Klant_ID (Klout7)] = b.klant_id
WHERE a.klant_naam IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [Tax_File_Klant_Naam] = b.klant_naam_new
FROM Tax_Filed a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Tax_File_Klant_id] = b.klant_id
WHERE a.[Tax_File_Klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [TFC_klant_Naam] = left(b.klant_naam_new,50)
FROM Tax_Filed_Tijdvakcorrectie a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[TFC_klant_id] = b.klant_id
WHERE a.[TFC_klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [klant_Naam] = b.klant_naam_new
FROM WeekbriefjeZW_Uitgesloten a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[klant_id] = b.klant_id
WHERE a.[klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [WHK_Change_Klant_Naam] = b.klant_naam_new
, [WHK_Change_werkgever_Naam] = w.werkgever_naam_new
FROM WHK_Changes_ZW a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[WHK_Change_Klant_id] = b.klant_id
JOIN [BSNAnonymize].dbo.werkgever_anonym w
	ON a.[WHK_Change_werkgever_id] = w.werkgever_id
WHERE a.[WHK_Change_Klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [Klant_Naam] = b.klant_naam_new
, [werkgever_Naam] = w.werkgever_naam_new
FROM ZM_Winstdeling_End_Of_Year a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Klant_id] = b.klant_id
JOIN [BSNAnonymize].dbo.werkgever_anonym w
	ON a.[werkgever_id] = w.werkgever_id
WHERE a.[Klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [Klant_Naam] = b.klant_naam_new
FROM ZW_Contract_Import a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Klant_code] = b.klant_id
WHERE a.[Klant_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [JV_Kostenplaats_naam] = b.klant_naam_new
FROM WGA_Verloning_Journaalpost a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[JV_Kostenplaats_naam] = b.Klant_Naam collate SQL_Latin1_General_CP1_CI_AS
WHERE a.[JV_Kostenplaats_naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [ZM_Percentage_Loonsom_Klant_Name] = b.klant_naam_new
FROM ZM_Percentage_Loonsom a
LEFT OUTER JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[ZM_Percentage_Loonsom_Klant_id] = b.Klant_id 
WHERE b.dbname = @dbname

UPDATE a
SET [ZM_Uitvoeringskosten_Klant_Name] = IsNUll(b.klant_naam_new, dbo.[fnAnonymizeString]([ZM_Uitvoeringskosten_Klant_Name]))
,[ZM_Uitvoeringskosten_Ziekmeld_Naam] = dbo.[FNAnonymizeString]([ZM_Uitvoeringskosten_Ziekmeld_Naam])
FROM ZM_Vastbedrag a
OUTER APPLY
(
	SELECT  TOP 1 klant_naam_new
	FROM    [BSNAnonymize].dbo.klant_anonym b
	WHERE   a.[ZM_Uitvoeringskosten_Klant_name] = b.Klant_Naam collate SQL_Latin1_General_CP1_CI_AS
	AND b.dbname = @dbname
) b

UPDATE a
SET [ZM_Winstdeling_Klant_Name] = b.klant_naam_new
FROM ZM_Winstdeling a
LEFT OUTER JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.ZM_Winstdeling_Klant_Id = b.Klant_id 
WHERE b.dbname = @dbname

UPDATE a
SET [JV_Kostenplaats_naam] = IsNUll(b.klant_naam_new, dbo.[fnAnonymizeString]([JV_Kostenplaats_naam]))
FROM ZW_Verloning_Journaalpost a
OUTER APPLY
(
	SELECT  TOP 1 klant_naam_new
	FROM    [BSNAnonymize].dbo.klant_anonym b
	WHERE   a.[JV_Kostenplaats_naam] = b.Klant_Naam collate SQL_Latin1_General_CP1_CI_AS
	AND b.dbname = @dbname
) b

SELECT 'klant done' AS STATUS
GO


DECLARE @dbname VARCHAR(200) = $(sqldbname);
UPDATE a
SET verzekeraar_naam = b.verzekeraar_naam_new
	,verzekeraar_KvK_nummer = b.Verzekeraar_KvK_nummer
	,Verzekeraar_BTWnummer = b.Verzekeraar_BTWnummer
FROM verzekeraar a
JOIN [BSNAnonymize].dbo.verzekeraar_anonym b
	ON a.verzekeraar_id = b.verzekeraar_id
WHERE b.dbname = @dbname

UPDATE a
SET [ACSRG Suplement Insurer] = b.verzekeraar_naam_new
FROM [Acture Clients Sector Risc Groups 2016] a
LEFT OUTER JOIN [BSNAnonymize].dbo.verzekeraar_anonym b
	ON a.[ACSRG Suplement Insurer] = b.verzekeraar_naam  collate SQL_Latin1_General_CP1_CI_AS
WHERE b.dbname = @dbname

UPDATE a
SET [ACSRG Stop Loss Insurer] = b.verzekeraar_naam_new
FROM [Acture Clients Sector Risc Groups 2016] a
LEFT OUTER JOIN [BSNAnonymize].dbo.verzekeraar_anonym b
	ON a.[ACSRG Stop loss Insurer] = b.verzekeraar_naam  collate SQL_Latin1_General_CP1_CI_AS
WHERE b.dbname = @dbname

UPDATE a
SET [ACSRG TaxFilingNo] =  dbo.[fnAnonymizeStringAndNo]([ACSRG TaxFilingNo])
	,[ACSRG Tax Number] =  dbo.[fnAnonymizeStringAndNo]([ACSRG Tax Number])
FROM [Acture Clients Sector Risc Groups 2016] a

SELECT 'insurer done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);


UPDATE a
SET Werkgever_naam = b.Werkgever_naam_new
FROM Werkgever a
JOIN [BSNAnonymize].dbo.Werkgever_anonym b
	ON a.Werkgever_id = b.Werkgever_id
WHERE b.dbname = @dbname

UPDATE a
SET [Tax_File_werkgever_Naam] = left(b.werkgever_naam_new,50)
FROM Tax_Filed a
JOIN [BSNAnonymize].dbo.werkgever_anonym b
	ON a.[Tax_File_werkgever_id] = b.werkgever_id
WHERE a.[Tax_File_werkgever_Naam] IS NOT NULL
	AND b.dbname = @dbname

UPDATE a
SET [TFC_Werkgever_Naam] = left(b.werkgever_naam_new,50)
FROM Tax_Filed_Tijdvakcorrectie a
JOIN [BSNAnonymize].dbo.werkgever_anonym b
	ON a.[TFC_werkgever_id] = b.werkgever_id
WHERE a.[TFC_werkgever_Naam] IS NOT NULL
	AND b.dbname = @dbname

SELECT 'werkgever done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);


-- other tables
UPDATE a
SET Ziekmeld_Verpleegadres_Straatnaam = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Straatnaam, 'Testverblijfstraat')
	,Ziekmeld_Verpleegadres_Huisnummer = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Huisnummer, '2')
	,Ziekmeld_Verpleegadres_Huisnummer_Toevoeging = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Huisnummer_Toevoeging, '-b')
	,Ziekmeld_Verpleegadres_Postcode = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Postcode, '9999 VV')
	,Ziekmeld_Verpleegadres_Plaatsnaam = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Plaatsnaam, 'Testverblijfplaatsnaam')
	,Ziekmeld_Verpleegadres_Telefoonnummer = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Telefoonnummer, '0248909476')
	,Ziekmeld_Telefoonnummer = dbo.fnIfNotNull(Ziekmeld_Telefoonnummer, '0248909476')
	,Ziekmeld_Vestiging_Telefoon = dbo.fnIfNotNull(Ziekmeld_Vestiging_Telefoon, '0248909476')
	,Ziekmeld_Vestiging_Mailadres_Case_Manager = dbo.fnIfNotNull(Ziekmeld_Vestiging_Mailadres_Case_Manager, 'prechartklout7@gmail.com')
	,Ziekmeld_Vestiging_Mailadres_Dagloon = dbo.fnIfNotNull(Ziekmeld_Vestiging_Mailadres_Dagloon, 'prechartklout7@gmail.com')
	,Ziekmeld_Vestiging_Contactpersoon = dbo.fnIfNotNull(Ziekmeld_Vestiging_Contactpersoon, '')
	,Ziekmeld_Opmerking = dbo.fnIfNotNull(Ziekmeld_Opmerking, 'Opmerking')
	,Ziekmeld_Contactpersoon = dbo.fnIfNotNull(Ziekmeld_Contactpersoon, 'Contact Persoon')
	,Ziekmelding_Annularen_Reden =  dbo.fnIfNotNull(Ziekmelding_Annularen_Reden, 'Reden')
	,Ziekmeld_Inzender_Naam =  dbo.fnIfNotNull(Ziekmeld_Inzender_Naam, 'Inzender')
	,Ziekmeld_Mailadres = dbo.fnIfNotNull(Ziekmeld_Mailadres, 'prechartklout7@gmail.com')
	,ziekmeld_Vestiging_naam = ISNULL(b.klant_vestiging_naam, dbo.[FNAnonymizeString]([ziekmeld_Vestiging_naam]))
FROM Ziekmelding a
OUTER APPLY
(
	SELECT  TOP 1 Klant_Vestiging_Naam
	FROM    Klant_Vestiging b
	WHERE   a.[Ziekmeld_Vestiging] = b.Klant_Vestiging_Code 
) b

SELECT 'ziekmelding done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);

UPDATE WGA_Dossier
SET DossierWGA_Verpleegadres_Straatnaam = 'Testwgastraat'
	,DossierWGA_Verpleegadres_Huisnummer = '3'
	,DossierWGA_Verpleegadres_Huisnummer_Toevoeging = '-c'
	,DossierWGA_Verpleegadres_Postcode = '9999 WG'
	,DossierWGA_Verpleegadres_Plaatsnaam = 'Testwgaplaatsnaam'
	,DossierWGA_Verpleegadres_Telefoonnummer = '0248909476'
	,DossierWGA_Verzekerde_Telefoonnummer_Mobiel = '0699999999' 
	,DossierWGA_Verzekerde_Telefoonnummer_Vast = '0248909476'
	,DossierWGA_Vestiging_Email_CM_WGA = (dbo.fnReplaceString(DossierWGA_Vestiging_Email_CM_WGA, 'prechartklout7@gmail.com', ';'))
	,DossierWGA_Vestiging_Contactpersoon = dbo.[FNAnonymizeString](DossierWGA_Vestiging_Contactpersoon)
	,DossierWGA_Verzekerde_Achternaam = dbo.[FNAnonymizeString](DossierWGA_Verzekerde_Achternaam)
	,DossierWGA_Verzekerde_Voornaam = dbo.[FNAnonymizeString](DossierWGA_Verzekerde_Voornaam)

SELECT 'wgadossier done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);

UPDATE DigiZSM_Message
SET Ziekmeld_Mailadres = dbo.fnIfNotNull(Ziekmeld_Mailadres, 'prechartklout7@gmail.com')
	,Verzekerde_Emailadres = dbo.fnIfNotNull(Verzekerde_Emailadres, 'prechartklout7@gmail.com')
	,Ziekmeld_Inzender_Naam = dbo.fnIfNotNull(Ziekmeld_Inzender_Naam, '')
	,Ziekmeld_Contactpersoon = dbo.fnIfNotNull(Ziekmeld_Contactpersoon, '')
	,Ziekmeld_Telefoonnummer = dbo.fnIfNotNull(Ziekmeld_Telefoonnummer, '0699999999')
	,Ziekmeld_VerpleegadresNL_Postcode = dbo.fnIfNotNull(Ziekmeld_VerpleegadresNL_Postcode, '9999 WW')
	,Ziekmeld_VerpleegadresNL_Huisnummer = dbo.fnIfNotNull(Ziekmeld_VerpleegadresNL_Huisnummer, '1')
	,Ziekmeld_VerpleegadresNL_Huisnummer_Toevoeging = dbo.fnIfNotNull(Ziekmeld_VerpleegadresNL_Huisnummer_Toevoeging, '-a')
	,Ziekmeld_VerpleegadresNL_Straatnaam = dbo.fnIfNotNull(Ziekmeld_VerpleegadresNL_Straatnaam, 'Testwoonstraat')
	,Ziekmeld_VerpleegadresNL_Plaatsnaam = dbo.fnIfNotNull(Ziekmeld_VerpleegadresNL_Plaatsnaam, 'Testwoonplaatsnaam')
	,Ziekmeld_VerpleegadresBTL_Postcode = dbo.fnIfNotNull(Ziekmeld_VerpleegadresBTL_Postcode, '9999 WW')
	,Ziekmeld_VerpleegadresBTL_Huisnummer = dbo.fnIfNotNull(Ziekmeld_VerpleegadresBTL_Huisnummer, '1')
	,Ziekmeld_VerpleegadresBTL_Straatnaam = dbo.fnIfNotNull(Ziekmeld_VerpleegadresBTL_Straatnaam, 'Testwoonstraat')
	,Ziekmeld_VerpleegadresBTL_Plaatsnaam = dbo.fnIfNotNull(Ziekmeld_VerpleegadresBTL_Plaatsnaam, 'Testwoonplaatsnaam')
	,Ziekmeld_Verpleegadres_Telefoonnummer = dbo.fnIfNotNull(Ziekmeld_Verpleegadres_Telefoonnummer, '0699999999')
	,Ziekmeld_Verpleeginrichting_Naam = dbo.fnIfNotNull(Ziekmeld_Verpleeginrichting_Naam, '')
	,Ziekmeld_Correctie_Geboortedatum_Oud = [dbo].[fnIfNotNullDate](Ziekmeld_Correctie_Geboortedatum_Oud)
	,Ziekmeld_Intrekking_Geboortedatum_Oud = [dbo].[fnIfNotNullDate](Ziekmeld_Intrekking_Geboortedatum_Oud)
	,Ziekmeld_Intrekking_Herstelmelding_Geboortedatum_Oud = [dbo].[fnIfNotNullDate](Ziekmeld_Intrekking_Herstelmelding_Geboortedatum_Oud)
	,Verzekerde_Geboortedatum = [dbo].[fnIfNotNullDate](Verzekerde_Geboortedatum)
	,Verzekerde_WoonadresNL_Postcode = dbo.fnIfNotNull(Verzekerde_WoonadresNL_Postcode, '9999 WW')
	,Verzekerde_WoonadresNL_Huisnummer = dbo.fnIfNotNull(Verzekerde_WoonadresNL_Huisnummer, '1')
	,Verzekerde_WoonadresNL_Huisnummer_Toevoeging = dbo.fnIfNotNull(Verzekerde_WoonadresNL_Huisnummer_Toevoeging, '-a')
	,Verzekerde_WoonadresNL_Straatnaam = dbo.fnIfNotNull(Verzekerde_WoonadresNL_Straatnaam, 'Testwoonstraat')
	,Verzekerde_WoonadresNL_Plaatsnaam = dbo.fnIfNotNull(Verzekerde_WoonadresNL_Plaatsnaam, 'Testwoonplaatsnaam')
	,Verzekerde_WoonadresBTL_Postcode = dbo.fnIfNotNull(Verzekerde_WoonadresBTL_Postcode, '9999 WW')
	,Verzekerde_WoonadresBTL_Huisnummer = dbo.fnIfNotNull(Verzekerde_WoonadresBTL_Huisnummer, '1')
	,Verzekerde_WoonadresBTL_Straatnaam = dbo.fnIfNotNull(Verzekerde_WoonadresBTL_Straatnaam, 'Testwoonstraat')
	,Verzekerde_WoonadresBTL_Plaatsnaam = dbo.fnIfNotNull(Verzekerde_WoonadresBTL_Plaatsnaam, 'Testwoonplaatsnaam')
	,Verzekerde_Telefoonnummer_Mobiel = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_Mobiel, '0699999999')
	,Verzekerde_Telefoonnummer_Vast = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_Vast, '0248909470')
	,Verzekerde_Telefoonnummer_BTL = dbo.fnIfNotNull(Verzekerde_Telefoonnummer_BTL, '0032-36631953')
	,Verzekerde_bankrekeningBTL_IBAN = dbo.fnIfNotNull(Verzekerde_bankrekeningBTL_IBAN, 'NL66RABO0146703316')
	,Verzekerde_Achternaam = dbo.[FNAnonymizeString](Verzekerde_Achternaam)
	,Verzekerde_Achternaam_Voorvoegsels = dbo.[FNAnonymizeString](Verzekerde_Achternaam_Voorvoegsels)
	,Verzekerde_Achternaam_Partner = dbo.[FNAnonymizeString](Verzekerde_Achternaam_Partner)
	,Verzekerde_Achternaam_Voorvoegsels_Partner = dbo.[FNAnonymizeString](Verzekerde_Achternaam_Voorvoegsels_Partner)
	,Verzekerde_Voornaam = dbo.[FNAnonymizeString](Verzekerde_Voornaam)
	,Ziekmeld_Opmerking = 'Ziekmeld opmerking'
	,Ziekmeld_Vestiging = 'Ziekmeld vestiging'

SELECT 'digizsmmessage done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname);

UPDATE a
SET DigiWGA_Email_Address = (dbo.fnReplaceString(DigiWGA_Email_Address, 'prechartklout7@gmail.com', ';'))
	,DigiWGA_Verzekerde_Email_Address = (dbo.fnReplaceString(DigiWGA_Email_Address, 'prechartklout7@gmail.com', ';'))
	,DigiWGA_Verzekerde_Geboortedatum = [dbo].[fnIfNotNullDate](DigiWGA_Verzekerde_Geboortedatum)
	,DigiWGA_Verzekerde_Bankrekening_IBAN = dbo.fnIfNotNull(DigiWGA_Verzekerde_Bankrekening_IBAN, 'NL66RABO0146703316')
	,DigiWGA_Verzekerde_Telefoonnummer_Vast = dbo.fnIfNotNull(DigiWGA_Verzekerde_Telefoonnummer_Vast, '0248909470')
	,DigiWGA_Verzekerde_Telefoonnummer_Mobiel = dbo.fnIfNotNull(DigiWGA_Verzekerde_Telefoonnummer_Mobiel, '0699999999')
	,DigiWGA_Verzekerde_WoonadresNL_Straatnaam = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresNL_Straatnaam, 'Testwoonstraat')
	,DigiWGA_Verzekerde_WoonadresNL_Huisnummer = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresNL_Huisnummer, '1')
	,DigiWGA_Verzekerde_WoonadresNL_Huisnummer_Toevoeging = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresNL_Huisnummer_Toevoeging, '-a')
	,DigiWGA_Verzekerde_WoonadresNL_Postcode = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresNL_Postcode, '9999 WW')
	,DigiWGA_Verzekerde_WoonadresNL_Plaatsnaam = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresNL_Plaatsnaam, 'Testwoonplaatsnaam')
	,DigiWGA_Verzekerde_WoonadresBTL_Straatnaam = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresBTL_Straatnaam, 'Testwoonstraat')
	,DigiWGA_Verzekerde_WoonadresBTL_Huisnummer = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresBTL_Huisnummer, '1')
	,DigiWGA_Verzekerde_WoonadresBTL_Postcode = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresBTL_Postcode, '9999 WW')
	,DigiWGA_Verzekerde_WoonadresBTL_Plaatsnaam = dbo.fnIfNotNull(DigiWGA_Verzekerde_WoonadresBTL_Plaatsnaam, '1')
	,DigiWGA_Verzekerde_Achternaam = dbo.[FNAnonymizeString](DigiWGA_Verzekerde_Achternaam)
	,DigiWGA_Verzekerde_Achternaam_Voorvoegsels = dbo.[FNAnonymizeString](DigiWGA_Verzekerde_Achternaam_Voorvoegsels)
	,DigiWGA_Verzekerde_Achternaam_Partner = dbo.[FNAnonymizeString](DigiWGA_Verzekerde_Achternaam_Partner)
	,DigiWGA_Verzekerde_Achternaam_Voorvoegsels_Partner = dbo.[FNAnonymizeString](DigiWGA_Verzekerde_Achternaam_Voorvoegsels_Partner)
	,DigiWGA_Verzekerde_Voornaam = dbo.[FNAnonymizeString](DigiWGA_Verzekerde_Voornaam)
	,DigiWGA_Klant_Naam = b.klant_naam_new
FROM WGA_DigiZSM_Message a
LEFT OUTER JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[DigiWGA_Klant_ID] = b.klant_id

SELECT 'wgadigizsmmessage done' AS STATUS
GO

DECLARE @dbname VARCHAR(200) = $(sqldbname)


UPDATE Bedrijf_Contactpersoon
SET Bedrijf_Contactpersoon_Email = (dbo.fnReplaceString(Bedrijf_Contactpersoon_Email, 'prechartklout7@gmail.com', ';'))
WHERE Bedrijf_Contactpersoon_Email IS NOT NULL

UPDATE Bedrijfarts
SET Bedrijfarts_Email = (dbo.fnReplaceString(Bedrijfarts_Email, 'prechartklout7@gmail.com', ';'))
WHERE Bedrijfarts_Email IS NOT NULL

UPDATE Bedrijfarts_Organisatie
SET Bedrijfartsorganisatie_Email = (dbo.fnReplaceString(Bedrijfartsorganisatie_Email, 'prechartklout7@gmail.com', ';'))
WHERE Bedrijfartsorganisatie_Email IS NOT NULL

UPDATE Document
SET Document_Email_From = (dbo.fnReplaceString(Document_Email_From, 'prechartklout7@gmail.com', ';'))
	,Document_Email_To = (dbo.fnReplaceString(Document_Email_To, 'prechartklout7@gmail.com', ';'))

UPDATE Gebruiker
SET Gebruiker_Emailadres = (dbo.fnReplaceString(Gebruiker_Emailadres, 'prechartklout7@gmail.com', ';'))
WHERE Gebruiker_Emailadres IS NOT NULL

UPDATE Journaalpost
SET Journaalpost_Account_Email = (dbo.fnReplaceString(Journaalpost_Account_Email, 'prechartklout7@gmail.com', ';'))
WHERE Journaalpost_Account_Email IS NOT NULL

UPDATE Klant
SET Klant_email_CM = (dbo.fnReplaceString(Klant_email_CM, 'prechartklout7@gmail.com', ';'))
	,Klant_email_dagloon = (dbo.fnReplaceString(Klant_email_dagloon, 'prechartklout7@gmail.com', ';'))
	,Klant_Factuur_Emailadres = (dbo.fnReplaceString(Klant_Factuur_Emailadres, 'prechartklout7@gmail.com', ';'))
	,Klant_Factuur_Emailadres_WGA = (dbo.fnReplaceString(Klant_Factuur_Emailadres_WGA, 'prechartklout7@gmail.com', ';'))
	,Klant_Factuur_Emailadres_Herrinering = (dbo.fnReplaceString(Klant_Factuur_Emailadres_Herrinering, 'prechartklout7@gmail.com', ';'))
	,Klant_Factuur_Emailadres_WGA_Herrinering = (dbo.fnReplaceString(Klant_Factuur_Emailadres_WGA_Herrinering, 'prechartklout7@gmail.com', ';'))

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Email = (dbo.fnReplaceString(Klant_Contactpersoon_Email, 'prechartklout7@gmail.com', ';'))
WHERE Klant_Contactpersoon_Email IS NOT NULL

UPDATE Klant_Loonsommen
SET Loonsom_akkoord_gever_email_Q1 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q1, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q2 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q2, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q3 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q3, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q4 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q4, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Jaar = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Jaar, 'prechartklout7@gmail.com', ';'))

UPDATE Klant_Loonsommen_Trail
SET Loonsom_akkoord_gever_email_Q1 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q1, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q2 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q2, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q3 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q3, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Q4 = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Q4, 'prechartklout7@gmail.com', ';'))
	,Loonsom_akkoord_gever_email_Jaar = (dbo.fnReplaceString(Loonsom_akkoord_gever_email_Jaar, 'prechartklout7@gmail.com', ';'))

UPDATE Klant_Team_Email
SET KlantTeamEmail_Name = (dbo.fnReplaceString(KlantTeamEmail_Name, 'prechartklout7@gmail.com', ';'))
	,KlantTeamEmail_EmailAddress = (dbo.fnReplaceString(KlantTeamEmail_EmailAddress, 'prechartklout7@gmail.com', ';'))
	,KlantTeamEmail_DB = (dbo.fnReplaceString(KlantTeamEmail_DB, 'prechartklout7@gmail.com', ';'))

UPDATE Klant_Team
SET [Klant_Team_Naam] = 'klant_team_' + Convert(nvarchar(8), Klant_Team_id)
	, [Klant_Team_Omschrijving] = dbo.[FNAnonymizeString]([Klant_Team_Omschrijving]) 

UPDATE Klant_Vestiging
SET Klant_Vestiging_Email_CM = (dbo.fnReplaceString(Klant_Vestiging_Email_CM, 'prechartklout7@gmail.com', ';'))
	,Klant_Vestiging_Email_Dagloon = (dbo.fnReplaceString(Klant_Vestiging_Email_Dagloon, 'prechartklout7@gmail.com', ';'))
	,Klant_Vestiging_Email_CM_WGA = (dbo.fnReplaceString(Klant_Vestiging_Email_CM_WGA, 'prechartklout7@gmail.com', ';'))
	,Klant_Vestiging_Telefoonnummer = (dbo.fnReplaceString(Klant_Vestiging_Telefoonnummer, '0248909470', ';'))
	,Klant_Vestiging_Naam =  dbo.[FNAnonymizeString]([Klant_Vestiging_Naam]) 
	,Klant_Vestiging_Contactpersoon =  dbo.[FNAnonymizeString]([Klant_Vestiging_Contactpersoon]) 

UPDATE KlantImport
SET Klant_email_CM = (dbo.fnReplaceString(Klant_email_CM, 'prechartklout7@gmail.com', ';'))
	,Klant_email_dagloon = (dbo.fnReplaceString(Klant_email_dagloon, 'prechartklout7@gmail.com', ';'))

UPDATE LogBoekArchive
SET ToEmails = dbo.fnReplaceString(ToEmails, 'prechartklout7@gmail.com',';')
, toNames = dbo.[FNAnonymizeString]([toNames]) 
, [Subject] = dbo.[FNAnonymizeString]([Subject]) 
, [Logboek_Data1] = dbo.[FNAnonymizeString]([Logboek_Data1]) 
WHERE ToEmails IS NOT NULL

--UPDATE MailArchive SET ToEmails = 'prechartklout7@gmail.com' WHERE ToEmails IS NOT NULL
UPDATE LogBoek
SET Logboek_Data2 = 'prechartklout7@gmail.com'
	,Logboek_Data3 = 'prechartklout7@gmail.com'
WHERE Logboek_Data1 LIKE '%MAILa%'

UPDATE MailSenderReceiver
SET EmailAddress = (dbo.fnReplaceString(EmailAddress, 'prechartklout7@gmail.com', ';'))
WHERE EmailAddress IS NOT NULL

UPDATE Poortwachter_Documents
SET PoortDocument_Uploader_Email = (dbo.fnReplaceString(PoortDocument_Uploader_Email, 'prechartklout7@gmail.com', ';'))
, PoortDocument_ClientFileName = dbo.[FNAnonymizeString]([PoortDocument_ClientFileName]) 
, PoortDocument_Uploader_Name = (dbo.fnReplaceString(PoortDocument_Uploader_Name, 'TestUploaderName', ';'))

UPDATE Poortwachter_Link
SET PoortwachterLink_ClientEmail = (dbo.fnReplaceString(PoortwachterLink_ClientEmail, 'prechartklout7@gmail.com', ';'))
WHERE PoortwachterLink_ClientEmail IS NOT NULL

UPDATE RaamContract
SET RaamContract_PreWGA_UitvraagEmailaddress = (dbo.fnReplaceString(RaamContract_PreWGA_UitvraagEmailaddress, 'prechartklout7@gmail.com', ';'))
WHERE RaamContract_PreWGA_UitvraagEmailaddress IS NOT NULL

UPDATE Verzekeraar_Contactpersoon
SET Verzekeraar_Contactpersoon_Email = (dbo.fnReplaceString(Verzekeraar_Contactpersoon_Email, 'prechartklout7@gmail.com', ';'))
WHERE Verzekeraar_Contactpersoon_Email IS NOT NULL

UPDATE WGA_Contract_PreWGA
SET WGA_Contract_PreWGA_akkoord_gever_email_Q1 = (dbo.fnReplaceString(WGA_Contract_PreWGA_akkoord_gever_email_Q1, 'prechartklout7@gmail.com', ';'))
	,WGA_Contract_PreWGA_akkoord_gever_email_Q2 = (dbo.fnReplaceString(WGA_Contract_PreWGA_akkoord_gever_email_Q2, 'prechartklout7@gmail.com', ';'))
	,WGA_Contract_PreWGA_akkoord_gever_email_Q3 = (dbo.fnReplaceString(WGA_Contract_PreWGA_akkoord_gever_email_Q3, 'prechartklout7@gmail.com', ';'))
	,WGA_Contract_PreWGA_akkoord_gever_email_Q4 = (dbo.fnReplaceString(WGA_Contract_PreWGA_akkoord_gever_email_Q4, 'prechartklout7@gmail.com', ';'))
	,WGA_Contract_PreWGA_akkoord_gever_email_Jaar = (dbo.fnReplaceString(WGA_Contract_PreWGA_akkoord_gever_email_Jaar, 'prechartklout7@gmail.com', ';'))
	,WGA_Contract_PreWGA_Email_Count_Jaar = (dbo.fnReplaceString(WGA_Contract_PreWGA_Email_Count_Jaar, 'prechartklout7@gmail.com', ';'))
	,[WGA_Contract_PreWGA_akkoord_gever_naam_Q1] = dbo.[FNAnonymizeString]([WGA_Contract_PreWGA_akkoord_gever_naam_Q1])
	,[WGA_Contract_PreWGA_akkoord_gever_naam_Q2] = dbo.[FNAnonymizeString]([WGA_Contract_PreWGA_akkoord_gever_naam_Q2])
	,[WGA_Contract_PreWGA_akkoord_gever_naam_Q3] = dbo.[FNAnonymizeString]([WGA_Contract_PreWGA_akkoord_gever_naam_Q3])
	,[WGA_Contract_PreWGA_akkoord_gever_naam_Q4] = dbo.[FNAnonymizeString]([WGA_Contract_PreWGA_akkoord_gever_naam_Q4])

UPDATE WGA_LogBoekArchive
SET WGA_ToEmails = (dbo.fnReplaceString(WGA_ToEmails, 'prechartklout7@gmail.com', ';'))
WHERE WGA_ToEmails IS NOT NULL

UPDATE WGAContract
SET WGAContract_PreWGA_UitvraagEmailaddress = (dbo.fnReplaceString(WGAContract_PreWGA_UitvraagEmailaddress, 'prechartklout7@gmail.com', ';'))
WHERE WGAContract_PreWGA_UitvraagEmailaddress IS NOT NULL

UPDATE ZW_Contract
SET ZW_Contract_Loonsom_Email = (dbo.fnReplaceString(ZW_Contract_Loonsom_Email, 'prechartklout7@gmail.com', ';'))
WHERE ZW_Contract_Loonsom_Email IS NOT NULL

UPDATE WGA_Contract_Document
SET WGA_Contract_Document_Author = (dbo.fnReplaceString(WGA_Contract_Document_Author, 'prechartklout7@gmail.com', ';'))
WHERE WGA_Contract_Document_Author IS NOT NULL

UPDATE ZW_Contract_Document
SET ZW_Contract_Document_Author = (dbo.fnReplaceString(ZW_Contract_Document_Author, 'prechartklout7@gmail.com', ';'))
, [ZW_Contract_Document_FileName] = dbo.fnIfNotNull([ZW_Contract_Document_FileName], 'filename.ext')
WHERE ZW_Contract_Document_Author IS NOT NULL

UPDATE Gebruiker
SET Gebruiker_Achternaam = 'Gebruiker'
	,Gebruiker_Voornaam = Gebruiker_Gebruikersnaam

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Voornaam = 'Voornaamcnt'
	,Klant_Contactpersoon_Achternaam = 'Achternaamcnt'

UPDATE Verzekeraar_Contactpersoon
SET Verzekeraar_Contactpersoon_Voornaam = 'VNverzekeraar'
	,Verzekeraar_Contactpersoon_Achternaam = 'ANverzekeraar'

--Others---
UPDATE Bedrijfarts
SET Bedrijfarts_BIG_Registratienummer = 9999999999
WHERE Bedrijfarts_BIG_Registratienummer IS NOT NULL

UPDATE Bedrijfarts_Organisatie
SET Bedrijfartsorganisatie_Straat = 'Testwoonstraat'
	,Bedrijfartsorganisatie_Huisnummer = '1'
	,Bedrijfartsorganisatie_Huisnummer_Toevoeging = '-a'
	,Bedrijfartsorganisatie_Postcode = '9999 WW'
	,Bedrijfartsorganisatie_Plaats = 'Testwoonplaatsnaam'

UPDATE Klant_Incasso
SET Klant_Incasso_IBAN = 'NL66RABO0146703316'
WHERE Klant_Incasso_IBAN IS NOT NULL

UPDATE Bedrijf_Contactpersoon
SET Bedrijf_Contactpersoon_Voornaam = 'VNBedrijf'
	,Bedrijf_Contactpersoon_Achternaam = 'ANBedrijf'
	,Bedrijf_Contactpersoon_Telefoon = '0699999999'
	,Bedrijf_Contactpersoon_Mobiel = '0699999999'

UPDATE Ziekmelding_Reiskosten_Trajecten
SET Reiskosten_Traject_Postcode_Van_Vertrek = '9999 WW'
	,Reiskosten_Traject_Postcode_Van_Bestemming = '9999 WW'
	,Reiskosten_Traject_Plaats_Van_Vertrek = 'Testwoonplaatsnaam'
	,Reiskosten_Traject_Plaats_Van_Bestemming = 'Testwoonplaatsnaam'

UPDATE Verzekerde_Vordering_Machtiging
SET Machtiging_Iban = 'NL66RABO0146703316'
WHERE Machtiging_Iban IS NOT NULL

UPDATE Verzekerde_Vordering_Incasso
SET Vordering_Incasso_Iban = 'NL66RABO0146703316'
WHERE Vordering_Incasso_Iban IS NOT NULL

UPDATE Verzekeraar_Incasso
SET Verzekeraar_Incasso_IBAN = 'NL66RABO0146703316'
WHERE Verzekeraar_Incasso_IBAN IS NOT NULL

UPDATE a
SET [Verzekeraar_Incasso_Tenaamstelling_Rekening] = b.verzekeraar_naam_new
FROM Verzekeraar_Incasso a
JOIN [BSNAnonymize].dbo.verzekeraar_anonym b
	ON a.Verzekeraar_Verzekeraar_ID = b.verzekeraar_id
WHERE b.dbname = @dbname

UPDATE Verzekeraar_Contactpersoon
SET Verzekeraar_Contactpersoon_Straat = 'Testwoonstraat'
	,Verzekeraar_Contactpersoon_Huisnummer = '1'
	,Verzekeraar_Contactpersoon_Huisnummer_Toevoeging = '-a'
	,Verzekeraar_Contactpersoon_Postcode = '9999 WW'
	,Verzekeraar_Contactpersoon_Plaats = 'Testwoonplaatsnaam'
	,Verzekeraar_Contactpersoon_Postcode_Postbus = '9999 WW'
	,Verzekeraar_Contactpersoon_Plaats_Postbus = 'Testwoonplaatsnaam'
	,Verzekeraar_Contactpersoon_Mobiel = '0699999999'
	,Verzekeraar_Contactpersoon_Telefoonnummer = '0248909470'
	,Verzekeraar_Contactpersoon_Faxnummer = '0248909470'

UPDATE UWV_Vestiging
SET UWV_Vestiging_Naam = 'TestVestigingName'
WHERE UWV_Vestiging_Naam IS NOT NULL

UPDATE AutoIncasso
SET AutoIncasso_DbtrAcct_Id_IBAN = '0699999999',
 [AutoIncasso_Dbtr_Nm] = dbo.[fnAnonymizeString]([AutoIncasso_Dbtr_Nm])
WHERE AutoIncasso_DbtrAcct_Id_IBAN IS NOT NULL

UPDATE Bedrijfarts
SET Bedrijfarts_Telefoonnummer = '0248909470'
WHERE Bedrijfarts_Telefoonnummer IS NOT NULL

UPDATE Bezoeklocatie
SET Straat = 'Testwoonstraat'
WHERE Straat IS NOT NULL

UPDATE Bezoeklocatie
SET Huisnummer = '1'
WHERE Huisnummer IS NOT NULL

UPDATE Bezoeklocatie
SET HuisnummerToevoeging = '-a'
WHERE HuisnummerToevoeging IS NOT NULL

UPDATE Bezoeklocatie
SET Postcode = '9999 WW'
WHERE Postcode IS NOT NULL

UPDATE Bezoeklocatie
SET Plaats = 'Testwoonplaatsnaam'
WHERE Plaats IS NOT NULL

UPDATE ContractZW6083
SET [ACSRG Inc Bank Acc SL] = 'NL66RABO0146703316'
WHERE [ACSRG Inc Bank Acc SL] IS NOT NULL

UPDATE ContractZW6083
SET [ACSRG Inc Bank Acc Cost] = 'NL66RABO0146703316'
WHERE [ACSRG Inc Bank Acc Cost] IS NOT NULL

UPDATE ContractZW6083
SET [ACSRG Inc Bank Acc PS] = 'NL66RABO0146703316'
WHERE [ACSRG Inc Bank Acc PS] IS NOT NULL

UPDATE Digipoort_Tax_Filed_Payment_Details
SET Tax_Filed_Payment_Creditor_IBAN = 'NL66RABO0146703316'
WHERE Tax_Filed_Payment_Creditor_IBAN IS NOT NULL

UPDATE Gebruiker
SET Gebruiker_Intern_Telefoonnummer = '0699999999'
WHERE Gebruiker_Intern_Telefoonnummer IS NOT NULL

UPDATE Gebruiker
SET Gebruiker_Mobile_Number = '0699999999'
WHERE Gebruiker_Mobile_Number IS NOT NULL

UPDATE Gebruiker
SET Gebruiker_PasswordExpiration = null
WHERE Gebruiker_PasswordExpiration IS NOT NULL


UPDATE Klant
SET Klant_Straat = 'Testwoonstraat'
WHERE Klant_Straat IS NOT NULL

UPDATE Klant
SET Klant_Huisnummer = '1'
WHERE Klant_Huisnummer IS NOT NULL

UPDATE Klant
SET Klant_Huisnummer_Toevoeging = '-a'
WHERE Klant_Huisnummer_Toevoeging IS NOT NULL

UPDATE Klant
SET Klant_Postcode = '9999 WW'
WHERE Klant_Postcode IS NOT NULL

UPDATE Klant
SET Klant_Plaats = 'Testwoonplaatsnaam'
WHERE Klant_Plaats IS NOT NULL

UPDATE Klant
SET Klant_Postcode_Postbus = '9999 WW'
WHERE Klant_Postcode_Postbus IS NOT NULL

UPDATE Klant
SET Klant_Plaats_Postbus = 'Testwoonplaatsnaam'
WHERE Klant_Plaats_Postbus IS NOT NULL

UPDATE Klant
SET Klant_Telefoonnummer = '0248909470'
WHERE Klant_Telefoonnummer IS NOT NULL

UPDATE Klant
SET Klant_Faxnummer = '0248909470'
WHERE Klant_Faxnummer IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Straat = 'Testwoonstraat'
WHERE Klant_Contactpersoon_Straat IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Huisnummer = '1'
WHERE Klant_Contactpersoon_Huisnummer IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Huisnummer_Toevoeging = '-a'
WHERE Klant_Contactpersoon_Huisnummer_Toevoeging IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Postcode = '9999 WW'
WHERE Klant_Contactpersoon_Postcode IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Plaats = 'Testwoonplaatsnaam'
WHERE Klant_Contactpersoon_Plaats IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Cosntacpersoon_Postcode_Postbus = '9999 WW'
WHERE Klant_Cosntacpersoon_Postcode_Postbus IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Plaats_Postbus = '9999 WW'
WHERE Klant_Contactpersoon_Plaats_Postbus IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Telefoonnummer = '0248909470'
WHERE Klant_Contactpersoon_Telefoonnummer IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Faxnummer = '0248909470'
WHERE Klant_Contactpersoon_Faxnummer IS NOT NULL

UPDATE Klant_Contactpersoon
SET Klant_Contactpersoon_Mobiel = '0699999999'
WHERE Klant_Contactpersoon_Mobiel IS NOT NULL

UPDATE Klant_Incasso
SET Klant_Incasso_IBAN = 'NL66RABO0146703316'
WHERE Klant_Incasso_IBAN IS NOT NULL

UPDATE KlantImport
SET Klant_Straat = 'Testwoonstraat'
WHERE Klant_Straat IS NOT NULL

UPDATE KlantImport
SET Klant_Huisnummer = '1'
WHERE Klant_Huisnummer IS NOT NULL

UPDATE KlantImport
SET Klant_Huisnummer_Toevoeging = '-a'
WHERE Klant_Huisnummer_Toevoeging IS NOT NULL

UPDATE KlantImport
SET Klant_Postcode = '9999 WW'
WHERE Klant_Postcode IS NOT NULL

UPDATE KlantImport
SET Klant_Plaats = '9999 WW'
WHERE Klant_Plaats IS NOT NULL

UPDATE KlantImport
SET Klant_Postcode_Postbus = '9999 WW'
WHERE Klant_Postcode_Postbus IS NOT NULL

UPDATE KlantImport
SET Klant_Plaats_Postbus = '9999 WW'
WHERE Klant_Plaats_Postbus IS NOT NULL

UPDATE KlantImport
SET Klant_Telefoonnummer = '0248909470'
WHERE Klant_Telefoonnummer IS NOT NULL

UPDATE KlantImport
SET Klant_Incasso = 'NL66RABO0146703316'
WHERE Klant_Incasso IS NOT NULL

UPDATE KlantImport
SET Klant_Faxnummer = '0248909470'
WHERE Klant_Faxnummer IS NOT NULL

UPDATE Loonbeslag
SET Loonbeslag_Bankrekening_IBAN = dbo.fnIfNotNull(Loonbeslag_Bankrekening_IBAN, 'NL66RABO0146703316')
, [Loonbeslag_Bankrekening_Betalingsreferentie] = dbo.[fnAnonymizeStringAndNo]([Loonbeslag_Bankrekening_Betalingsreferentie]) 
, [Loonbeslag_Bankrekening_Tenaamstelling] = dbo.[FNAnonymizeString]([Loonbeslag_Bankrekening_Tenaamstelling]) 

UPDATE Loonbeslag_Instantie
SET Loonbeslag_Instantie_Postcode =  dbo.fnIfNotNull(Loonbeslag_Instantie_Postcode, '9999 WW')
, Loonbeslag_Instantie_Plaatsnaam =  dbo.fnIfNotNull(Loonbeslag_Instantie_Plaatsnaam, 'Testwoonplaatsnaam')
,[Loonbeslag_Instantie_Naam] = dbo.[FNAnonymizeString]([Loonbeslag_Instantie_Naam]) 

UPDATE Spreekuurlocatie
SET [Spreekuurlocatie_Naam] = dbo.[FNAnonymizeString]([Spreekuurlocatie_Naam]) 
, Spreekuurlocatie_Straat = dbo.fnIfNotNull(Spreekuurlocatie_Straat, 'Testwoonstraat')
, Spreekuurlocatie_Huisnummer = dbo.fnIfNotNull(Spreekuurlocatie_Huisnummer, '1')
, Spreekuurlocatie_Huisnummer_Toevoeging = dbo.fnIfNotNull(Spreekuurlocatie_Huisnummer_Toevoeging, '-a')
, Spreekuurlocatie_Postcode = dbo.fnIfNotNull(Spreekuurlocatie_Postcode, '9999 WW')
, Spreekuurlocatie_Plaats = dbo.fnIfNotNull(Spreekuurlocatie_Plaats, '9999 WW')
, Spreekuurlocatie_Telefoonnummer = dbo.fnIfNotNull(Spreekuurlocatie_Telefoonnummer,'0248909470')

UPDATE UWV_Vestiging
SET UWV_Vestiging_Bezoekadres_Plaats = 'Testwoonplaatsnaam'
WHERE UWV_Vestiging_Bezoekadres_Plaats IS NOT NULL

UPDATE UWV_Vestiging
SET UWV_Vestiging_Postcode_Postbus = '9999 WW'
WHERE UWV_Vestiging_Postcode_Postbus IS NOT NULL

UPDATE UWV_Vestiging
SET UWV_Vestiging_Postadres_Plaats = 'Testwoonplaatsnaam'
WHERE UWV_Vestiging_Postadres_Plaats IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Straat = 'Testwoonstraat'
WHERE Verzekeraar_Straat IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Huisnummer = '1'
WHERE Verzekeraar_Huisnummer IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Huisnummer_toevoeging = '-a'
WHERE Verzekeraar_Huisnummer_toevoeging IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Postcode = '9999 WW'
WHERE Verzekeraar_Postcode IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Plaats = 'Testwoonplaatsnaam'
WHERE Verzekeraar_Plaats IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Postcode_postbus = '9999 WW'
WHERE Verzekeraar_Postcode_postbus IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_plaats_postbus = 'Testwoonplaatsnaam'
WHERE Verzekeraar_plaats_postbus IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Telefoonnummer = '0248909470'
WHERE Verzekeraar_Telefoonnummer IS NOT NULL

UPDATE Verzekeraar
SET Verzekeraar_Faxnummer = '0248909470'
WHERE Verzekeraar_Faxnummer IS NOT NULL

UPDATE Ziekmelding_Memo
SET Memo_Auteur = 'Memo_Auteur ' + cast(Id AS NVARCHAR(10))
	,Memo_Titel = 'Memo_Titel ' + cast(Id AS NVARCHAR(10))
	,Memo_Content = 'Memo_Content ' + cast(ID AS NVARCHAR(10))

UPDATE WGA_Memo
SET WGA_Memo_Auteur = dbo.[FNAnonymizeString](WGA_Memo_Auteur)
WHERE WGA_Memo_Auteur IS NOT NULL

UPDATE WGA_Memo
SET WGA_Memo_Title = dbo.[FNAnonymizeString](WGA_Memo_Title)
WHERE WGA_Memo_Title IS NOT NULL

UPDATE WGA_Memo
SET WGA_Memo_Content = dbo.[FNAnonymizeString](WGA_Memo_Content)
WHERE WGA_Memo_Content IS NOT NULL

UPDATE WGA_ContactHistorie_Note
SET WGA_Note_Author = dbo.[FNAnonymizeString](WGA_Note_Author)
WHERE WGA_Note_Author IS NOT NULL

UPDATE WGA_ContactHistorie_Note
SET WGA_Note_Title = dbo.[FNAnonymizeString](WGA_Note_Title)
WHERE WGA_Note_Title IS NOT NULL

UPDATE WGA_ContactHistorie_Note
SET WGA_Note_Content = dbo.[FNAnonymizeString](WGA_Note_Content)
WHERE WGA_Note_Content IS NOT NULL

UPDATE Ziekmelding_Taak_Notities
SET Notities_Auteur = 'Notities_Auteur ' + cast(Notities_Id AS NVARCHAR(10))
	,Notities_Titel = 'Notities_Titel ' + cast(Notities_Id AS NVARCHAR(10))
	,Notities_Content = 'Notities_Content ' + cast(Notities_Id AS NVARCHAR(10))

UPDATE Bedrijf_Contactpersoon
SET Bedrijf_Contactpersoon_Achternaam = dbo.[FNAnonymizeString](Bedrijf_Contactpersoon_Achternaam)
WHERE Bedrijf_Contactpersoon_Achternaam IS NOT NULL

UPDATE Bedrijfarts
SET Bedrijfarts_Achternaam = dbo.[FNAnonymizeString](Bedrijfarts_Achternaam)
WHERE Bedrijfarts_Achternaam IS NOT NULL

UPDATE WGA_MaandBriefjes
SET Verzekerde_Achternaam = dbo.[FNAnonymizeString](Verzekerde_Achternaam)
WHERE Verzekerde_Achternaam IS NOT NULL

UPDATE WGA_MaandBriefjes_Vakantiebijslag
SET Vakantiebriefje_Verzekerde_Achternaam = dbo.[FNAnonymizeString](Vakantiebriefje_Verzekerde_Achternaam)
WHERE Vakantiebriefje_Verzekerde_Achternaam IS NOT NULL

UPDATE WGA_Uitkeringsorder
SET WGAUitkeringsorder_Verzekerde_Achternaam = dbo.[FNAnonymizeString](WGAUitkeringsorder_Verzekerde_Achternaam)
WHERE WGAUitkeringsorder_Verzekerde_Achternaam IS NOT NULL

UPDATE Verzekeraar_Contactpersoon
SET Verzekeraar_Contactpersoon_Achternaam = dbo.[FNAnonymizeString](Verzekeraar_Contactpersoon_Achternaam)
WHERE Verzekeraar_Contactpersoon_Achternaam IS NOT NULL

UPDATE Bedrijfarts
SET Bedrijfarts_Voornaam = dbo.[FNAnonymizeString](Bedrijfarts_Voornaam)
WHERE Bedrijfarts_Voornaam IS NOT NULL

UPDATE WGA_MaandBriefjes
SET Verzekerde_Voornaam = dbo.[FNAnonymizeString](Verzekerde_Voornaam)
WHERE Verzekerde_Voornaam IS NOT NULL

UPDATE WGA_MaandBriefjes_Vakantiebijslag
SET Vakantiebriefje_Verzekerde_Voornaam = dbo.[FNAnonymizeString](Vakantiebriefje_Verzekerde_Voornaam)
WHERE Vakantiebriefje_Verzekerde_Voornaam IS NOT NULL

UPDATE WGA_Uitkeringsorder
SET WGAUitkeringsorder_Verzekerde_Voornaam = dbo.[FNAnonymizeString](WGAUitkeringsorder_Verzekerde_Voornaam)
WHERE WGAUitkeringsorder_Verzekerde_Voornaam IS NOT NULL

UPDATE Verzekeraar_Contactpersoon
SET Verzekeraar_Contactpersoon_Voornaam = dbo.[FNAnonymizeString](Verzekeraar_Contactpersoon_Voornaam)
WHERE Verzekeraar_Contactpersoon_Voornaam IS NOT NULL

UPDATE UWV_Vestiging
SET UWV_Vestiging_Bezoekadres = dbo.[FNAnonymizeString](UWV_Vestiging_Bezoekadres)
WHERE UWV_Vestiging_Bezoekadres IS NOT NULL

SELECT '#Achternaam & Voornaam done'

UPDATE ziekmeld_digipoort_tracking
SET [FileName] = dbo.[fnAnonymizeStringAndNo]([filename])
WHERE [FileName] IS NOT NULL

/*Cleanup Digipoort Pending*/
UPDATE ziekmeld_digipoort_tracking
SET XMLStatus = 7
WHERE id IN (
		SELECT Id
		FROM [vwDigipoortPendingRequests]
		)


UPDATE a
SET [Tax_Filed_Payment_Remittance_Information] = b.klant_naam_new
FROM Digipoort_Tax_Filed_Payment_Details a
LEFT OUTER JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Tax_Filed_Payment_Remittance_Information] = b.Klant_Naam  collate SQL_Latin1_General_CP1_CI_AS
WHERE b.dbname = @dbname

update Digipoort_Tax_Filed_Payment_Details
SET [Tax_Filed_Payment_Remittance_Information] = dbo.[FNAnonymizeString]([Tax_Filed_Payment_Remittance_Information])
WHERE [Tax_Filed_Payment_Remittance_Information] not like 'kl_%' 

/*Additional Anonymize Script for IBAN*/

IF (@dbname = 'TempActure')
BEGIN
	UPDATE Verzekerde
	SET Verzekerde_Bankrekening_IBAN = dbo.fnIfNotNull(Verzekerde_Bankrekening_IBAN, 'NL21RABO0163874387')
		,Verzekerde_Bewindvoerder_Bankrekening_IBAN = dbo.fnIfNotNull(Verzekerde_Bewindvoerder_Bankrekening_IBAN, 'NL66RABO0146703316')

	SELECT 'verzekerde done' AS STATUS

	UPDATE ZW_Verloning_Sepa
	SET Sepa_IBAN = (
			SELECT CASE 
					WHEN Verzekerde_Bewindvoerder = 1
						THEN LTrim(RTrim(isNULL(Verzekerde_Bewindvoerder_Bankrekening_IBAN, '')))
					ELSE LTrim(RTrim(isNULL(Verzekerde_Bankrekening_IBAN, '')))
					END
			FROM Verzekerde
			WHERE Verzekerde_Id = Sepa_Verzekerde_id
			)
	WHERE Sepa_IBAN IS NOT NULL

	UPDATE WGA_Verloning_Sepa
	SET Sepa_IBAN = (
			SELECT CASE 
					WHEN Verzekerde_Bewindvoerder = 1
						THEN LTrim(RTrim(isNULL(Verzekerde_Bewindvoerder_Bankrekening_IBAN, '')))
					ELSE LTrim(RTrim(isNULL(Verzekerde_Bankrekening_IBAN, '')))
					END
			FROM Verzekerde
			WHERE Verzekerde_Id = Sepa_Verzekerde_id
			)
	WHERE Sepa_IBAN IS NOT NULL
END
ELSE
BEGIN
	UPDATE Verzekerde
	SET Verzekerde_Bankrekening_IBAN = dbo.fnIfNotNull(Verzekerde_Bankrekening_IBAN, 'NL66RABO0146703316')
		,Verzekerde_Bewindvoerder_Bankrekening_IBAN = dbo.fnIfNotNull(Verzekerde_Bewindvoerder_Bankrekening_IBAN, 'NL21RABO0163874387')

	SELECT 'verzekerde done' AS STATUS

	UPDATE ZW_Verloning_Sepa
	SET Sepa_IBAN = (
			SELECT CASE 
					WHEN Verzekerde_Bewindvoerder = 1
						THEN LTrim(RTrim(isNULL(Verzekerde_Bewindvoerder_Bankrekening_IBAN, '')))
					ELSE LTrim(RTrim(isNULL(Verzekerde_Bankrekening_IBAN, '')))
					END
			FROM Verzekerde
			WHERE Verzekerde_Id = Sepa_Verzekerde_id
			)
	WHERE Sepa_IBAN IS NOT NULL

	UPDATE WGA_Verloning_Sepa
	SET Sepa_IBAN = (
			SELECT CASE 
					WHEN Verzekerde_Bewindvoerder = 1
						THEN LTrim(RTrim(isNULL(Verzekerde_Bewindvoerder_Bankrekening_IBAN, '')))
					ELSE LTrim(RTrim(isNULL(Verzekerde_Bankrekening_IBAN, '')))
					END
			FROM Verzekerde
			WHERE Verzekerde_Id = Sepa_Verzekerde_id
			)
	WHERE Sepa_IBAN IS NOT NULL
END

UPDATE WGA_Verloning_Sepa
SET [Sepa_Nm] = dbo.[FNAnonymizeString]([Sepa_Nm])
WHERE [Sepa_Nm] IS NOT NULL

UPDATE BatchProcesses
SET [ClaimsJson] = null

UPDATE [Emp Job Record]
SET [Change By] = dbo.[FNAnonymizeString]([Change By])

update Jaaropgaven_2017
SET [Jaaropgaven_BSN] = [BSNAnonymize].dbo.fnAnonSofi([Jaaropgaven_ID])

UPDATE Journaalpost
SET [Journaalpost_Account_Name] =  dbo.[FNAnonymizeString]([Journaalpost_Account_Name])
,Journaalpost_Account_Fax = '012-3456789'
,Journaalpost_Account_Phone = '012-3456789'
,Journaalpost_Costcenter_Description = 'omschrijving'

UPDATE a
SET [Journaalpost_Account_Name] = b.Klant_Naam_new
FROM Journaalpost a
JOIN [BSNAnonymize].dbo.klant_anonym b
	ON a.[Journaalpost_Account_Code] = b.Klant_id 
WHERE [Journaalpost_Account_Name] IS NOT NULL
	AND b.dbname = @dbname

update Klant_Categorie
set [KC_Categorie] = dbo.[FNAnonymizeString]([KC_Categorie]) 
,[KC_Categorie_Eng] = dbo.[FNAnonymizeString]([KC_Categorie_Eng]) 

update Klant_Categorie_wga
set [KCW_Categorie] = dbo.[FNAnonymizeString]([KCW_Categorie]) 

IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'dbo.Klant_Factuur_Record')
)
BEGIN
	update Klant_Factuur_Record
	set [InsurredName] = dbo.[FNAnonymizeString]([InsurredName]) 
	, [InsurredBirthDate] = [dbo].[fnIfNotNullDate]([InsurredBirthDate])
	, [GroupName] = dbo.[FNAnonymizeString]([GroupName])
END

UPDATE Klant_Groep
SET [Klant_Groep_Naam] = 'klant_groep_' + Klant_Groep_Code

UPDATE Klant_Incasso
SET [Klant_Incasso_Tenaamstelling_Rekening] = dbo.[FNAnonymizeString]([Klant_Incasso_Tenaamstelling_Rekening]) 

UPDATE USGDagloonGegevensRequest_Log
SET [USGDGR_Status_Message] = null

UPDATE Klant_Loonsommen
SET [Loonsom_Document_Path_Jaar] = dbo.fnIfNotNull([Loonsom_Document_Path_Jaar], 'filename.ext') 

UPDATE Klant_Loonsommen_Trail
SET [Loonsom_Document_Path_Jaar] = dbo.fnIfNotNull([Loonsom_Document_Path_Jaar] , 'filename.ext')

UPDATE Verzekerde_Document
SET [Verzekerde_Document_Naam] = dbo.fnIfNotNull([Verzekerde_Document_Naam], 'filename.ext')

UPDATE WGA_Contract_Document
SET [WGA_Contract_Document_FileName] = dbo.fnIfNotNull([WGA_Contract_Document_FileName], 'filename.ext')

UPDATE WGA_Document
SET [WGA_Document_Naam] = dbo.fnIfNotNull([WGA_Document_Naam], 'filename.ext')

UPDATE Ziekmelding_Document
SET [Ziekmelding_Document_Naam] = dbo.fnIfNotNull([Ziekmelding_Document_Naam], 'filename.ext')

UPDATE Voorschot
SET [Ziekmelding_Voorschot_Naam_Aanvrager] = dbo.[FNAnonymizeString]([Ziekmelding_Voorschot_Naam_Aanvrager])

UPDATE WGA_DossierBeschikking
SET [DossierWGA_Beschikking_Contact_UWV] = dbo.[FNAnonymizeString]([DossierWGA_Beschikking_Contact_UWV])

UPDATE WGA_Verrichtingen
SET [WGA_Verrichtingen_Gebruiker_Naam] = dbo.[FNAnonymizeString]([WGA_Verrichtingen_Gebruiker_Naam])

UPDATE ZM_Verrichtingen
SET[ZM_Verrichtingen_Gebruiker_Naam] = dbo.[FNAnonymizeString](ZM_Verrichtingen_Gebruiker_Naam)

UPDATE ZM_Schadelast_Factuur_Records
SET [SFR_Klant_Vestiging] = dbo.[FNAnonymizeStringAndNo]([SFR_Klant_Vestiging])


-- removing unused tables

truncate table [Logboek]

truncate table [WGA_Logboek]

truncate TABLE Exact_Document_Upload_Log

DROP TABLE [_backup_Gebruiker_20180501]

GO

ENABLE TRIGGER [trigVerzekerde]
ON [Verzekerde];
