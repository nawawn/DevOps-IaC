$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "$sut is valid PowerShell code"{
    $PSFile = Get-Content -Path $here\$sut -ErrorAction 'Stop'
    $errors = $null
    [Void][System.Management.Automation.PSParser]::Tokenize($PSFile,[ref]$errors)
    It 'Should contain no syntax error'{
        $errors.Count | Should Be 0
    }    
}
Describe 'Test-LanGateway'{
    It 'Should return Boolean'{
        Mock -CommandName 'Get-AzLocalNetworkGateway' -MockWith{
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSLocalNetworkGateway)
        }
        Test-LanGateway -Name 'LGw-Name' -ResourceGroupName 'RG-Vpn-Name' | Should BeOfType [Bool]
    }
}
Describe 'Test-VpnGateway'{
    It 'Should return Boolean'{
        Mock -CommandName 'Get-AzVirtualNetworkGateway' -MockWith{
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway)
        }
        Test-VpnGateway -Name 'VGw-Name' -ResourceGroupName 'RG-Vpn-Name' | Should BeOfType [Bool]
    }
}
Describe 'Test-PublicIP'{
    It 'Should return Boolean'{
        Mock -CommandName 'Get-AzPublicIpAddress' -MockWith{
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSPublicIpAddress)
        }
        Test-PublicIP -Name 'Vpn-Name' -ResourceGroupName 'RG-Vpn-Name' | Should BeOfType [Bool]
    }
}
Describe 'Test-VpnConnection'{
    It 'Should return Boolean'{
        Mock -CommandName 'Get-AzVirtualNetworkGatewayConnection' -MockWith{
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayConnection)
        }
        Test-VpnConnection -Name 'Vpn-Name' -ResourceGroupName 'RG-Vpn-Name' | Should BeOfType [Bool]
    }
}
Describe 'New-LanGateway'{
    Mock -CommandName 'New-AzLocalNetworkGateway'{}
    Mock -CommandName 'New-LanGateway'{}
    It 'Should create a Lan Gateway'{
        New-LanGateway -Name 'LanGw-Name' -ResourceGroupName 'RG-Vpn-Name' -Location 'uksouth' -GatewayIpAddress '20.20.20.20' -AddressPrefix @('10.150.0.0/16','10.200.0.0/16') | Should be $null
    }
}
Describe 'New-PublicIP'{
    Mock -CommandName 'New-AzPublicIpAddress' -MockWith {
        $hash = @{
            Name              = 'Pip-Name'
            ResourceGroupName = 'RG-Test-VM'
            Location          = 'uksouth'
            AllocationMethod  = 'Dynamic'
        }
        return $hash
    }
    It 'Should return Ip Object'{
        New-PublicIp -Name 'Pip-Name' -ResourceGroupName 'RG-Test-VM' -Location 'uksouth' -AllocationMethod 'Dynamic' | Should Not Be $null
    }
}
Describe 'New-VpnGwIpConfig'{
    Mock -CommandName 'Get-AzVirtualNetwork'{}
    Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig'{}
    Mock -CommandName 'Get-AzPublicIpAddress'{}
    Mock -CommandName 'New-AzVirtualNetworkGatewayIpConfig'{}
    Mock -CommandName 'New-VpnGwIpConfig' -MockWith{
        $IpConfigs = New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayIpConfiguration
        return ($IpConfigs)
    }
    It 'Should return Ip Configuration Object'{
        New-VpnGwIpConfig -IpConfigName 'ipconfig1' -VNetName 'VNet-Name' -VNetResourceGroup 'RG-VNet' -GatewaySubnet 'GatewaySubnet' -PipName 'Pip-Name' -PipResourceGroup 'RG-Pip' | Should Not Be $null
    }
}
Describe 'New-VpnGateway'{
    Mock -CommandName 'Get-AzVirtualNetwork'{}
    Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig'{}
    Mock -CommandName 'Get-AzPublicIpAddress'{}
    Mock -CommandName 'New-AzVirtualNetworkGatewayIpConfig'{}
    Mock -CommandName 'New-AzVirtualNetworkGateway'{}
    Mock -CommandName 'New-VpnGateway'{}
    It 'Should create a Virtual Network Gateway'{
        New-VpnGateway -Name 'VpnGw-Name' -ResourceGroupName 'RG-VNet' -Location 'uksouth'      `
            -GatewayType 'Vpn' -VpnType 'RouteBased' -GatewaySku 'Basic' -VNetName 'VNet-Name'  `
            -GatewaySubnet 'GatewaySubnet' -PipName 'Pip-Name' -IpConfigName 'VpnGw-IpConfig' | Should be $null
    }
}
Describe 'New-VpnConnection'{
    Mock -CommandName 'Get-AzVirtualNetworkGateway'{}
    Mock -CommandName 'Get-AzLocalNetworkGateway'{}
    Mock -CommandName 'New-AzVirtualNetworkGatewayConnection'{}
    Mock -CommandName 'New-VpnConnection'{}
    It 'Should create a new Connection'{
        New-VpnConnection -Name 'Vpn-Name' -ResourceGroupName 'RG-VNet' -Location 'uksouth' `
            -VpnGwName 'VpnGw-Name' -LanGwName 'LanGw-Name' -ConnectionType 'IPSec'         `
            -RoutingWeight '10' -Base64 'Somethingcool=' | Should be $null
    }
}