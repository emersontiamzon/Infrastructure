param($dbname, $targetdbname, $sqldatadir, $svcusername, $tenant, $environment,$documentservername)

$currentdir = $PSScriptRoot

Write-Output "Restore DB"
Invoke-Sqlcmd -Query "ALTER DATABASE [$($targetdbname)] SET MULTI_USER WITH ROLLBACK IMMEDIATE"
Invoke-Sqlcmd -Query "ALTER DATABASE [$($targetdbname)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
Invoke-Sqlcmd -Query "ALTER DATABASE [$($targetdbname)] SET MULTI_USER WITH ROLLBACK IMMEDIATE"
Invoke-Sqlcmd -Query "RESTORE DATABASE [$($targetdbname)] FROM DISK = '$($currentdir)\db\$($dbname).bak' WITH MOVE 'Acture' TO '$($sqldatadir)\$($targetdbname).mdf', MOVE 'Acture_log' TO '$($sqldatadir)\$($targetdbname).ldf', REPLACE" -QueryTimeout 3600
Invoke-Sqlcmd -Query "ALTER DATABASE [$($targetdbname)] SET RECOVERY SIMPLE WITH NO_WAIT"

Write-Output "Remove backup"
Remove-Item "$($currentdir)\db\$($dbname).bak"

$variables= @("tenant = '$tenant'","environment = '$environment'", "documentservername = '$documentservername'") 

Write-Output "Update DB"
Invoke-Sqlcmd -Database "$($targetdbname)" -InputFile "$($currentdir)\sql\migrate_main_v2.sql" -variable $variables
Invoke-Sqlcmd -Database "$($targetdbname)" -InputFile "$($currentdir)\sql\migrate_serviceclient.sql" -variable $variables
Invoke-Sqlcmd -Database "$($targetdbname)" -InputFile "$($currentdir)\sql\migrate_exactonline.sql" -variable $variables

if ($svcusername) {
  Invoke-Sqlcmd -Database "$($targetdbname)" -Query "CREATE USER [$($env:COMPUTERNAME)\$($svcusername)] FOR LOGIN [$($env:COMPUTERNAME)\$($svcusername)]"
  Invoke-Sqlcmd -Database "$($targetdbname)" -Query "ALTER ROLE [db_owner] ADD MEMBER [$($env:COMPUTERNAME)\$($svcusername)]"
}

