Param (
    [Parameter(Mandatory=$True)]
    [string]$SqlServiceUser,

    [Parameter(Mandatory=$True)]
    [string]$SqlServicePass,

    [Parameter(Mandatory=$True)]
    [string]$MailAccountName,
    
    [Parameter(Mandatory=$True)]
    [string]$MailProfileName,
   
    [Parameter(Mandatory=$True)]
    [string]$MailEAddress,

    [Parameter(Mandatory=$True)]
    [string]$MailServerName,

    [Parameter(Mandatory=$True)]
    [string]$MailUserName,
    
    [Parameter(Mandatory=$True)]
    [string]$MailPassword
    
)

$currentdir = $PSScriptRoot

Write-Output "Configure SQL Server"

#STILL NEED TOBE CHECK
#STILL NEED TOBE CHECK
#STILL NEED TOBE CHECK
#give deployment agent access to database
Invoke-Sqlcmd -Query "IF NOT EXISTS(SELECT name FROM [master].[sys].[syslogins] WHERE NAME = 'NT AUTHORITY\SYSTEM') CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS"
Invoke-Sqlcmd -Query "use master ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM]"

#enable Ole Automation and xp_cmdshell, only used while SQL server does disk access
Invoke-Sqlcmd -Query "sp_configure 'show advanced options', 1"
Invoke-Sqlcmd -Query "RECONFIGURE"
Invoke-Sqlcmd -Query "sp_configure 'Ole Automation Procedures', 1"
Invoke-Sqlcmd -Query "RECONFIGURE"
Invoke-Sqlcmd -Query "sp_configure 'xp_cmdshell', 1"
Invoke-Sqlcmd -Query "RECONFIGURE"
Invoke-Sqlcmd -Query "sp_configure 'Database Mail XPs', 1"
Invoke-Sqlcmd -Query "RECONFIGURE"
 

 
# Mailer is commentout    
#$checkMailAcountName = Invoke-Sqlcmd -Query "select count(name) value  from   msdb.[dbo].[sysmail_account] where name = '$($MailAccountName)'"
#$checkMailProfileName = Invoke-Sqlcmd -Query "select count(name) value  from   msdb.[dbo].[sysmail_profile] where name = '$($MailProfileName)'"

#if($checkMailAcountName.value -eq  0)
#{
#    Invoke-Sqlcmd -Query "EXECUTE msdb.dbo.sysmail_add_account_sp @account_name = '$($MailAccountName)', @description = '$($MailAccountName) account', @email_address = '$MailEAddress', @display_name = '$MailAccountName', @mailserver_name = '$MailServerName' , @username = '$MailUserName' , @password = '$MailPassword', @port = 587, @enable_ssl = 1 "
#}
#if($checkMailProfileName.value -eq  0)
#{
#    Invoke-Sqlcmd -Query "EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = '$($MailProfileName)', @description = '$($MailProfileName) profile' "
#    Invoke-Sqlcmd -Query "EXECUTE msdb.dbo.sysmail_add_profileaccount_sp @profile_name = '$($MailProfileName)', @account_name = '$MailAccountName', @sequence_number = 1 " 
#    Invoke-Sqlcmd -Query "EXECUTE msdb.dbo.sysmail_add_principalprofile_sp @profile_name = '$($MailProfileName)', @principal_name = 'public', @is_default = 1"
#}

#set login audit level to "Both failed and successful logins"
$SQLServer		= "(local)"
$AuditLevel		= "All"
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$smo = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "$($SQLServer)"
$smo.AuditLevel = $AuditLevel
$smo.Alter()

#set "force encryption" to true
#$RegKey = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQLServer\SuperSocketNetLib";
#Set-ItemProperty -path $RegKey -name ForceEncryption -value "1";

Write-Output "Downloading Setups"
New-Item -ItemType Directory -Force -Path "$($currentdir)\sources\"

$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/DacFramework.msi","$($currentdir)\sources\DacFramework.msi")

Write-Output "Installing Dac Framework"
Write-Output "/I $($currentdir)\sources\DacFramework.msi /quiet"
Start-Process -NoNewWindow msiexec.exe -Wait -ArgumentList "/I $($currentdir)\sources\DacFramework.msi /quiet"

Write-Output "Create firewall rule"
netsh advfirewall firewall add rule name = SQLPort dir = in protocol = tcp action = allow localport = 1433 remoteip = localsubnet profile = PRIVATE

Write-Output "Run SQL server under service user"
$svc=gwmi win32_service -filter "name='MSSQLSERVER'"
$svc.change($null,$null,$null,$null,$null,$null,".\$($SqlServiceUser)","$($SqlServicePass)",$null,$null,$null)

Restart-Service -Name "MSSQLSERVER"