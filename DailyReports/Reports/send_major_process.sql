 
  
DECLARE @header VARCHAR(200) 
DECLARE @subject VARCHAR(1000)
DECLARE @to VARCHAR(1000)
DECLARE @cc VARCHAR(1000)
DECLARE @from VARCHAR(1000)   
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @count int
DECLARE @dbname VARCHAR(200)
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @mailprofilename = $(sqlmailprofile_name)  
set @environment =  $(environment)

set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Health_Email_Recipient')
SET @subject = 'Klout7-Reports [Major Process Flag] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Major Process Flag] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
 
 
declare @Major table ( 
	[key] [varchar](500) NOT NULL ,
	[value] [varchar](500) )
	 
insert into @Major
select * from (
SELECT *FROM CONFIGURATION WHERE [KEY] LIKE '%STARTED%' OR [KEY] LIKE '%MAJOR%'  
) a where [value] <> 'false' and Value <> ''



SET @xml = CAST(( SELECT [key] AS 'TD','',[value]   AS 'TD',''
FROM  @Major  
FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))


SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:50%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><tr><th> Disk </th> <th>Size </th></tr>'    


SET @body = @body + @xml +'
      </table><BR><BR><BIG STYLE="FONT-WEIGHT: BOLD;"><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;">SYSTEM GENERATED.</SPAN></BIG></BIG><BR> </body></html>'

set @count = (select count(*) from @Major )
if (@count>0 )
begin
  EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @mailprofilename,
    @recipients = @to,
    @body = @body,
	@body_format= 'HTML',
    @subject = @subject; 
end   
 
