 
  
DECLARE @header VARCHAR(200) 
DECLARE @subject VARCHAR(1000)
DECLARE @to VARCHAR(1000)
DECLARE @cc VARCHAR(1000)
DECLARE @from VARCHAR(1000) 
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @dbname VARCHAR(200) 
DECLARE @dbname_main VARCHAR(200) 
DECLARE @dbname_log VARCHAR(200) 
DECLARE @dbname_med VARCHAR(200) 
DECLARE @dbname_mail VARCHAR(200) 
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @dbname_main = $(sqldbname_main)
set @dbname_log =  $(sqldbname_log)
set @dbname_med =  $(sqldbname_med)
set @dbname_mail =  $(sqldbname_mail)
set @mailprofilename = $(sqlmailprofile_name)
set @environment =  $(environment)

set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Health_Email_Recipient')
SET @subject = 'Klout7-Reports [Database Size] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Database Size] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'


			    
declare @dbSize table
(
	[database] varchar(100), 
	MDF varchar(100),
	LDF varchar(100),
	[Total Size] varchar(100)
)
 
declare @tbl_ldf table
(
	[database] varchar(100),
	[file name] varchar(1000),
	LDF decimal(18,2)
)
declare @tbl_mdf table
(
	[database] varchar(100),
	[file name] varchar(1000),
	MDF decimal(18,2)
)


insert into @tbl_ldf
SELECT
   b.[name] as [Database], 
   a.physical_Name as [File name],
   cast(a.SIZE * 8 as float)/ 1024  
FROM   sys.master_files a
LEFT OUTER JOIN sys.databases b ON a.database_id = b.database_id
where physical_Name like '%.ldf'
  

insert into @tbl_mdf
SELECT
   b.[name] as [Database], 
   a.physical_Name as [File name],
   cast(a.SIZE * 8 as float)/ 1024  
FROM   sys.master_files a
LEFT OUTER JOIN sys.databases b ON a.database_id = b.database_id
where physical_Name like '%.mdf' and   b.[name] in (''+@dbname_main+'',+@dbname_log+'',+@dbname_med+'',+@dbname_mail+'')
  

  insert into @dbSize
 select a.[database], 
 case when b.mdf > 1024 then cast(cast((b.mdf/1024) as decimal(18,2)) as varchar)+' GB'  else cast(b.mdf  as varchar)+' MB' end,
 case when a.ldf > 1024 then cast(cast((a.ldf/1024) as decimal(18,2)) as varchar)+' GB'  else cast(a.ldf  as varchar)+' MB' end ,  
 case when (b.mdf+a.ldf) > 1024 then cast(cast(((b.mdf+a.ldf) /1024) as decimal(18,2)) as varchar)+' GB'  else cast((b.mdf+a.ldf)   as varchar)+' MB' end
   
 from   @tbl_ldf a join @tbl_mdf b on a.[database] = b.[database] order by b.[database] asc

 

 
SET @xml = CAST(( SELECT [database] AS 'TD','',MDF   AS 'TD_R1','','',LDF   AS 'TD_R1','','',[Total Size]   AS 'TD_R1',''
FROM  @dbSize  
FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))


set @xml = replace(@xml,'<TD_R1>','<TD align="right">') 
set @xml = replace(@xml,'</TD_R1>','</TD>')
SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:50%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><tr><th>Database</th> <th>MDF</th><th>LDF</th><th>Total Size</th></tr>'    


SET @body = @body + @xml +'
      </table><BR><BR><BIG STYLE="FONT-WEIGHT: BOLD;"><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;">SYSTEM GENERATED.</SPAN></BIG></BIG><BR> </body></html>'


  EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @mailprofilename,
    @recipients = @to,
    @body = @body,
	@body_format= 'HTML',
    @subject = @subject; 
  

  
   