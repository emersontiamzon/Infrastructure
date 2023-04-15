param($dbname, $remoteshare, $documentsfolder, $username, $password,$usernamedest,$passworddest)

$mapfoldersrc = "$($remoteshare)\$($documentsfolder)"

#creating map network for production documents
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
New-PSDrive -name "X" -PSProvider FileSystem -Root $mapfoldersrc -Credential $credential

#creating map network for destination documents
$securePassword = ConvertTo-SecureString $passworddest -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $usernamedest, $securePassword
$path_document_dest = Invoke-Sqlcmd  -Database "$($dbname)" "select value as value from configuration where [key] = 'DocumentUploadPath'"  
New-PSDrive -name "Y" -PSProvider FileSystem -Root $path_document_dest.value -Credential $credential

$path_src = "X:\*.*" 
$path_dest = "Y:\"

Write-Output $path_src
Write-Output $path_dest

Copy-Item   $path_src -destination $path_dest -Force
