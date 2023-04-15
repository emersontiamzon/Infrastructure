DECLARE @header VARCHAR(200)
DECLARE @subject VARCHAR(1000)
DECLARE @to VARCHAR(1000)
DECLARE @cc VARCHAR(1000)
DECLARE @from VARCHAR(1000)
DECLARE @cur_Run_Nummer INT
DECLARE @end_time VARCHAR(25)
DECLARE @add_time VARCHAR(25)
DECLARE @processby VARCHAR(25)
DECLARE @startdate VARCHAR(25)
DECLARE @get_journal_status VARCHAR(25)
DECLARE @get_factuur_time VARCHAR(25)
DECLARE @get_journal_time VARCHAR(25)
DECLARE @InvoiceRun_Nummer INT
DECLARE @count INT
DECLARE @date VARCHAR(max)
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @dbname VARCHAR(200)
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @mailprofilename = $(sqlmailprofile_name) 
set @environment =  $(environment)

set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Runs_Email_Recipient') 
SET @subject = 'Klout7-Reports [Factuur Runs] ['+@environment+'] ['+@dbname+'] [' + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Factuur Runs] ['+@environment+'] ['+@dbname+'] [' + CONVERT(VARCHAR(8), Getdate(), 112) + ']'

DECLARE @table TABLE (
	Run_Nummer INT
	,Factuurtype VARCHAR(250)
	,Run_Datum VARCHAR(250)
	,[Kwartaal/Maand] VARCHAR(250)
	,TotaalInclBTW DECIMAL(18, 2)
	,Journaal_Debet DECIMAL(18, 2)
	,Journaal_Credit DECIMAL(18, 2)
	,Factuur_Count INT
	,Factuur_Created INT
	,Batch_Status VARCHAR(250)
	,Journaal_Status VARCHAR(250)
	,Document_Status VARCHAR(250)
	,Balanced VARCHAR(50)
	,[Processed by] [varchar](100) NULL
	,[Start Time] [varchar](100) NULL
	,[End Time] [varchar](100) NULL
	)
DECLARE @Audit_Log TABLE (
	[Audit_Log_ID] [int] NOT NULL
	,[Audit_Log_UserName] [varchar](50) NOT NULL
	,[Audit_Log_DateTime] [datetime] NOT NULL
	,[Audit_Log_TableName] [varchar](50) NOT NULL
	,[Audit_Log_PropertyName] [varchar](100) NOT NULL
	,[Audit_Log_Entity_ID] [int] NOT NULL
	,[Audit_Log_Entity_ID_Additional] [int] NULL
	,[Audit_Log_Action] [varchar](30) NOT NULL
	,[Audit_Log_OldData] [varchar](max) NULL
	,[Audit_Log_NewData] [varchar](max) NULL
	)
	 
SET @date = CONVERT(CHAR(08), GetDate() - 7, 112)
 
 
DECLARE c_Users CURSOR FAST_FORWARD
FOR
SELECT InvoiceRun_Nummer
FROM InvoiceRun
WHERE InvoiceRun_Datum >= @date

OPEN c_Users

FETCH NEXT
FROM c_Users
INTO @InvoiceRun_Nummer

WHILE (@@FETCH_STATUS = 0)
BEGIN
	INSERT INTO @table (
		[Run_Nummer]
		,[Factuurtype]
		,[Run_Datum]
		,[Kwartaal/Maand]
		,[TotaalInclBTW]
		,[Journaal_Debet]
		,[Journaal_Credit]
		,[Factuur_Count]
		,[Factuur_Created]
		,[Batch_Status]
		,[Journaal_Status]
		,[Document_Status]
		,[balanced]
		)
	SELECT ir.InvoiceRun_Nummer AS Run_Nummer
		,CASE 
			WHEN kf.FactuurZW_Factuurtype LIKE 'Schadelast%'
				THEN 'Schadelast'
			ELSE kf.FactuurZW_Factuurtype
			END AS Factuurtype
		,ir.InvoiceRun_Datum AS Run_Datum
		,CASE 
			WHEN kf.FactuurZW_Kwartaal IS NULL
				THEN cast(kf.FactuurZW_Maand AS VARCHAR)
			WHEN kf.FactuurZW_Kwartaal = 401
				THEN Substring(kf.FactuurZW_Maand, 0, 5) + ' - Kwartaal 1'
			WHEN kf.FactuurZW_Kwartaal = 402
				THEN Substring(kf.FactuurZW_Maand, 0, 5) + ' - Kwartaal 2'
			WHEN kf.FactuurZW_Kwartaal = 403
				THEN Substring(kf.FactuurZW_Maand, 0, 5) + ' - Kwartaal 3'
			WHEN kf.FactuurZW_Kwartaal = 404
				THEN Substring(kf.FactuurZW_Maand, 0, 5) + ' - Kwartaal 4'
			ELSE ' '
			END AS [Kwartaal/Maand]
		,sum(kf.FactuurZW_TotaalInclBTW) AS TotaalInclBTW
		,CASE 
			WHEN (
					SELECT sum(Journaalpost_Amount_Value)
					FROM Journaalpost
					WHERE Journaalpost_FactuurZW IN (
							SELECT FactuurZW_ID
							FROM Klant_Factuur
							WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
							)
						AND Journaalpost_Amount_Value > 0
					) IS NULL
				THEN 0.00
			ELSE (
					SELECT sum(Journaalpost_Amount_Value)
					FROM Journaalpost
					WHERE Journaalpost_FactuurZW IN (
							SELECT FactuurZW_ID
							FROM Klant_Factuur
							WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
							)
						AND Journaalpost_Amount_Value > 0
					)
			END AS Journaal_Debet
		,CASE 
			WHEN (
					SELECT sum(Journaalpost_Amount_Value)
					FROM Journaalpost
					WHERE Journaalpost_FactuurZW IN (
							SELECT FactuurZW_ID
							FROM Klant_Factuur
							WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
							)
						AND Journaalpost_Amount_Value < 0
					) IS NULL
				THEN 0.00
			ELSE (
					SELECT sum(Journaalpost_Amount_Value)
					FROM Journaalpost
					WHERE Journaalpost_FactuurZW IN (
							SELECT FactuurZW_ID
							FROM Klant_Factuur
							WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
							)
						AND Journaalpost_Amount_Value < 0
					)
			END AS Journaal_Credit
		,(
			SELECT count(*)
			FROM Klant_Factuur
			WHERE FactuurZW_InvoiceRun = ir.InvoiceRun_Nummer
			) AS Factuur_Count
		,(
			SELECT count(*)
			FROM Klant_Factuur
			WHERE FactuurZW_InvoiceRun = ir.InvoiceRun_Nummer
				AND FactuurZW_Koppeling IS NOT NULL
			) AS Factuur_Created
		,CASE 
			WHEN ir.InvoiceRun_Factuurbestand IS NULL
				THEN 'Batch Not Created'
			ELSE 'Batch is created'
			END AS Batch_Status
		,CASE 
			WHEN (ir.InvoiceRun_Journaal_Status = 1)
				THEN 'Nog Uit Te Voeren'
			WHEN (ir.InvoiceRun_Journaal_Status = 2)
				THEN 'Gestart'
			WHEN (ir.InvoiceRun_Journaal_Status = 3)
				THEN 'Invalide Bestand'
			WHEN (ir.InvoiceRun_Journaal_Status = 4)
				THEN 'Communicatie fout'
			WHEN (ir.InvoiceRun_Journaal_Status = 5)
				THEN 'Uitgevoerd'
			END AS Journaal_Status
		,CASE 
			WHEN (ir.InvoiceRun_Document_Status = 1)
				THEN 'Nog Uit Te Voeren'
			WHEN (ir.InvoiceRun_Document_Status = 2)
				THEN 'Gestart'
			WHEN (ir.InvoiceRun_Document_Status = 3)
				THEN 'Invalide Bestand'
			WHEN (ir.InvoiceRun_Document_Status = 4)
				THEN 'Communicatie fout'
			WHEN (ir.InvoiceRun_Document_Status = 5)
				THEN 'Uitgevoerd'
			END AS Document_Status
		,CASE 
			WHEN (
					(
						SELECT sum(Journaalpost_Amount_Value)
						FROM Journaalpost
						WHERE Journaalpost_FactuurZW IN (
								SELECT FactuurZW_ID
								FROM Klant_Factuur
								WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
								)
							AND Journaalpost_Amount_Value > 0
						) + (
						SELECT sum(Journaalpost_Amount_Value)
						FROM Journaalpost
						WHERE Journaalpost_FactuurZW IN (
								SELECT FactuurZW_ID
								FROM Klant_Factuur
								WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
								)
							AND Journaalpost_Amount_Value < 0
						)
					) = 0
				THEN 'Yes'
			WHEN (
					(
						SELECT sum(Journaalpost_Amount_Value)
						FROM Journaalpost
						WHERE Journaalpost_FactuurZW IN (
								SELECT FactuurZW_ID
								FROM Klant_Factuur
								WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
								)
							AND Journaalpost_Amount_Value > 0
						) + (
						SELECT sum(Journaalpost_Amount_Value)
						FROM Journaalpost
						WHERE Journaalpost_FactuurZW IN (
								SELECT FactuurZW_ID
								FROM Klant_Factuur
								WHERE FactuurZW_InvoiceRun = @InvoiceRun_Nummer
								)
							AND Journaalpost_Amount_Value < 0
						)
					) IS NULL
				THEN 'No Journal'
			ELSE 'Not'
			END balanced
	FROM InvoiceRun ir
	INNER JOIN Klant_Factuur kf ON ir.InvoiceRun_Nummer = kf.FactuurZW_InvoiceRun
	WHERE ir.InvoiceRun_Nummer = @InvoiceRun_Nummer
	GROUP BY ir.InvoiceRun_Nummer
		,kf.FactuurZW_Kwartaal
		,kf.FactuurZW_Maand
		,CASE 
			WHEN kf.FactuurZW_Factuurtype LIKE 'Schadelast%'
				THEN 'Schadelast'
			ELSE kf.FactuurZW_Factuurtype
			END
		,ir.InvoiceRun_Datum
		,CASE 
			WHEN kf.FactuurZW_Kwartaal IS NULL
				THEN kf.FactuurZW_Maand
			ELSE kf.FactuurZW_Kwartaal
			END
		,ir.InvoiceRun_Factuurbestand
		,ir.InvoiceRun_Journaalbestand
		,ir.InvoiceRun_Journaal_Status
		,ir.InvoiceRun_Document_Status
	ORDER BY ir.InvoiceRun_Nummer

	FETCH NEXT
	FROM c_Users
	INTO @InvoiceRun_Nummer
END

CLOSE c_Users

DEALLOCATE c_Users

		 

INSERT INTO @Audit_Log
SELECT *
FROM (
	SELECT *
	FROM synauditlog
	WHERE FORMAT(Audit_Log_DateTime, 'yyyyMMdd') >= @date
	) a
WHERE (
		Audit_Log_NewData LIKE '%Schadelast%'
		OR Audit_Log_PropertyName LIKE '%InvoiceRun_%'
		)
	OR (
		Audit_Log_TableName LIKE '%config%'
		AND Audit_Log_PropertyName NOT LIKE '%factur%'
		)

DECLARE c_Run_Nummer CURSOR FAST_FORWARD
FOR
SELECT [Run_Nummer]
FROM @table

OPEN c_Run_Nummer

FETCH NEXT
FROM c_Run_Nummer
INTO @cur_Run_Nummer                                                       

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @get_journal_status = (
			SELECT TOP 1 [Journaal_Status]
			FROM @table
			WHERE [Run_Nummer] = @cur_Run_Nummer
			)

	SET @get_journal_time = (
			SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd')
			FROM @Audit_Log
			WHERE (Audit_Log_PropertyName = 'InvoiceRun_Journaalbestand')
				AND Audit_Log_Entity_ID = @cur_Run_Nummer
			)
	SET @get_factuur_time = (
			SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd')
			FROM @Audit_Log
			WHERE (Audit_Log_PropertyName = 'InvoiceRun_Factuurbestand')
				AND Audit_Log_Entity_ID = @cur_Run_Nummer
			)

	IF (@get_journal_status = 'Nog uit te voeren')
	BEGIN
		SET @end_time = (
				SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
				FROM @Audit_Log
				WHERE (
						Audit_Log_PropertyName = 'InvoiceRun_Factuurbestand'
						OR Audit_Log_PropertyName = 'InvoiceRun_Postbestand'
						)
					AND Audit_Log_Entity_ID = @cur_Run_Nummer
				)
		SET @add_time = (
				SELECT TOP 1 FORMAT(DATEADD(mi, 2, @end_time), 'yyyy-MM-dd HH:mm:ss')
				)
		SET @processby = (
				SELECT TOP 1 Audit_Log_OldData
				FROM @Audit_Log
				WHERE Audit_Log_DateTime >= @end_time
					AND Audit_Log_PropertyName = 'MajorProcessBy'
					AND len(Audit_Log_OldData) > 0
				)
		SET @startdate = (
				SELECT TOP 1  FORMAT(CAST(Audit_Log_OldData as Datetime), 'yyyy-MM-dd HH:mm:ss') 
				FROM @Audit_Log
				WHERE Audit_Log_DateTime >= @end_time
					AND Audit_Log_PropertyName = 'MajorProcessDate'
					AND len(Audit_Log_OldData) > 0
				)

		UPDATE @table
		SET [Start Time] = CASE 
				WHEN @startdate IS NULL
					THEN ' '
				ELSE @startdate
				END
			,[end Time] = CASE 
				WHEN @end_time IS NULL
					THEN ''
				ELSE @end_time
				END
			,[Processed by] = CASE 
				WHEN @processby IS NULL
					THEN ' '
				ELSE @processby
				END
		WHERE [Run_Nummer] = @cur_Run_Nummer
	END
	ELSE
	BEGIN
		SET @end_time = (
				SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
				FROM @Audit_Log
				WHERE (Audit_Log_PropertyName = 'InvoiceRun_Journaalbestand')
					AND Audit_Log_Entity_ID = @cur_Run_Nummer
				)
		SET @add_time = (
				SELECT TOP 1 FORMAT(DATEADD(mi, 2, @end_time), 'yyyy-MM-dd HH:mm:ss')
				)
		SET @processby = (
				SELECT TOP 1 Audit_Log_OldData
				FROM @Audit_Log
				WHERE Audit_Log_DateTime >= @end_time
					AND Audit_Log_PropertyName = 'MajorProcessBy'
					AND len(Audit_Log_OldData) > 0
				)

		IF (@get_journal_time = @get_factuur_time)
		BEGIN
			SET @end_time = (
					SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
					FROM @Audit_Log
					WHERE (Audit_Log_PropertyName = 'InvoiceRun_Journaalbestand')
						AND Audit_Log_Entity_ID = @cur_Run_Nummer
					)
			SET @add_time = (
					SELECT TOP 1 FORMAT(DATEADD(mi, 2, @end_time), 'yyyy-MM-dd HH:mm:ss')
					)
			SET @startdate = (
					SELECT TOP 1  FORMAT(CAST(Audit_Log_OldData as Datetime), 'yyyy-MM-dd HH:mm:ss')
					FROM @Audit_Log
					WHERE Audit_Log_DateTime >= @end_time
						AND Audit_Log_PropertyName = 'MajorProcessDate'
						AND len(Audit_Log_OldData) > 0
					)
			SET @processby = (
					SELECT TOP 1 Audit_Log_OldData
					FROM @Audit_Log
					WHERE Audit_Log_DateTime >= @end_time
						AND Audit_Log_PropertyName = 'MajorProcessBy'
						AND len(Audit_Log_OldData) > 0
					)
		END
		ELSE
		BEGIN
			SET @end_time = (
					SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
					FROM @Audit_Log
					WHERE (
							Audit_Log_PropertyName = 'InvoiceRun_Factuurbestand'
							OR Audit_Log_PropertyName = 'InvoiceRun_Postbestand'
							)
						AND Audit_Log_Entity_ID = @cur_Run_Nummer
					)
			SET @add_time = (
					SELECT TOP 1 FORMAT(DATEADD(mi, 2, @end_time), 'yyyy-MM-dd HH:mm:ss')
					)
			SET @processby = (
					SELECT TOP 1 Audit_Log_OldData
					FROM @Audit_Log
					WHERE Audit_Log_DateTime >= @end_time
						AND Audit_Log_PropertyName = 'MajorProcessBy'
						AND len(Audit_Log_OldData) > 0
					)
			SET @startdate = (
					SELECT TOP 1  FORMAT(CAST(Audit_Log_OldData as Datetime), 'yyyy-MM-dd HH:mm:ss')
					FROM @Audit_Log
					WHERE Audit_Log_DateTime >= @end_time
						AND Audit_Log_PropertyName = 'MajorProcessDate'
						AND len(Audit_Log_OldData) > 0
					)
		 
		END

		SET @end_time = (
				SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
				FROM @Audit_Log
				WHERE (
						Audit_Log_PropertyName = 'InvoiceRun_Factuurbestand'
						OR Audit_Log_PropertyName = 'InvoiceRun_Postbestand'
						)
					AND Audit_Log_Entity_ID = @cur_Run_Nummer
				)
		SET @add_time = (
				SELECT TOP 1 FORMAT(DATEADD(mi, 2, @end_time), 'yyyy-MM-dd HH:mm:ss')
				)
		SET @startdate = (
				SELECT TOP 1 FORMAT(CAST(Audit_Log_OldData as Datetime), 'yyyy-MM-dd HH:mm:ss')
				FROM @Audit_Log
				WHERE Audit_Log_DateTime >= @end_time
					AND Audit_Log_PropertyName = 'MajorProcessDate'
					AND len(Audit_Log_OldData) > 0
				)
		SET @end_time = (
				SELECT TOP 1 FORMAT(Audit_Log_DateTime, 'yyyy-MM-dd HH:mm:ss')
				FROM @Audit_Log
				WHERE (Audit_Log_PropertyName = 'InvoiceRun_Journaalbestand')
					AND Audit_Log_Entity_ID = @cur_Run_Nummer
				)

		UPDATE @table
		SET [Start Time] = CASE 
				WHEN @startdate IS NULL
					THEN ' '
				ELSE @startdate
				END
			,[end Time] = CASE 
				WHEN @end_time IS NULL
					THEN ''
				ELSE @end_time
				END
			,[Processed by] = CASE 
				WHEN @processby IS NULL
					THEN ' '
				ELSE @processby
				END
		WHERE [Run_Nummer] = @cur_Run_Nummer
	END

	FETCH NEXT
	FROM c_Run_Nummer
	INTO @cur_Run_Nummer
END

CLOSE c_Run_Nummer

DEALLOCATE c_Run_Nummer

  
  

SET @xml = CAST(( SELECT Run_Nummer  AS 'TD','',Factuurtype   AS 'TD','',
	Run_Datum  AS 'TD','', [Kwartaal/Maand]  AS 'TD','',TotaalInclBTW  AS 'TD_R1','',  Journaal_Debet  AS 'TD_R1','',    
	Abs(Journaal_Credit)  AS 'TD_R1','',Factuur_Count  AS 'TD_R1','',  Factuur_Created  AS 'TD_R1','',  Batch_Status AS 'TD','',
	Journaal_Status AS 'TD','', Document_Status AS 'TD','',  Balanced AS 'TD_C1','',  [Processed by]AS 'TD','',  [Start Time] AS 'TD','',  
	[End Time] AS 'TD'   FROM  @table    FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))


SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:100%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><TH>Run Nummer </TH> <TH>Factuurtype </TH> <TH width="7%">Run Datum </TH> <TH>Kwartaal/Maand </TH> <TH width="7%">Totaal Inclusief BTW </TH>
	  <TH width="7%">Journaal Debet </TH> <TH width="7%">Journaal Credit </TH> <TH width="7%">Aantal Facturen</TH> <TH width="7%">Aantal Facturen Gecreerd </TH> <TH width="7%">Batch Status </TH>
	  <TH width="7%">Journaal Status </TH> <TH width="7%">Document Status </TH> <TH width="7%">Journaal in Balance</TH> <TH width="7%">Uitgevoerd Door</TH> <TH width="7%">Begin Tijd</TH> <TH width="7%">Eind Tijd</TH> </TR>'    
	  
set @xml = replace(@xml,'<TD_R1>','<TD align="right">') 
set @xml = replace(@xml,'</TD_R1>','</TD>')
set @xml = replace(@xml,'<TD_C1>','<TD align="center">') 
set @xml = replace(@xml,'</TD_C1>','</TD>')

SET @body = @body + @xml +'
      </table><BR><BR><BIG STYLE="FONT-WEIGHT: BOLD;"><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;">SYSTEM GENERATED.</SPAN></BIG></BIG><BR> </body></html>'

	      
		   
set @count =(select count(*) from @table)

if(@count > 0)
begin
  EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @mailprofilename,
    @recipients = @to,
    @body = @body,
	@body_format= 'HTML',
    @subject = @subject; 
end  
   
 
 
  