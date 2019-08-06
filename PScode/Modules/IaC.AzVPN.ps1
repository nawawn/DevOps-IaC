Function Test-LanGateway{
    [OutputType([Bool])]
    Param(
        [string]$Name,
        [string]$ResourceGroupName
    )
    Process{
        return ($null -ne (Get-AzLocalNetworkGateway -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    }    
}
Function Test-VpnGateway{
    [OutputType([Bool])]
    Param(
        [string]$Name,
        [string]$ResourceGroupName
    )
    Process{
        return ($null -ne (Get-AzVirtualNetworkGateway -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    }    
}
Function Test-PublicIP{
    [OutputType([Bool])]
    Param(
        [string]$Name,        
        [string]$ResourceGroupName
    )
    Process{
        return ($null -ne (Get-AzPublicIpAddress -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    } 
}
Function Test-VpnConnection{
    [OutputType([Bool])]
    Param(
        [string]$Name,
        [string]$ResourceGroupName
    )
    #Site to Site IPSec Tunnel
    Process{
        return ($null -ne (Get-AzVirtualNetworkGatewayConnection -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    }    
}
Function New-LanGateway{
<#
.DESCRIPTION
   Create a new LAN Gateway. This is where you enter the details of your on premises LAN details.
   Output type is [Mircosoft.Azure.Commands.Network.Models.PSLocalNetworkGateway]
.EXAMPLE
   New-LanGateway -Name 'LanGw-Name' -ResourceGroupName 'RG-Name' -Location 'uksouth' -GatewayIpAddress <OnPrem-PublicIp> -AddressPrefix <OnPrem-LanIpRange>
#>
    Param(
        [string]$Name,        
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$GatewayIpAddress,
        [string[]]$AddressPrefix
    )
    Process{
        New-AzLocalNetworkGateway -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location `
                                  -GatewayIpAddress $GatewayIpAddress -AddressPrefix $AddressPrefix
    }
}
Function New-PublicIP{
    #[Mircosoft.Azure.Commands.Network.Models.PSPublicIpAddress]
    Param(
        [string]$Name,        
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$AllocationMethod
    )
    Process{
        #Only Dynamic IP address assignment is supported for VPN gateway
        New-AzPublicIpAddress -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod $AllocationMethod
    }
}
Function New-VpnGwIpConfig{
    #[Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayIpConfiguration]
    Param(
        [string]$IpConfigName,
        [string]$VNetName,
        [string]$VNetResourceGroup,
        [string]$GatewaySubnet,
        [string]$PipName,
        [string]$PipResourceGroup        
    )
    Process{
        $PSVNet    = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroup
        $SubnetId  = (Get-AzVirtualNetworkSubnetConfig -Name $GatewaySubnet -VirtualNetwork $PSVNet).Id
        $PipAddrId = (Get-AzPublicIpAddress -Name $PipName -ResourceGroupName $PipResourceGroup).Id
        $IpConfigurations = New-AzVirtualNetworkGatewayIpConfig -Name $IpConfigName -SubnetId $SubnetId -PublicIpAddressId $PipAddrId
        return ($IpConfigurations)
    }
}
Function New-VpnGateway{
    #[Mircosoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)][string]$Name,        
        [Parameter(Mandatory)][string]$ResourceGroupName,
        [Parameter(Mandatory)][string]$Location,        
        [Parameter(Mandatory)][string]$GatewayType,
        [Parameter(Mandatory)][string]$VpnType,
        [Parameter(Mandatory)][string]$GatewaySku,        
        [Parameter(Mandatory)][string]$VNetName,
        [Parameter(Mandatory)][string]$GatewaySubnet,
        [Parameter(Mandatory)][string]$PipName,
        [Parameter(Mandatory)][string]$IpConfigName        
    )
    #Can take up to 20 minutes
    Process{        
        $PSVNet    = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
        $SubnetId  = (Get-AzVirtualNetworkSubnetConfig -Name $GatewaySubnet -VirtualNetwork $PSVNet).Id
        $PipAddrId = (Get-AzPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName).Id
        $IpConfig = New-AzVirtualNetworkGatewayIpConfig -Name $IpConfigName -SubnetId $SubnetId -PublicIpAddressId $PipAddrId
        #Virtual Network Gateway has to be in the same Resource Group as the VNet Resource Group
        New-AzVirtualNetworkGateway -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location `
            -GatewayType $GatewayType `
            -VpnType $VpnType         `
            -GatewaySku $GatewaySku   `
            -IpConfigurations $IpConfig           
    }    
}

Function New-VpnConnection{
    #[Mircosoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayConnection]
    Param(
        [Parameter(Mandatory)][string]$Name,        
        [Parameter(Mandatory)][string]$ResourceGroupName,
        [Parameter(Mandatory)][string]$Location,
        [Parameter(Mandatory)][string]$VpnGwName,
        [Parameter(Mandatory)][string]$LanGwName,       
        [Parameter(Mandatory)][string]$ConnectionType,
        [Parameter(Mandatory)][string]$RoutingWeight,
        [Parameter(Mandatory)][string]$Base64
    )
    Process{
        $PSVpnGw = Get-AzVirtualNetworkGateway -Name $VpnGwName -ResourceGroupName $ResourceGroupName 
        $PSLanGw = Get-AzLocalNetworkGateway -Name $LanGwName -ResourceGroupName $ResourceGroupName

        New-AzVirtualNetworkGatewayConnection -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location `
            -VirtualNetworkGateway1 $PSVpnGw `
            -LocalNetworkGateway2 $PSLanGw   `
            -ConnectionType $ConnectionType  `
            -RoutingWeight $RoutingWeight    `
            -SharedKey $Base64
    }
}
