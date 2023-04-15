
declare @Runno int
declare @GetRundate varchar(10)
declare @Date int
declare @journal int
declare @Bestand int
declare @Run  int
declare @RunNummer int
declare @Rundate varchar(10)
declare @journal_Status varchar(100)
declare @Bestand_status varchar(100)
declare @Run_Type varchar(100)
declare @verlonings_record int
declare @payslip_created int
declare @verlonings_Credit decimal(18,2)
declare @verlonings_Debit  decimal(18,2)
declare @verlonings_Balanced  varchar(50)
declare @verlonings_To_paid decimal(18,2)
declare @verlonings_Payment decimal(18,2)
declare @verlonings_Sepa decimal(18,2)
declare @Verlonings_Run_Type  int
declare @xml nvarchar(MAX)
declare @body nvarchar(MAX)
declare @header varchar(200) 
declare @subject varchar(1000)
declare @to varchar(1000)
declare @cc varchar(1000)
declare @from varchar(1000)
declare @dbname varchar(200) 
declare @count  int
declare @journal_starttime datetime 
declare @verloning_starttime datetime 
declare @Cur_Run_Nummer int
declare @Cur_starttime varchar(25)
declare @Cur_runtype varchar(25)
declare @end_time varchar(25) 
declare @processby varchar(25)
declare @starttime varchar(25)
declare @get_journal_status varchar(25)
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @mailprofilename = $(sqlmailprofile_name)  
set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
set @environment =  $(environment)
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Runs_Email_Recipient') 
SET @subject = 'Klout7-Reports [Uitkeringen Runs] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Uitkeringen Runs] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']' 
Declare @table table
(  
[RunNummer] int,
[Rundate] varchar(10),
[Runtype] varchar(max),
[Journal_Status] varchar(100),
[Bestand_Status] varchar(100),
[Verlonings_Record] int,
[Payslip_Created] int,
[Verlonings_Credit] decimal(18,2),
[Verlonings_Debit]  decimal(18,2),
[Verlonings_Balanced] varchar(20),
[Verlonings_To_Paid] decimal(18,2),
[Verlonings_Payment] decimal(18,2),
[Verlonings_Sepa] decimal(18,2),
[Processed by] [varchar](100) NULL,
[Start Time]  [varchar](100) NULL,
[End Time]  [varchar](100) NULL
)



 declare   @Audit_Log table (
[Audit_Log_ID] [int]   NOT NULL,
[Audit_Log_UserName] [varchar](50) NOT NULL ,
[Audit_Log_DateTime] [datetime] NOT NULL,
[Audit_Log_TableName] [varchar](50) NOT NULL,
[Audit_Log_PropertyName] [varchar](100) NOT NULL ,
[Audit_Log_Entity_ID] [int] NOT NULL ,
[Audit_Log_Entity_ID_Additional] [int] NULL,
[Audit_Log_Action] [varchar](30) NOT NULL,
[Audit_Log_OldData] [varchar](max) NULL,
[Audit_Log_NewData] [varchar](max) NULL)
 
 
 
set  @GetRundate = CONVERT(char(08), GETDATE() -7,112)
  
DECLARE c_Users CURSOR FAST_FORWARD FOR             
select Verlonings_Run_No from Verlonings_Run where format(Verlonings_Run_Datum,'yyyyMMdd')  >= @GetRundate      
OPEN c_Users                   
       FETCH NEXT FROM c_Users INTO @Runno
                                                                  
              WHILE (@@FETCH_STATUS =0)                  
              BEGIN                   
			         
                    set @verloning_starttime= (select  Verlonings_Run_Datum  from Verlonings_Run where Verlonings_Run_No = @Runno)                        
                    set  @Verlonings_Run_Type  = (select Verlonings_Run_Type from Verlonings_Run where Verlonings_Run_No = @Runno) 
                    if (@Verlonings_Run_Type <> 20)
                    begin 
                        set @journal = (select Verlonings_Run_Journaal_Status from Verlonings_Run where verlonings_run_no = @Runno)
                        set @Bestand = (select Verlonings_Run_Betalings_Bestand_Status  from Verlonings_Run where verlonings_run_no = @Runno)
                        set @Run = (select Verlonings_Run_Type   from Verlonings_Run where verlonings_run_no = @Runno)
                        if(@journal = 1)
                        begin
                                set @journal_Status  = 'Nog uit te voeren'
                        end
                        else if(@journal = 2)
                        begin
                                set @journal_Status  = 'Gestart'
                        end
                        else if(@journal = 3)
                        begin
                                set @journal_Status  = 'InvalideBestand'
                        end
                        else if(@journal = 4)
                        begin
                                set @journal_Status  = 'Communicatiefout'
                        end
                        else if(@journal = 5)
                        begin
                                set @journal_Status  = 'Uitgevoerd'
                        end
                        if(@Bestand =1 and @Run = 15)
                        begin
                        set @Bestand_status = 'Te betalen'
                        end
						else if(@Bestand =1 and @Run = 18)
						begin
						set @Bestand_status = 'Niet Vantoepassing'
						end
						else if(@Bestand =1 and @Run = 20)
						begin
						set @Bestand_status = 'Te betalen'
						end
                        else if(@Bestand =2 )
                        begin
                        set @Bestand_status = 'Betaald'
                        end
                        if (@Run = 15)
                        begin
                        set @Run_Type = 'Uitkeringen'
                        end
                        else if (@Run = 18)
                        begin
                        set @Run_Type = 'UitkeringenTerugboeken'
                        end
                        else if (@Run = 20)
                        begin
                        set @Run_Type = 'WgaUitkeringen'
                        end 
                        select @RunNummer =  Verlonings_Run_No ,@Rundate = CONVERT(char(08), Verlonings_Run_Datum,112) from Verlonings_Run where verlonings_run_no = @Runno 
						select @verlonings_record =  count(*)  from zw_Verzekerde_Verloning where Verloning_Run_No = @Runno
                        select @payslip_created = count(*)  from verzekerde_uitkeringsspecificatie where verzekerde_uitkeringsspecificatie_runnr = @Runno
                        select @verlonings_Debit = case when sum (isnull(jv_debet,0)) is null then 0.00 else sum (isnull(jv_debet,0))  end  , @verlonings_Credit = case when sum (isnull(jv_credit,0))  is null then 0.00 else  sum (isnull(jv_credit,0)) end  from zw_Verloning_Journaalpost where jv_run_no = @Runno
						select @verlonings_Balanced =  case when sum (isnull(jv_debet,0))- sum (isnull(jv_credit,0)) = 0 then 'Yes'   when sum (isnull(jv_debet,0))- sum (isnull(jv_credit,0)) is null then 'No Journal' else 'No' end from zw_Verloning_Journaalpost where jv_run_no = @Runno
                        select @verlonings_To_paid = case when  sum (isnull(jv_credit,0))  is null then 0.00 else  sum (isnull(jv_credit,0))  end   from zw_Verloning_Journaalpost where jv_run_no = @Runno and jv_grootboek_rekening = 2000
                        select @verlonings_Payment = case when  sum(isnull(Verloning_Netto_Betaald,0)) is null then 0.00 else  sum(isnull(Verloning_Netto_Betaald,0))  end    from zw_verzekerde_verloning where Verloning_Run_No = @Runno
                        select @verlonings_Sepa =  case when sum (isnull(sepa_instamt,0))  is null then 0.00 else sum (isnull(sepa_instamt,0))  end   from zw_Verloning_Sepa where Sepa_Verloning_Run_No = @Runno
 
                        insert into @table([RunNummer],[Rundate],[Runtype] ,[Journal_Status],[Bestand_Status],[Verlonings_Record] ,[Payslip_Created] ,[Verlonings_Credit],[Verlonings_Debit] ,  [Verlonings_Balanced]  ,[Verlonings_To_Paid] ,[Verlonings_Payment] ,[Verlonings_Sepa],[Start Time] )
                        select @RunNummer ,@Rundate, @Run_Type,@journal_Status ,@Bestand_status ,@verlonings_record ,@payslip_created  ,@verlonings_Credit ,@verlonings_Debit   ,@verlonings_Balanced    ,@verlonings_To_paid ,@verlonings_Payment ,@verlonings_Sepa ,FORMAT(@verloning_starttime , 'yyyy-MM-dd HH:mm:ss')
                                          
                                     
                    end
                else if (@Verlonings_Run_Type = 20)
                begin  
                    set @journal = (select Verlonings_Run_Journaal_Status from Verlonings_Run where verlonings_run_no = @Runno)
                    set @Bestand = (select Verlonings_Run_Betalings_Bestand_Status  from Verlonings_Run where verlonings_run_no = @Runno)
                    set @Run = (select Verlonings_Run_Type   from Verlonings_Run where verlonings_run_no = @Runno)
                    if(@journal = 1)
                    begin
                        set @journal_Status  = 'Nog uit te voeren'
                    end
                    else if(@journal = 2)
                    begin
                        set @journal_Status  = 'Gestart'
                    end
                    else if(@journal = 3)
                    begin
                            set @journal_Status  = 'InvalideBestand'
                    end
                    else if(@journal = 4)
                    begin
                            set @journal_Status  = 'Communicatiefout'
                    end
                    else if(@journal = 5)
                    begin
                            set @journal_Status  = 'Uitgevoerd'
                    end
                    if(@Bestand =1 and @Run = 15)
                    begin
						set @Bestand_status = 'Te betalen'
                    end
					else if(@Bestand =1 and @Run = 18)
                    begin
						set @Bestand_status = 'Niet Vantoepassing'
                    end
					else if(@Bestand =1 and @Run = 20)
                    begin
						set @Bestand_status = 'Te betalen'
                    end
                    else if(@Bestand =2 )
                    begin
						set @Bestand_status = 'Betaald'
                    end
                    if (@Run = 15)
                    begin
						set @Run_Type = 'Uitkeringen'
                    end
                    else if (@Run = 18)
                    begin
						set @Run_Type = 'UitkeringenTerugboeken'
                    end
                    else if (@Run = 20)
                    begin
						set @Run_Type = 'WgaUitkeringen'
                    end 
                    select @RunNummer =  Verlonings_Run_No ,@Rundate = CONVERT(char(08), Verlonings_Run_Datum,112) from Verlonings_Run where verlonings_run_no = @Runno 
                    select @verlonings_record =  count(*)  from wga_Verzekerde_Verloning where Verloning_Run_No = @Runno
                    select @payslip_created = count(*)  from verzekerde_uitkeringsspecificatie where verzekerde_uitkeringsspecificatie_runnr = @Runno
                    select @verlonings_Debit = case when sum (isnull(jv_debet,0)) is null then 0.00 else sum (isnull(jv_debet,0)) end    , @verlonings_Credit = case when sum (isnull(jv_credit,0)) is null then 0.00 else  sum (isnull(jv_credit,0)) end  from wga_Verloning_Journaalpost where jv_run_no = @Runno
					select @verlonings_Balanced =  case when sum (isnull(jv_debet,0))- sum (isnull(jv_credit,0)) = 0 then 'Yes' when sum (isnull(jv_debet,0))- sum (isnull(jv_credit,0)) is null then 'No Journal' else 'No' end from wga_Verloning_Journaalpost where jv_run_no = @Runno
				    select @verlonings_To_paid =  case when sum (isnull(jv_credit,0)) is null then 0.00 else sum (isnull(jv_credit,0)) end   from wga_Verloning_Journaalpost where jv_run_no = @Runno and jv_grootboek_rekening = 2000
                    select @verlonings_Payment =  case when sum(isnull(Verloning_Netto_Betaald,0)) is null then 0.00 else sum(isnull(Verloning_Netto_Betaald,0)) end   from wga_verzekerde_verloning where Verloning_Run_No = @Runno
                    select @verlonings_Sepa =  case when sum (isnull(sepa_instamt,0))  is null then 0.00 else  sum (isnull(sepa_instamt,0)) end   from wga_Verloning_Sepa where Sepa_Verloning_Run_No = @Runno
 
                    insert into @table([RunNummer],[Rundate],[Runtype] ,[Journal_Status],[Bestand_Status],[Verlonings_Record] ,[Payslip_Created] ,[Verlonings_Credit],[Verlonings_Debit] ,  [Verlonings_Balanced]  ,[Verlonings_To_Paid] ,[Verlonings_Payment] ,[Verlonings_Sepa],[Start Time] )
                    select  @RunNummer ,@Rundate, @Run_Type,@journal_Status ,@Bestand_status ,@verlonings_record ,@payslip_created  ,@verlonings_Credit ,@verlonings_Debit   ,@verlonings_Balanced    ,@verlonings_To_paid ,@verlonings_Payment ,@verlonings_Sepa ,FORMAT(@verloning_starttime , 'yyyy-MM-dd HH:mm:ss')

                end
                                                                                                       
                                                                                
       FETCH NEXT FROM c_Users INTO @Runno                   
       END            
                                 
CLOSE c_Users             
                                  
DEALLOCATE c_Users
 
insert    INTO @Audit_Log
select *
 from (select * from synAuditLog
where
  FORMAT(Audit_Log_DateTime, 'yyyyMMdd')  >=
 @GetRundate) a where (Audit_Log_NewData like '%Uitkeringsspecificaties%' or Audit_Log_PropertyName like '%Verlonings_Run_%') or  (Audit_Log_TableName like '%config%' and Audit_Log_PropertyName not like '%factur%' )
   

     DECLARE c_Run_Nummer CURSOR FAST_FORWARD FOR                                              
       select [RunNummer],[Start Time],Runtype  from @table                                           
               OPEN c_Run_Nummer                                     
                      FETCH NEXT FROM c_Run_Nummer INTO @cur_Run_Nummer,@Cur_starttime,@Cur_runtype                                                  
                           WHILE (@@FETCH_STATUS =0)                                            
                                  BEGIN   
									select @get_journal_status = (select [Journal_Status]  from @table where [RunNummer] =  @cur_Run_Nummer)	
									
									if(@get_journal_status =  'Nog uit te voeren' )
									begin
										set @end_time = ( select top 1 FORMAT(Audit_Log_DateTime , 'yyyy-MM-dd HH:mm:ss')  from @Audit_Log where (Audit_Log_PropertyName = 'Verlonings_Run_Specificaties_bestand')  and Audit_Log_Entity_ID = @cur_Run_Nummer order by Audit_Log_DateTime asc) 
										set @processby = (select top 1 Audit_Log_OldData  from @Audit_Log where Audit_Log_DateTime >= @end_time   and Audit_Log_PropertyName= 'MajorProcessBy' order by Audit_Log_DateTime asc)
										update @table set [Processed by] = case when @processby is null then ' ' else @processby end , [End Time] = case when @end_time is null then ' ' else @end_time end  where RunNummer = @cur_Run_Nummer
									end
									else if(@get_journal_status <>  'Nog uit te voeren'  )
									begin
										set @end_time = ( select top 1 FORMAT(Audit_Log_DateTime , 'yyyy-MM-dd HH:mm:ss')  from @Audit_Log where (Audit_Log_PropertyName = 'Verlonings_Run_Journaal_Status')  and Audit_Log_Entity_ID = @cur_Run_Nummer order by Audit_Log_DateTime asc) 
										set @processby = (select top 1 Audit_Log_OldData  from @Audit_Log where Audit_Log_DateTime >= @end_time   and Audit_Log_PropertyName= 'MajorProcessBy' order by Audit_Log_DateTime asc)
										update @table set [Processed by] = case when @processby is null then ' ' else @processby end , [End Time] = case when @end_time is null then ' ' else @end_time end  where RunNummer = @cur_Run_Nummer
									end              
									
                                FETCH NEXT FROM c_Run_Nummer INTO @cur_Run_Nummer,@Cur_starttime,@Cur_runtype                                      
                           END                                                               
              CLOSE c_Run_Nummer                                                                      
       DEALLOCATE c_Run_Nummer  
 
 
SET @xml = CAST(( SELECT RunNummer  AS 'TD','',Rundate   AS 'TD','',
	Runtype  AS 'TD','', Journal_Status  AS 'TD','',Bestand_Status  AS 'TD','',  Verlonings_Record  AS 'TD_R1','',    
	Payslip_Created  AS 'TD_R1','',Verlonings_Credit  AS 'TD_R1','',   Verlonings_Debit AS 'TD_R1','',  Verlonings_Balanced  AS 'TD_C1','',  Verlonings_To_Paid AS 'TD_R1','',
	Verlonings_Payment AS 'TD_R1','', Verlonings_Sepa AS 'TD_R1','',  [Processed by]AS 'TD','',  [Start Time] AS 'TD', '',  
	[End Time] AS 'TD',' '  FROM  @table    FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))

	
SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:100%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><TR> <TH>RunNummer </TH> <TH>Run Datum</TH> <TH>Run Type</TH> <TH>Journaal Status</TH> <TH width="7%">Betaal Bestand Status</TH> <TH width="7%">Antaal Verlonings Record</TH> <TH width="7%">Antaal Uitkerings Specificaties</TH>
<TH width="7%">Verloning Credit</TH> <TH width="7%">Verloning Debet</TH> <TH width="7%">Journaal in Balance </TH> <TH width="7%">Verloning To Paid</TH> <TH width="7%">Verloning Betaling </TH> <TH width="7%">Verloning Sepa</TH>
<TH width="7%">Uitgevoerd Door</TH> <TH width="7%">Begin Tijd</TH> <TH width="7%">Eind Tijd</TH></TR>'    


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
     