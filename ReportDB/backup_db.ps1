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
    [string]$dbfilename
)

Write-Output "Create credential $($storageaccountname)"
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT * FROM sys.credentials WHERE credential_identity = '$($storageaccountname)') CREATE CREDENTIAL [$($storageaccountname)] WITH IDENTITY='$($storageaccountname)' , SECRET = '$($storageaccountsecret)'"

Write-Output "Create backup $($dbname)"
Invoke-Sqlcmd -Query "BACKUP DATABASE [$($dbname)] TO URL='https://$($storageaccountname).blob.core.windows.net/$($storagecontainername)/$($dbfilename).bak' WITH COPY_ONLY, FORMAT, COMPRESSION, CREDENTIAL = '$($storageaccountname)'" -QueryTimeout 10000