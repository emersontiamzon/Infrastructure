
#this part is commented out for preparation purposes deployment is not final
#Param (
#    [Parameter(Mandatory=$True)]
#    [string]$environment,
#    [Parameter(Mandatory=$True)]
#    [string]$client
#)

$currentdir = $PSScriptRoot
#$svcusername = "$($client)-$($environment)"
$svcusername = "Serveradmin"
Write-Output "Download Certificate"
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://prechartstorage.blob.core.windows.net/setup/prechart.pfx","$($currentdir)\prechart.pfx")

Write-Output "Import Certificate"
$sslsecurepwd = ConvertTo-SecureString -String "Calender365" -AsPlainText -Force

$certificate = Get-ChildItem "Cert:\LocalMachine\My" | Where thumbprint -eq "‎045558a25f2202825306bf8e39cab473dc23adce"
 


if ($certificate -eq $null)
{
    Import-PfxCertificate -FilePath "$($currentdir)\prechart.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $sslsecurepwd

}

$certificate = Get-ChildItem "Cert:\LocalMachine\My" | Where thumbprint -eq "045558a25f2202825306bf8e39cab473dc23adce"
if ($certificate -eq $null)
{
    $message="Certificate with thumbprint:"+$certThumbprint+" does not exist at "+$certStorePath
    Write-Host $message -ForegroundColor Red
    exit 1;
}else
{
    Write-Output  $rsaCert.key.UniqueName
    $rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
    $fileName = $rsaCert.key.UniqueName
    $path = "c:\programdata\microsoft\crypto\RSA\MachineKeys\$fileName"
    $permissions = Get-Acl -Path $path

    $access_rule = New-Object System.Security.AccessControl.FileSystemAccessRule($svcusername, 'Read', 'None', 'None', 'Allow')
    $permissions.AddAccessRule($access_rule)
    Set-Acl -Path $path -AclObject $permissions
}
