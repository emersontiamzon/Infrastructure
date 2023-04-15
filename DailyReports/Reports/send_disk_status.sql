 
DECLARE @header VARCHAR(200) 
DECLARE @subject VARCHAR(1000)
DECLARE @to VARCHAR(1000)
DECLARE @cc VARCHAR(1000)
DECLARE @from VARCHAR(1000)
DECLARE @bodytype VARCHAR(10) 
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @dbname VARCHAR(200) 
DECLARE @mailprofilename VARCHAR(200) 
DECLARE @environment VARCHAR(200) 


set @mailprofilename = $(sqlmailprofile_name)
set @dbname =  REPLACE($(sqldbname),'ActureBedrijven','ActivaSZ') 
set @environment =  $(environment)
SET @bodytype = 'htmlbody'
SET @from = 'NO-REPLY@klout7.com'
SET @to = (SELECT [Value] FROM dbo.Configuration WHERE [Key] = 'Daily_Health_Email_Recipient')
SET @subject = 'Klout7-Reports [Disk Status] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
SET @header  = 'Klout7-Reports [Disk Status] ['+@environment+']['+@dbname+'] ['
               + CONVERT(VARCHAR(8), Getdate(), 112) + ']'
 


 
declare @TblDiskSize table
(
	[disk] varchar(10),
	[Size] varchar(10),
	[Free]varchar(10)
)

declare @TblDiskFreeSize table
(
	[disk] varchar(10), 
	[Free] decimal(18,2)
)
declare @table table([text] varchar(200))
declare @query nvarchar(2000)
insert into @table 
	exec xp_cmdshell 'wmic logicaldisk get size,caption'
		 


insert into @TblDiskSize([disk],[Size])
select   SUBSTRING ([text],0,3), cast( ((cast (replace(SUBSTRING ([text],3,len([text])-3),' ','') as float ) /1024)/1024)/1024 as decimal(18,2))  from @table where len([text])>1  and [text] not like '%caption%' and len(REPLACE([text] ,' ','')) > 3

declare @table2 table([text] varchar(200))
insert into @table2
exec  xp_cmdshell 'wmic logicaldisk get freespace,caption' 

insert into @TblDiskFreeSize
select   SUBSTRING ([text],0,3), cast( ((cast (replace(SUBSTRING ([text],3,len([text])-3),' ','') as float ) /1024)/1024)/1024 as decimal(18,2))  from @table2 where len([text])>1  and [text] not like '%caption%' and len(REPLACE([text] ,' ','')) > 3


UPDATE a set a.Free = b.Free from @TblDiskSize a join @TblDiskFreeSize b on a.disk = b.disk  
 

 

SET @xml = CAST(( SELECT [disk] AS 'TD','',[size] + ' GB' AS 'TD_R1','',
      [free] + ' GB' AS 'TD_R1',''
FROM  @TblDiskSize ORDER BY [disk] 
FOR XML PATH('TR'), ELEMENTS ) AS NVARCHAR(MAX))


set @xml = replace(@xml,'<TD_R1>','<TD align="right">') 
set @xml = replace(@xml,'</TD_R1>','</TD>')
SET @body ='<HTML>
   <BODY>
      <BR><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><BIG><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;"><SPAN STYLE="FONT-WEIGHT: BOLD;"> '+@header+'</SPAN></SPAN></BIG></BIG></SPAN><BR><BR> 
      <STYLE TYPE="TEXT/CSS"> TABLE.TFTABLE {FONT-SIZE:12PX;COLOR:#333333;WIDTH:30%;BORDER-WIDTH: 1PX;BORDER-COLOR: #729EA5;BORDER-COLLAPSE: COLLAPSE;} TABLE.TFTABLE TH {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BACKGROUND-COLOR:#ACC8CC;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;TEXT-ALIGN:LEFT;} TABLE.TFTABLE TR {BACKGROUND-COLOR:#FFFFFF;} TABLE.TFTABLE TD {FONT-FAMILY:MONOSPACE;FONT-SIZE:12PX;BORDER-WIDTH: 1PX;PADDING: 8PX;BORDER-STYLE: SOLID;BORDER-COLOR: #729EA5;} </STYLE>
      <TABLE ID="TFHOVER" CLASS="TFTABLE" BORDER="1"><tr><th width="30%"> Disk </th> <th width="30%">Total Size </th> <th width="30%">Free</th></tr>'    


SET @body = @body + @xml +'
      </table><BR><BR><BIG STYLE="FONT-WEIGHT: BOLD;"><BIG><SPAN STYLE="FONT-FAMILY: MONOSPACE;">SYSTEM GENERATED.</SPAN></BIG></BIG><BR> </body></html>'

	   

 
  EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @mailprofilename,
    @recipients = @to,
    @body = @body,
	@body_format= 'HTML',
    @subject = @subject; 

	 