Try{
    . "$PSScriptRoot\Modules\IaC.AzRG.ps1"
    . "$PSScriptRoot\Modules\IaC.AzVPN.ps1"
}
Catch{
    Write-Warning "Unable to load IaC Functions"
}

Function Deploy-S2SVpn{
<#
.Synopsis
   Setup S2S VPN connection on the Azure Virtual Network
.DESCRIPTION
   This script deploys Site-to-Site VPN Connection on the Azure virtual network environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   Deploy-S2SVpn -ConfigFile "..\Config\AzVPN-Config.psd1"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        $ConfigFile	
    )

    #region VPN Deployment

    Write-Verbose "[*] Checking Config File..."
    If((Test-Path $ConfigFile -PathType Leaf) -and (Test-PSDataFile $ConfigFile)){
        $Config = Import-PowerShellDataFile -Path $ConfigFile
        Write-Verbose "[*] - Config File imported OK!"
    }
    Else {
        Write-Warning "$ConfigFile : File not found or incorrect format"
        return
    }

    Write-Verbose "[*] Checking Azure PowerShell Session..."
    If(-Not(Test-AzPSSession)){
        Connect-AzAccount    
    }

    Write-Verbose "[*] Checking the VNet Resource Group: $($Config.ResourceGroup)"
    If (-Not(Test-ResourceGroup -ResourceGroupName $Config.ResourceGroup)){
        Write-Verbose "[*] >> $($Config.ResourceGroup) doesn't exists!"
        return        
    }
    Else { Write-Verbose "[*] >> $($Config.ResourceGroup) exists!" }

    Write-Verbose "[*] Creating a LAN Gateway with On-prem LAN details"
    If(-Not(Test-LanGateway -Name $Config.LAN.LanGwName -ResourceGroupName $Config.ResourceGroup)){
        New-LanGateway -Name $Config.LAN.LanGwName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -GatewayIpAddress $Config.LAN.LanGwPip -AddressPrefix $Config.LAN.LanAddress
    }
    Else{ Write-Verbose "[*] >> $($Config.LAN.LanGwName) already exists!"}

    Write-Verbose "[*] Acquiring a Public IP address..."
    If(-Not(Test-PublicIP -Name $Config.VPN.PipName -ResourceGroupName $Config.ResourceGroup)){
        New-PublicIp -Name $Config.VPN.PipName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AllocationMethod $Config.VPN.AllocationMethod
    }
    Else{ Write-Verbose "[*] >> $($Config.VPN.PipName) already exists!" }

    Write-Verbose "[*] Creating a VPN Gateway for the Azure Virtual Network"
    Write-Verbose "Info: This can take up to 20 mintues to complete."
    If(-Not(Test-VpnGateway -Name $Config.VNet.VpnGwName -ResourceGroupName $Config.ResourceGroup)){
        New-VpnGateway -Name $Config.VNet.VpnGwName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location `
            -VNetName $Config.VNet.Name             `
            -GatewaySubnet $Config.VNet.GatewaySub  `
            -PipName $Config.VPN.PipName            `
            -GatewayType $Config.VNet.GatewayType   `
            -VpnType $Config.VNet.VpnType           `
            -GatewaySku $Config.VNet.GatewaySku     `
            -IpConfigName $Config.VNet.GwIpCfgName
    }
    Else{ Write-Verbose "[*] >> $($Config.VNet.VpnGwName) already exists!" }

    Write-Verbose "[*] Creating a new Site-to-Site VPN Connection"
    If(-Not(Test-VpnConnection -Name $Config.VPN.Name -ResourceGroupName $Config.ResourceGroup)){
        New-VpnConnection -Name $Config.VPN.Name -ResourceGroupName $Config.ResourceGroup -Location $Config.Location `
            -VpnGwName $Config.VNet.VpnGwName   `
            -LanGwName $Config.LAN.LanGwName    `
            -ConnectionType $Config.VPN.ConnectionType  `
            -RoutingWeight $Config.VPN.RoutingWeight    `
            -Base64 (Base64 -Text $($Config.VPN.SharedKey))
    }
    Else{ Write-Verbose "[*] >> $($Config.VPN.Name) already exists!" }
    #endregion VPN Deployment
}

Measure-Command -Expression {
    Deploy-S2SVpn -ConfigFile ..\Config\AzVPN-Config.psd1 -Verbose
}