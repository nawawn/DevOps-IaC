Try{
    . "$PSScriptRoot\Modules\IaC.AzRG.ps1"
    . "$PSScriptRoot\MOdules\IaC.AzVNet.ps1"
}
Catch{
    Write-Warning "Unable to load IaC Functions"
}

Function New-AzVNetEvn{
<#
.Synopsis
   Deploy VNet with NSG on the Azure IaaS platform
.DESCRIPTION
   This script deploys Virtual Network on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   New-AzVnetTestEnv -ConfigFile "..\Config\AzVnet-Config.psd1"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        $ConfigFile	
    )

    #region VNet Deployment
    
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

    Write-Verbose "[*] Creating a Resource Group: $($Config.ResourceGroup)"
    If (-Not(Test-ResourceGroup -ResourceGroupName $Config.ResourceGroup)){
        New-ResourceGroup -Name $Config.ResourceGroup -Location $Config.Location 
    }
    Else { Write-Verbose "[*] >> $($Config.ResourceGroup) already exists!" }

    Write-Verbose "[*] Creating a Virtual Network: $($Config.Vnet.VNetName)"
    If (-Not(Test-VNet -ResourceGroupName $Config.ResourceGroup -Name $Config.Vnet.VNetName)){
        New-VNet -Name $Config.VNet.VNetName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AddressPrefix $Config.VNet.VNetAddr
    }
    Else { Write-Verbose "[*] >> $($Config.Vnet.VNetName) already exists!" }

    Write-Verbose "[*] Attaching a Subnet to the Virtual Network: $($Config.Vnet.SubNetName) -> $($Config.ResourceGroup)"
    If(-Not(Test-VNetSubnet -ResourceGroupName $Config.ResourceGroup -VNetName $Config.VNet.VNetName -SubnetName $Config.Vnet.SubNetName )){
        Add-SubnetToVNet -SubnetName $Config.VNet.SubNetName -AddressPrefix $Config.VNet.SubNetAddr -ResourceGroupName $Config.ResourceGroup -VNetName $Config.VNet.VNetName
    }
    Else { Write-Verbose "[*] >> Already Attached!" }

    Write-Verbose "[*] Setting up the Gateway subnet for the Virtual Network: GatewaySubnet -> $($Config.ResourceGroup)"
    If(-Not(Test-VNetSubnet -ResourceGroupName $Config.ResourceGroup -VNetName $Config.VNet.VNetName -SubnetName 'GatewaySubnet')){
        Add-SubnetToVNet -SubnetName 'GatewaySubnet' -AddressPrefix $Config.VNet.GatewaySub -ResourceGroupName $Config.ResourceGroup -VNetName $Config.VNet.VNetName
    }

    Write-Verbose "[*] Creating a Network Security Group: $($Config.VNet.NSGName)"
    If(-Not(Test-Nsg -ResourceGroupName $Config.ResourceGroup -Name $Config.VNet.NSGName)){
        New-Nsg -Name $Config.VNet.NSGName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location
    }
    Else { Write-Verbose "[*] >> $($Config.VNet.NSGName) already exists!" }
    
    Write-Verbose "[*] Adding rules to the Network Security Group"
    Foreach($Key in ($Config.NsgRules).Keys){
        $Rule = ($Config.NsgRules)[$Key]        
        If(-Not(Test-NsgRule -ResourceGroupName $Config.ResourceGroup -NSGName $Config.VNet.NSGName -RuleName $Rule.Name)){
            Write-Verbose "[*] - $($Rule.Name) -> $($Config.VNet.NSGName)"            
            Add-RuleToNsg -NSGName $Config.VNet.NSGName -ResourceGroupName $Config.ResourceGroup -Rule $Rule
        }
        Else { Write-Verbose "[*] >> $($Rule.Name) rule already exists!" }
    }
       
    Write-Verbose "[*] Attaching the Network Security Group to the Subnet"
    If(-Not(Test-SubnetNsg -ResourceGroupName $Config.ResourceGroup -VNetName $Config.VNet.VNetName -SubnetName $Config.VNet.SubNetName -NsgName $Config.VNet.NSGName)){
        Join-NsgToSubnet -NSGName $Config.VNet.NSGName -SubnetName $Config.VNet.SubNetName -VNetName $Config.VNet.VNetName -ResourceGroupName $Config.ResourceGroup   
    }
    Else { Write-Verbose "[*] >> $($Config.VNet.NSGName) rule already attached !"}    
    #endregion VNet Deployment
}

Measure-Command -Expression {
    New-AzVNetEvn -ConfigFile '..\Config\AzVnet-Config.psd1' -Verbose
}