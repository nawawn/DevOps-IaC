$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "$sut is valid PowerShell code"{
    $PSFile = Get-Content -Path $here\$sut -ErrorAction 'Stop'
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize($PSFile,[ref]$errors)
    It 'Should contain no syntax error'{
        $errors.Count | Should Be 0
    }    
}

Describe "Test-VNet"{
    It "should return boolean"{
        Mock -CommandName 'Get-AzVirtualNetwork' -MockWith{
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork)
        }
        Test-VNet -ResourceGroupName 'RG-VNet-Name' -Name 'VNet-Name' | Should BeOfType '[Bool]'
    }
}
Describe "Test-VNetSubnet"{
    It "should return boolean"{
        Mock -CommandName 'Get-AzVirtualNetwork' -MockWith {}
        Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig' -MockWith {}
        Mock -CommandName 'Test-VNetSubnet' -MockWith {
            return $true
        }
        Test-VNetSubnet -ResourceGroupName 'RG-VNet-Name' -VNetName 'VNet-Name' -SubnetName 'Subnet-Name' | Should BeOfType '[Bool]'
    }
}

Describe "Test-NSG"{
    It "should return boolean"{
        Mock -CommandName 'Get-AzNetworkSecurityGroup' -MockWith{
            $PSNsg = New-Object Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup
            return ($null -ne $PSNsg)
        }
        Test-NSG -ResourceGroupName 'RG-VNet-Name' -Name 'NSG-Name' | Should BeOfType '[Bool]'
    }
}
Describe "Test-NsgRule"{
    It "should return boolean"{
        Mock -CommandName 'Get-AzNetworkSecurityGroup' -MockWith {}
        Mock -CommandName 'Get-AzNetworkSecurityRuleConfig' -MockWith {}
        Mock -CommandName 'Test-NsgRule' -MockWith {
            return $true
        }
        Test-NsgRule -ResourceGroupName 'RG-VNet-Name' -NSGName 'NSG-Name' -RuleName 'Rdp' | Should BeOfType '[Bool]'
    }
}
Describe "New-VNet" {
    Mock -CommandName 'New-AzVirtualNetwork'-MockWith{        
        $VnetObj = New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
        $VnetObj.Name = 'VNet-Name'
        $VnetObj.ResourceGroupName = 'RG-VNet-Name'
        $VnetObj.Location = 'uksouth'
        return ($VnetObj)
    } -ParameterFilter {$Name -eq 'VNet-Name' -and $ResourceGroupName -eq 'RG-VNet-Name' -and $Location -eq 'uksouth'}

    It 'Should create new Azure VNet'{
        New-VNet -Name 'VNet-Name' -ResourceGroupName 'RG-VNet-Name' -Location 'uksouth' -AddressPrefix '10.7.0.0/16' | Should BeOfType [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]
    }
}
Describe "Add-SubnetToVNet" {
    It 'Should return a VNet'{
        Mock -CommandName 'Get-AzVirtualNetwork' -MockWith {}
        Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig' -MockWith {}        
        Mock -CommandName 'Set-AzVirtualNetwork' -MockWith {}             
        Mock -CommandName 'Add-SubnetToVNet' -MockWith{
            $VnetObj = New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
            $VnetObj.Name              = 'VNet-Name'
            $VnetObj.ResourceGroupName = 'RG-VNet-Name'
            $VnetObj.Location          = 'uksouth'           
            return $VnetObj
        }
        $TestVnet = Add-SubnetToVNet -SubnetName 'New-Subnet' -AddressPrefix '10.7.0.0/24' -ResourceGroupName 'RG-VNet-Name' -VNetName 'VNet-Name'
                
        $TestVnet | Should BeOfType [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]
    }
}
Describe 'New-Nsg'{
    Mock -CommandName 'New-AzNetworkSecurityGroup'-MockWith{
        return (New-Object Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup)
    } -ParameterFilter {$Name -eq 'Nsg-Name' -and $ResourceGroupName -eq 'RG-VNet-Name' -and $Location -eq 'uksouth'}
    It 'should create new Network Security Group'{
        New-Nsg -Name 'Nsg-Name' -ResourceGroupName 'RG-VNet-Name' -Location 'uksouth' | Should BeOfType [Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup]
    }
}
Describe 'Add-RuleToNsg'{
    It 'should return PSNetworkSecurityGroup'{
        Mock -CommandName 'Get-AzNetworkSecurityGroup' -MockWith {}
        Mock -CommandName 'Get-AzNetworkSecurityRuleConfig' -MockWith {}
        Mock -CommandName 'Set-AzVirtualNetwork' -MockWith {}
        Mock -CommandName 'Add-RuleToNsg' -MockWith {
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup)
        }
        $Rule = @{
            Name = 'Http'
            Description = 'Allow Http'
            DestinationPortRange = 80
        }        
        Add-RuleToNsg -NSGName 'NSG-Name' -ResourceGroupName 'RG-VNetName' -Rule $Rule | Should BeOfType [Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup]
    }
}
Describe 'Join-NsgToSubnet'{
    It 'should return PSVirtualNetwork'{
        Mock -CommandName 'Get-AzVirtualNetwork' -MockWith {}
        Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig' -MockWith {}
        Mock -CommandName 'Get-AzNetworkSecurityGroup' -MockWith {}
        Mock -CommandName 'Set-AzVirtualNetwork' -MockWith {}
        Mock -CommandName 'Join-NsgToSubnet' -MockWith {
            return (New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork)
        }        
        Join-NsgToSubnet -NSGName 'NSG-Name' -SubnetName 'Subnet-Name' -VNetName 'VNet-Name' -ResourceGroupName 'RG-VNetName' | Should BeOfType [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]        
    }
}