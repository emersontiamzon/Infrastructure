 

DECLARE @header VARCHAR(200)
DECLARE @subject VARCHAR(1000)
DECLARE @from VARCHAR(1000)
DECLARE @to VARCHAR(1000)
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @dbname VARCHAR(200)
declare @date datetime
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @mailprofilename = $(sqlmailprofile_name) 
set @environment =  $(environment)

DECLARE @NetdaysServiceRunLogs TABLE
(
	Audit_Log_ID INT ,
	Audit_Log_UserName varchar (200) ,
	Audit_Log_DateTime datetime ,
	Audit_Log_TableName varchar ,
	Audit_Log_PropertyName varchar ,
	Audit_Log_Entity_ID int ,
	Audit_Log_Entity_ID_Additional int ,
	Audit_Log_Action varchar (200) ,
	Audit_Log_OldData varchar (200) ,
	Audit_Log_NewData varchar (200)  
)  
 

DECLARE @AuditLog TABLE
(
	Audit_Log_ID INT ,
	Audit_Log_UserName varchar (200) ,
	Audit_Log_DateTime datetime ,
	Audit_Log_TableName varchar ,
	Audit_Log_PropertyName varchar ,
	Audit_Log_Entity_ID int ,
	Audit_Log_Entity_ID_Additional int ,
	Audit_Log_Action varchar (200) ,
	Audit_Log_OldData varchar (200) ,
	Audit_Log_NewData varchar (200)  
)  
 

set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Health_Email_Recipient') 
SET @subject = 'Klout7-Reports [Netdays Run Time] ['+@environment+'] ['+@dbname+'] [' + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Netdays Run Time] ['+@environment+'] ['+@dbname+'] [' + CONVERT(VARCHAR(8), Getdate(), 112) + ']'

set @date = dateadd ( dd,0 ,datediff( dd,0 ,getdate()))
INSERT into @AuditLog 
select * from vwNetdaysServiceRunLogs where Audit_Log_DateTime > @date order by Audit_Log_DateTime



insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='NetDaysCalculationStart' or Audit_Log_Action='NetDaysCalculationend' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='DaywageProcessStart' or Audit_Log_Action='DaywageProcessEnd' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='PaymentOrderProcessStart' or Audit_Log_Action='PaymentOrderProcessEnd' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='USGDaywageRequestStart' or Audit_Log_Action='USGDaywageRequestEnd' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='NetdaysNightlyServiceEnd' or Audit_Log_Action='NetdaysNightlyServiceStart' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='UpdateTravelExpensesStart' or Audit_Log_Action='UpdateTravelExpensesEnd' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='CreateArtikel3031WeekStart' or Audit_Log_Action='CreateArtikel3031WeekEnd' ) order by Audit_Log_DateTime
insert into @NetdaysServiceRunLogs
select * from @AuditLog where (Audit_Log_Action='CreateSubZWContractTasksStart' or Audit_Log_Action='CreateSubZWContractTasksEnd' ) order by Audit_Log_DateTime
				
				 
		
		 



SET @xml = CAST(( SELECT Audit_Log_UserName AS 'TD','',FORMAT(Audit_Log_DateTime,'yyyy-MM-dd HH:mm:ss')   AS 'TD','','',Audit_Log_Action   AS 'TD','' 
FROM  @NetdaysServiceRunLogs  ORDER BY Audit_Log_DateTime ASC
FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))

SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:50%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><tr><th>AuditLog Username</th> <th>AuditLog DateTime</th><th>AuditLog Action</th></tr>'    


SET @body = @body + @xml +'
      </table><BR><BR><BIG STYLE="FONT-WEIGHT: BOLD;"><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;">SYSTEM GENERATED.</SPAN></BIG></BIG><BR> </body></html>'



  EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @mailprofilename,
    @recipients = @to,
    @body = @body,
	@body_format= 'HTML',
    @subject = @subject; 
 