Param (
    [Parameter(Mandatory=$True)]
    [string]$storageaccountname,

    [Parameter(Mandatory=$True)]
    [string]$storageaccountsecret,

    [Parameter(Mandatory=$True)]
    [string]$storagecontainername,

    [Parameter(Mandatory=$True)]
    [string]$dbname,

    [Parameter(Mandatory=$True)]
    [string]$dbfilename,

    [Parameter(Mandatory=$True)]
    [string]$sqldatadir
)

Write-Output "Create credential $($storageaccountname)"
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT * FROM sys.credentials WHERE credential_identity = '$($storageaccountname)') CREATE CREDENTIAL [$($storageaccountname)] WITH IDENTITY='$($storageaccountname)' , SECRET = '$($storageaccountsecret)'"

Write-Output "Disconnect users $($dbname)"
Invoke-Sqlcmd -Query "ALTER DATABASE [$($dbname)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
Invoke-Sqlcmd -Query "ALTER DATABASE [$($dbname)] SET MULTI_USER WITH ROLLBACK IMMEDIATE"
Write-Output "Restore backup $($dbname)"
Invoke-Sqlcmd -Query "RESTORE DATABASE [$($dbname)] FROM URL='https://$($storageaccountname).blob.core.windows.net/$($storagecontainername)/$($dbfilename).bak' WITH MOVE 'Acture' TO '$($sqldatadir)\$($dbname).mdf', MOVE 'Acture_log' TO '$($sqldatadir)\$($dbname).ldf', REPLACE, CREDENTIAL = '$($storageaccountname)'" -QueryTimeout 10000

Invoke-Sqlcmd -Query "ALTER DATABASE [$($dbname)] SET RECOVERY SIMPLE WITH NO_WAIT"

Write-Output "Add report users"
Invoke-Sqlcmd -Database "$($dbname)" -Query "CREATE USER [klout7rapp] FOR LOGIN [klout7rapp]"
Invoke-Sqlcmd -Database "$($dbname)" -Query "CREATE USER [report] FOR LOGIN [report]"

Invoke-Sqlcmd -Database "$($dbname)" -Query "ALTER ROLE [db_datareader] ADD MEMBER [klout7rapp]"
Invoke-Sqlcmd -Database "$($dbname)" -Query "ALTER ROLE [db_datareader] ADD MEMBER [report]"


