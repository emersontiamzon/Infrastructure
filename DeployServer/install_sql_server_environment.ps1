Param (
    [Parameter(Mandatory=$True)]
    [string]$environment,

    [Parameter(Mandatory=$True)]
    [string]$client,
    
    [Parameter(Mandatory=$True)]
    [string]$sqldir,

    [Parameter(Mandatory=$True)]
    [string]$svcuserpwd,

    [Parameter(Mandatory=$True)]
    [string]$AzureFileStorage,

    [Parameter(Mandatory=$True)]
    [string]$AzureUser,

    [Parameter(Mandatory=$True)]
    [string]$AzurePass,

    [Parameter(Mandatory=$True)]
    [string]$SqlServiceUser,

    [Parameter(Mandatory=$True)]
    [string]$SqlServicePass
)

$currentdir = $PSScriptRoot
$svcusername = "$($client)-$($environment)"
$securepwd = ConvertTo-SecureString -String $svcuserpwd -AsPlainText -Force
#$sqldir = "c:\mssql\data"
Write-Output "Setup user"

$getUser = $null

Try {
    Write-Verbose "Searching for $($svcusername)...."
    $getUser = Get-LocalUser $svcusername
    Write-Verbose "User $($svcusername) was found"
}

Catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "User $($svcusername) was not found" | Write-Warning
}

Catch {
    "An unspecifed error occured" | Write-Error
    Exit 
}

 
If (!$getUser) {
    Write-Verbose "Creating User $($svcusername)" #(Example)
    New-LocalUser $svcusername -Password $securepwd -FullName $svcusername -PasswordNeverExpires
    Add-LocalGroupMember -Group "Users" -Member $svcusername
}


#Write-Output "Store Azure file storage credentials"
#$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $svcusername, $securepwd
#Start-Process -WorkingDirectory 'C:\Windows\System32' -FilePath "cmd.exe" -Credential $credential -ArgumentList "/c cmdkey /add:`"$AzureFileStorage`" /user:`"$AzureUser`" /pass:`"$AzurePass`"" -LoadUserProfile -Wait -NoNewWindow

Write-Output  "cmdkey /add:`"$AzureFileStorage`" /user:`"$AzureUser`" /pass:`"$AzurePass`""
cmd.exe /C "cmdkey /add:`"$AzureFileStorage`" /user:`"$AzureUser`" /pass:`"$AzurePass`""

 Write-Output "Creating Database"
New-Item -ItemType Directory -Force -Path "$($sqldir)\"


$securepwd = ConvertTo-SecureString -String $SqlServicePass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $SqlServiceUser, $securepwd
Start-Process -WorkingDirectory 'C:\Windows\System32' -FilePath "cmd.exe" -Credential $credential -ArgumentList "/c cmdkey /add:`"$AzureFileStorage`" /user:`"$AzureUser`" /pass:`"$AzurePass`"" -LoadUserProfile -Wait -NoNewWindow


$checksqluser = Invoke-Sqlcmd -Query "SELECT count(name) FROM [sys].[server_principals] where name like '%$($svcusername)%'"
 if($checksqluser -eq 0)  
 {
    Write-Output "Creating user for the Sql Server"
    Invoke-Sqlcmd -Query "CREATE LOGIN [$($env:COMPUTERNAME)\$($svcusername)] FROM WINDOWS"
    Invoke-Sqlcmd -Query "CREATE USER [$($env:COMPUTERNAME)\$($svcusername)] FOR LOGIN [$($env:COMPUTERNAME)\$($svcusername)]"
    Invoke-Sqlcmd -Query "ALTER ROLE [db_owner] ADD MEMBER [$($env:COMPUTERNAME)\$($svcusername)]"
    Invoke-Sqlcmd -Query "ALTER SERVER ROLE [sysadmin] ADD MEMBER [$($env:COMPUTERNAME)\$($svcusername)]"
 }
 else
 {
    Write-Output "User Already Exist"
 }


Write-Output "Create db's"
function CreateDbWithUser {   
  param( [string]$db )
  $checkdb = Invoke-Sqlcmd -Query "select count(name) value from msdb.[dbo].sysdatabases where name = '$($client)-$($environment)-$($db)' "
  if($checkdb.value -eq 0)
  {
      Invoke-Sqlcmd -Query "CREATE DATABASE [$($client)-$($environment)-$($db)] "
      Invoke-Sqlcmd -Query "ALTER DATABASE [$($client)-$($environment)-$($db)] SET RECOVERY SIMPLE  "
      Invoke-Sqlcmd -Database "$($client)-$($environment)-$($db)" -Query "CREATE USER [$($env:COMPUTERNAME)\$($svcusername)] FOR LOGIN [$($env:COMPUTERNAME)\$($svcusername)]"
      Invoke-Sqlcmd -Database "$($client)-$($environment)-$($db)" -Query "ALTER ROLE [db_owner] ADD MEMBER [$($env:COMPUTERNAME)\$($svcusername)]"
  }
      
}

CreateDbWithUser "acture-main"
CreateDbWithUser "acture-log"
CreateDbWithUser "acture-med"
CreateDbWithUser "acture-mail"
CreateDbWithUser "activasz-main"
CreateDbWithUser "activasz-log"
CreateDbWithUser "activasz-med"
CreateDbWithUser "activasz-mail"


