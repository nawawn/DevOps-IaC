Function Test-VNet{
    [OutputType([Bool])]
    Param(        
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name
    )
    process{         
        return ($null -ne (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction 'SilentlyContinue'))
    }
}

Function Test-VNetSubnet{
    [OutputType([Bool])]
    Param(       
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$VNetName,
        [Parameter(Mandatory)][String]$SubnetName
    )
    process{
        $PSVnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName -ErrorAction 'SilentlyContinue'         
        return ($null -ne (Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $PSVnet -ErrorAction 'SilentlyContinue'))
    }
}
#Function Test-GatewaySubnet{ Same as Test-VnetSubnet }

Function Test-NSG{
    [OutputType([Bool])]
    Param(        
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name
    )
    process{         
        return ($null -ne (Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction 'SilentlyContinue'))
    }
}

Function Test-NsgRule{
    [OutputType([Bool])]
    Param(        
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$NSGName,
        [Parameter(Mandatory)][String]$RuleName
    )
    process{
        $PSNsg = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
        return ($null -ne (Get-AzNetworkSecurityRuleConfig -Name $RuleName -NetworkSecurityGroup $PSNsg -ErrorAction 'SilentlyContinue'))
    }
}

Function Test-SubnetNsg{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$VNetName,
        [Parameter(Mandatory)][String]$SubnetName,
        [Parameter(Mandatory)][String]$NsgName
    )
    $PSSubnet = (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName -ErrorAction 'SilentlyContinue' | 
                    Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -ErrorAction 'SilentlyContinue')
    $PSNsg = $PSSubnet.NetworkSecurityGroup
    If ($PSNsg){        
        return (($PSNsg.Id).EndsWith($NsgName))
    }
    Else {
        return $false
    }
}

Function New-VNet{
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Location,
        [Parameter(Mandatory)][String]$AddressPrefix
    )
    Process{
        New-AzVirtualNetwork -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $AddressPrefix
    }     
}

Function Add-SubnetToVNet{
    Param(        
        [Parameter(Mandatory)][String]$SubnetName,        
        [Parameter(Mandatory)][String]$AddressPrefix,
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$VNetName
    )
    Process{
        $PSVnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
        Add-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $AddressPrefix -VirtualNetwork $PSVnet        
        Set-AzVirtualNetwork -VirtualNetwork $PSVnet
    }
}

Function New-Nsg{
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][string]$Location
    )
    Process{
        New-AzNetworkSecurityGroup -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location
    }
}

Function Add-RuleToNsg{
    Param(
        [Parameter(Mandatory)][String]$NSGName,
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)]$Rule
    )
    Process{
        #[Mircosoft.Azure.Commands.Network.Models.PSSecurityRule]
        If ($Rule){
            Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName | 
            Add-AzNetworkSecurityRuleConfig @Rule | 
            Set-AzNetworkSecurityGroup
        }
    }
}

Function Join-NsgToSubnet{
    Param(
        [Parameter(Mandatory)][String]$NSGName,
        [Parameter(Mandatory)][String]$SubnetName,
        [Parameter(Mandatory)][String]$VNetName,
        [Parameter(Mandatory)][String]$ResourceGroupName        
    )
    Process{
        $PSVnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
        $Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $PSVnet -Name $SubnetName
        $PSNsg  = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName            
        $Subnet.NetworkSecurityGroup = $PSNsg
        Set-AzVirtualNetwork -VirtualNetwork $PSVnet
    }
}