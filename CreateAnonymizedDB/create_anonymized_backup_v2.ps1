param($sourcedb, $targetdb, $sqldatadir)

$currentdir = $PSScriptRoot

New-Item -ItemType Directory -Force -Path "$($currentdir)\db\"
New-Item -ItemType Directory -Force -Path "$($currentdir)\app\"

Write-Output "Create backup $($sourcedb)"
Invoke-Sqlcmd -Query "BACKUP DATABASE [$($sourcedb)] TO DISK='$($currentdir)\db\$($targetdb).bak' WITH COPY_ONLY, FORMAT, COMPRESSION" -QueryTimeout 3600

Write-Output "Restore DB"
Invoke-Sqlcmd -Query "RESTORE DATABASE [Temp$($targetdb)] FROM DISK = '$($currentdir)\db\$($targetdb).bak' WITH MOVE 'Acture' TO '$($sqldatadir)\Temp$($targetdb).mdf', MOVE 'Acture_log' TO '$($sqldatadir)\Temp$($targetdb).ldf', REPLACE" -QueryTimeout 3600
Write-Output "Set simple recovery"
Invoke-Sqlcmd -Query "ALTER DATABASE [Temp$($targetdb)] SET RECOVERY SIMPLE WITH NO_WAIT"

Write-Output "Remove backup"
Remove-Item "$($currentdir)\db\$($targetdb).bak"

$variables= @("sqldbname = 'Temp$($targetdb)'") 

Write-Output "Setup Anonymize DB"
#Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\create_main.sql"
#Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\create_bsn.sql"
#Invoke-Sqlcmd -Database "BSNAnonymize" -InputFile "$($currentdir)\sql\create_main.sql"
Write-Output "Execute Anonymize DB"
#Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\anonymize_main.sql" -variable $variables -QueryTimeout 7200
#Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\anonymize_serviceclients.sql"
#Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\migrate_exactonline.sql" -variable $variables
Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\migrate_main_v2.sql" -variable $variables
Invoke-Sqlcmd -Database "Temp$($targetdb)" -InputFile "$($currentdir)\sql\migrate_twofactor.sql" -variable $variables

Write-Output "Shrink DB"
Invoke-Sqlcmd -Query "DBCC SHRINKDATABASE (Temp$($targetdb), 2)" -QueryTimeout 3600

Write-Output "Create backup at $($currentdir)\db\$($targetdb)_anonymized.bak"
Invoke-Sqlcmd -Query "BACKUP DATABASE [Temp$($targetdb)] TO DISK='$($currentdir)\db\$($targetdb)_anonymized.bak' WITH COPY_ONLY, FORMAT, COMPRESSION" -QueryTimeout 3600
Invoke-Sqlcmd -Query "ALTER DATABASE [Temp$($targetdb)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE" -QueryTimeout 3600
Invoke-Sqlcmd -Query "DROP DATABASE [Temp$($targetdb)]" -QueryTimeout 3600



 

#azcopy cp "$($currentdir)\db\$($targetdb)_anonymized.bak"  "https://prechartdevt.file.core.windows.net/prechartdevtfiles/db/$($sas)"
#https://prechartdevt.file.core.windows.net/prechartdevtfiles/db/
#?st=2020-08-12T07%3A12%3A17Z&se=2025-08-13T07%3A12%3A00Z&sp=rcwdl&sv=2018-03-28&sr=s&sig=C57Vf9xnWrowwlM0lVO9qQVL%2B8dyeFI%2FJ%2B3e0AYhHvA%3D
#$webclient = New-Object System.Net.WebClient
#$webclient.DownloadFile("https://prechartdevt.blob.core.windows.net/serverapp/azcopy.exe","c:\az\azcopy.exe")
 
#$variableNameToAdd = "azcopy"
#$variableValueToAdd = "C:\az\"
#[System.Environment]::SetEnvironmentVariable("path", $variableValueToAdd, [System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable("Path", $variableValueToAdd, [System.EnvironmentVariableTarget]::Process)
#[System.Environment]::SetEnvironmentVariable($variableNameToAdd, "C:\az\azcopy.exe", [System.EnvironmentVariableTarget]::User)

