# * YOU MAY HAVE TO RUN THIS COMMAND PRIOR TO RUNNING THIS SCRIPT!
# Set-ExecutionPolicy Bypass -Scope Process

Param (
   [Parameter(Mandatory=$True)]
    [string]$client,

    [Parameter(Mandatory=$True)]
    [string]$environment,

    [Parameter(Mandatory=$True)]
    [string]$svcuserpwd,

    #[Parameter(Mandatory=$True)]
    #[string]$rabbitmqpwd,

    [Parameter(Mandatory=$True)]
    [string]$AzureFileStorage,

    [Parameter(Mandatory=$True)]
    [string]$AzureUser,

    [Parameter(Mandatory=$True)]
    [string]$AzurePass
)


#$serveruser = 'serveradmin' 
#$svcuserpwd ='Prechart2015HP' 
#$rabbitmqpwd= 'test' 
#$AzureFileStorage= 'prechartdevt.file.core.windows.net' 
#$AzureUser ='Azure\prechartdevt' 
#$AzurePass ='AD7OO9eFfRppI+BCLWGuHTHm1R5P4EAVU5CMlrFogIAK37coKBWq7mCQ3yhfVujr8Kt2KIT8JG77iumQ1Vt1Uw=='

$currentdir = $PSScriptRoot
$appdir = "c:\apps"
$rabbitVersion = '3.8.2'
#$svcusername = $serveruser
$svcusername = "$($client)-$($environment)"
$securepwd = ConvertTo-SecureString -String $svcuserpwd -AsPlainText -Force

function Update-Environment {   
    $pathbackup = $env:path
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {   
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }

    Set-Item -Path Env:\PATH -Value $pathbackup
}

function Add-ServiceLogonRight([string] $Username) {
    Write-Host "Enable ServiceLogonRight for $Username"

    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$Username" | sc -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    rm $tmp* -ea 0
}

Write-Output "Enabling IIS"

Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationDevelopment

Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-NetFxExtensibility45

Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-HttpCompressionStatic
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName IIS-ASPNET45

Write-Output "Setup user and folders"

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
    Write-Verbose "Creating User $($svcusername)"  
    New-LocalUser $svcusername -Password $securepwd -FullName $svcusername -PasswordNeverExpires
    Add-LocalGroupMember -Group "Users" -Member $svcusername
    Add-LocalGroupMember -Group "IIS_IUSRS" -Member $svcusername
    Add-LocalGroupMember -Group "Performance Monitor Users" -Member $svcusername
}





New-Item -ItemType Directory -Force -Path "c:\apps"
$acl = Get-Acl $appdir
 $ruleDirection=[System.Security.AccessControl.AccessControlType]"Allow"
 $fileSystemRights = [System.Security.AccessControl.FileSystemRights]"Read, Write"
 $inherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
 $propagation = [system.security.accesscontrol.PropagationFlags]"None"

 $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule(
     $svcusername, $fileSystemRights, $inherit, $propagation, $ruleDirection)
$acl.SetAccessRule($AccessRule)
set-acl $appdir $acl

Add-ServiceLogonRight($svcusername)

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $svcusername, $securepwd
Start-Process -WorkingDirectory 'C:\Windows\System32' -FilePath "cmd.exe" -Credential $credential -ArgumentList "/c cmdkey /add:`"$AzureFileStorage`" /user:`"$AzureUser`" /pass:`"$AzurePass`"" -LoadUserProfile -Wait -NoNewWindow

Write-Output "Downloading Setups"
New-Item -ItemType Directory -Force -Path "$($currentdir)\sources\"

$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/netcore6.exe","$($currentdir)\sources\netcore6.exe")
#$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/erlang_22.2.exe","$($currentdir)\sources\erlang.exe")
#$webclient.DownloadFile("https://prechartdeployment.blob.core.windows.net/setup/rabbitmq_$($rabbitVersion).exe","$($currentdir)\sources\rabbitmq.exe")
$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/clamav.zip","$($currentdir)\sources\clamav.zip")


Write-Output "Installing azcopy"

New-Item -ItemType Directory -Force -Path "c:\az\"
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/azcopy.exe","c:\az\azcopy.exe")

Write-Output "Installing dotnetcore"
Start-Process -NoNewWindow -FilePath "$($currentdir)\sources\netcore6.exe"  -ArgumentList "/S" -Wait  

#Write-Output "Installing erlang"
#Start-Process -NoNewWindow -FilePath "$($currentdir)\sources\erlang.exe"  -ArgumentList "/S" -Wait  
#
#Write-Output "Installing rabbitq"
#$proc = Start-Process -NoNewWindow -FilePath "$($currentdir)\sources\rabbitmq.exe"  -ArgumentList "/S" -Wait:$false -Passthru
#Wait-Process -Id $proc.Id
#
#Write-Output "Configure rabbitq"
#Update-Environment
#Write-Host "Updated Environment." -ForegroundColor Green
#Write-Host "ERLANG_HOME is $env:ERLANG_HOME" -ForegroundColor Yellow
#$sbin = "C:\Program Files\RabbitMQ Server\rabbitmq_server-$($rabbitVersion)\sbin"
#
#& $sbin\rabbitmq-plugins.bat enable rabbitmq_management
#
#& $sbin\rabbitmq-service.bat stop
#& $sbin\rabbitmq-service.bat remove
#& $sbin\rabbitmq-service.bat install
#& $sbin\rabbitmq-service.bat start
#
#Start-Sleep -s 15
#
#& $sbin\rabbitmqctl.bat add_user prechart $rabbitmqpwd
#& $sbin\rabbitmqctl.bat set_user_tags prechart administrator 
#& $sbin\rabbitmqctl.bat add_vhost acture 
#& $sbin\rabbitmqctl.bat add_vhost activasz 
#& $sbin\rabbitmqctl.bat set_permissions -p / prechart ".*" ".*" ".*" 
#& $sbin\rabbitmqctl.bat set_permissions -p acture prechart ".*" ".*" ".*" 
#& $sbin\rabbitmqctl.bat set_permissions -p activasz prechart ".*" ".*" ".*" 
#& $sbin\rabbitmqctl.bat delete_user guest

Write-Output "Installing clamav"
#Expand-Archive -LiteralPath "$($currentdir)\sources\clamav.zip" -DestinationPath $appdir
#Start-Process -NoNewWindow -FilePath "$($appdir)\clamav\freshclam.exe" -Wait 

Write-Output "$($appdir)\clamav\freshclam.exe"
Write-Output "$($appdir)\clamav\clamd.exe"
#Start-Process -NoNewWindow -FilePath "$($appdir)\clamav\clamd.exe" -ArgumentList "--install" -Wait 
#Start-Process -NoNewWindow -FilePath "$($appdir)\clamav\freshclam.exe" -ArgumentList "--install" -Wait 
#Set-Service -Name "ClamD" -StartupType "Automatic"
#Set-Service -Name "FreshClam" -StartupType "Automatic"
#sc.exe failure "FreshClam" actions= restart/60000/restart/120000/restart/180000 reset= 86400 
#sc.exe failure "ClamD" actions= restart/60000/restart/120000/restart/180000 reset= 86400 
#Start-Service -Name "ClamD"
#Start-Service -Name "FreshClam"

#Write-Output "Import prechart cert"
#$sslsecurepwd = ConvertTo-SecureString -String "X3jAJfmsttLZgdxZ" -AsPlainText -Force
#Import-PfxCertificate -FilePath "$($currentdir)\prechartnl.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $sslsecurepwd
#
#$certificate = Get-ChildItem "Cert:\LocalMachine\My" | Where thumbprint -eq "c00265681af44d9556bfda9ca8f1619b91382a67"
#
#if ($certificate -eq $null)
#{
#    $message="Certificate with thumbprint:"+$certThumbprint+" does not exist at "+$certStorePath
#    Write-Host $message -ForegroundColor Red
#    exit 1;
#}else
#{
#    $rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
#    $fileName = $rsaCert.key.UniqueName
#    $path = "c:\programdata\microsoft\crypto\RSA\MachineKeys\$fileName"
#    $permissions = Get-Acl -Path $path
#
#    $access_rule = New-Object System.Security.AccessControl.FileSystemAccessRule($svcusername, 'Read', 'None', 'None', 'Allow')
#    $permissions.AddAccessRule($access_rule)
#    Set-Acl -Path $path -AclObject $permissions
#}
