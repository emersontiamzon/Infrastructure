param($dbname,$sqldbname_main,$sqldbname_log,$sqldbname_med,$sqldbname_mail, $sqlmailprofile_name,$environment,$runemailrecipient,$healthemailrecipient)

$currentdir = $PSScriptRoot 



Write-Output "Insert Email Recipients"
$emailvariables = @("runemailrecipient='$runemailrecipient'","healthemailrecipient='$healthemailrecipient'") 
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\insert_email_recipient.sql" -variable $emailvariables

Write-Output "Reports"
$variables= @("sqldbname = '$dbname'","sqldbname_main='$sqldbname_main'","sqldbname_log='$sqldbname_log'","sqldbname_med='$sqldbname_med'","sqldbname_mail='$sqldbname_mail'","sqlmailprofile_name='$sqlmailprofile_name'","environment='$environment'") 
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_database_size.sql" -variable $variables  
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_disk_status.sql" -variable $variables
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_major_process.sql" -variable $variables 
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_netdays_run.sql" -variable $variables -QueryTimeout 3600 
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_factuur_runs.sql" -variable $variables -QueryTimeout 3600 
Invoke-Sqlcmd -Database "$($dbname)" -InputFile "$($currentdir)\reports\send_uitkeringen_runs.sql" -variable $variables -QueryTimeout 3600
