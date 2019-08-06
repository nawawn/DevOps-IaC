#Get Test environment from Azure
Get-AzVM -Status

$PublicIp = Get-AzPublicIpAddress
Write-Output "`r`nChecking the web site on $($PublicIp.IpAddress)..."
Invoke-WebRequest -Uri $PublicIp.IpAddress | Select-Object StatusCode,StatusDescription