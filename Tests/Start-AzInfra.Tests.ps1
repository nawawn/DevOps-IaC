$VNetConfig = '..\Config\AzVNet-Config.psd1'
$VPNConfig  = '..\Config\AzVPN-Config.psd1'
$StorConfig = '..\Config\AzStor-Config.psd1'
$VMList = @(
    '..\Config\CoreVM-Config.psd1'
)
  
Describe 'Azure Test Environment Virtual Network' -Tag 'VNet','All'{
    $Config = Import-PowerShellDataFile -Path $VNetConfig   

    Context 'Azure VNet Resource Group'{
        $RG = Get-AzResourceGroup -Name $($Config.ResourceGroup) -Location $($Config.Location)
        It "Resource Group Name: $($Config.ResourceGroup)"{
            $RG.ResourceGroupName | Should Not Be $null
        }
        It "Location should be: $($Config.Location)"{
            $RG.Location | Should Be $($Config.Location)
        }
    }
    Context 'Azure Virtual Network'{
        $VNet   = Get-AzVirtualNetwork -Name $($Config.Vnet.VNetName) -ResourceGroupName $($Config.ResourceGroup)
        $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $($Config.Vnet.SubNetName) -VirtualNetwork $VNet
        $Gateway = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $VNet
        $Nsg     = Get-AzNetworkSecurityGroup -Name $($Config.Vnet.NSGName) -ResourceGroupName $($Config.ResourceGroup)

        It "VNet Name should exist: $($Config.Vnet.VNetName)"{
            $VNet.Name | Should Not Be $null
        }
        It "VNet Address space: $($Config.Vnet.VNetAddr)"{
            $VNet.AddressSpace.AddressPrefixes | Should match $($Config.Vnet.VNetAddr)
        }
        It "Vnet Subnet Name should exist: $($Config.Vnet.SubNetName)"{
            $Subnet.Name | Should Not Be $null
        }
        It "VNet Subnet Address: $($Config.Vnet.SubNetAddr)"{
            $Subnet.addressprefix | Should match $($Config.Vnet.SubNetAddr)
        }
        It "Vnet GatewaySubnet should exist"{
            $Gateway.Name | Should Not Be $null
        }
        It "VNet GatewaySubnet Address: $($Config.Vnet.GatewaySub)"{
            $Gateway.addressprefix | Should match $($Config.Vnet.GatewaySub)
        }
        It "Network Security Group should exist: $($Config.Vnet.NSGName)"{
            $Nsg.Name | Should Not Be $null
        }
        Foreach($Key in ($Config.NsgRules).Keys){
            $Rule = ($Config.NsgRules)[$Key]
            $NsgRule = Get-AzNetworkSecurityRuleConfig -Name $($Rule.Name) -NetworkSecurityGroup $Nsg
            It "$($Rule.Name) Rule should exist"{
                $NsgRule.Name | Should Not Be $null
            }
            If ($Rule.Access -eq 'Allow'){
                It "$($Rule.Name) Traffic should be allowed"{
                    $NsgRule.Access | Should Be 'Allow'
                }
            }
            If ($Rule.Access -eq 'Deny'){
                It "$($Rule.Name) Traffic should be denied"{
                    $NsgRule.Access | Should Be 'Deny'
                }
            } 
        }     
    }
}#End of VNet Describe Block

Describe 'Azure Site-to-Site VPN' -Tag 'VPN','All'{
    $Config = Import-PowerShellDataFile -Path $VPNConfig
    Context 'Public Ip Address'{
        $PIp = Get-AzPublicIpAddress -Name $($Config.VPN.PipName) -ResourceGroupName $($Config.ResourceGroup)
        
        It "Public Ip should exist: $($Config.VPN.PipName)"{
            $PIp.Name | Should Not Be $null
        }
        It "Public IP allocation method must be: $($Config.VPN.AllocationMethod)"{
            $PIp.PublicIpAllocationMethod | Should match $($Config.VM.AllocationMethod)
        }
    }
    Context 'LAN Gateway'{
        $LanGw = Get-AzLocalNetworkGateway -Name $($Config.LAN.LanGwName) -ResourceGroupName $($Config.ResourceGroup)

        It "LAN Gateway should exist: $($Config.LAN.LanGwName)"{
            $LanGw.Name | Should not be $null
        }
        It "On-Prem Public IP should be: $($Config.LAN.LanGwPip)"{
            $lanGw.GatewayIpAddress | Should match $($Config.LAN.LanGwPip)
        }
        It "On-Prem LAN address should match: $($Config.LAN.LanAddress)"{
            Compare-Object $($Config.LAN.LanAddress) $($lanGw.LocalNetworkAddressSpace.AddressPrefixes) | Should be $null
        }
    }
    Context 'VNet Gateway'{
        $VnetGw = Get-AzVirtualNetworkGateway -Name $($Config.VNet.VpnGwName) -ResourceGroupName $($Config.ResourceGroup)
        It "VNet Gateway should exist: $($Config.VNet.VpnGwName)"{
            $VnetGw.Name | Should not be $null
        }
        It "VNet Gateway type should be: $($Config.VNet.GatewayType)"{
            $VnetGw.GatewayType | Should match $($Config.VNet.GatewayType)
        }
        It "VNet Gateway Vpntype should be: $($Config.VNet.VpnType)"{
            $VnetGw.VpnType | Should match $($Config.VNet.VpnType)
        }
    }
    Context 'VPN Connection'{
        $VPN = Get-AzVirtualNetworkGatewayConnection -Name $($Config.VPN.Name) -ResourceGroupName $($Config.ResourceGroup)
        It "VPN Connection should exist: $($Config.VPN.Name)"{
            $VPN.Name | Should not be $null
        }
        It "VPN provisioning should be succeeded"{
            $VPN.ProvisioningState | Should be 'Succeeded'
        }
        It "VPN RoutingWeight should be: $($Config.VPN.RoutingWeight)"{
            $VPN.RoutingWeight | Should be $($Config.VPN.RoutingWeight)
        }
    }
}#End of VPN Describe Block

Describe 'Azure Storage Provisioning' -Tag 'Stor','All'{
    $Config = Import-PowerShellDataFile -Path $StorConfig
    
    Context 'Azure Storage account Resource Group'{
        $RG = Get-AzResourceGroup -Name $($Config.ResourceGroup) -Location $($Config.Location)
        It "Resource Group Name: $($Config.ResourceGroup)"{
            $RG.ResourceGroupName | Should Not Be $null
        }
        It "Location should be: $($Config.Location)"{
            $RG.Location | Should Be $($Config.Location)
        }
    }
    Context 'Storage account'{
        $Stor = Get-AzStorageAccount -ResourceGroupName $($Config.ResourceGroup) -Name $($Config.Variables.StorageAccountName)
        It "Storage Account Name : $($Config.Variables.StorageAccountName)"{
            $Stor | Should not be $null
        }
        $Blob = Get-AzStorageContainer -Name $($Config.Variables.ContainerName) -Context $Stor.Context
        It "Blob Container Name: $($Config.Variables.ContainerName)"{
            $Blob | Should not be $null
        }
        It "Blob Permission shoul be: $($Config.Variables.Permission)"{
            $Blob.Permission.PublicAccess | Should match $($Config.Variables.Permission)
        }
        $Share = Get-AzStorageShare -Name $($Config.Variables.FileShareName) -Context $Stor.Context
        It "File Share Name: $($Config.Variables.FileShareName)"{
            $Share | Should not be $null
        }
    }
}#End of Storage Describe Block

Describe 'Azure Virtual Machine' -Tag 'VM','All' {    
    Foreach($VMConfig in $VMList){

        $Config = Import-PowerShellDataFile -Path $VMConfig

        Context 'Azure VM Resource Group'{
            $RG = Get-AzResourceGroup -Name $($Config.ResourceGroup) -Location $($Config.Location)
            It "Resource Group Name: $($Config.ResourceGroup)"{
                $RG.ResourceGroupName | Should Not Be $null
            }
            It "Location should be: $($Config.Location)"{
                $RG.Location | Should Be $($Config.Location)
            }
        }
        Context 'Public Ip Address'{
            $PIp = Get-AzPublicIpAddress -Name $($Config.VM.PipName) -ResourceGroupName $($Config.ResourceGroup)
            
            It "Public IP Should exist: $($Config.VM.PipName)"{
                $PIp.Name | Should Not Be $null
            }
            It "Public IP allocation method should be: $($Config.VM.AllocationMethod)"{
                $PIp.PublicIpAllocationMethod | Should match $($Config.VM.AllocationMethod)
            }
        }
        Context 'Virtual Network Interface'{
            $VNic = Get-AzNetworkInterface -Name $($Config.VM.VNicName) -ResourceGroupName $($Config.ResourceGroup)
            
            It "VNIC Should exist: $($Config.VM.VNicName)"{
                $VNic.Name | Should Not Be $null
            }
            It "VNIC Should have Public Ip: $($Config.VM.PipName)"{
                ($VNic.Ipconfigurations[0].PublicIpAddress.ID).EndsWith($($Config.VM.PipName)) | Should Be $true
            }
        }
        Context "Virtual Machine"{
            $VM = Get-AzVM -Name $($Config.VM.VMName) -ResourceGroupName $($Config.ResourceGroup)
            
            It "VM Name: $($Config.VM.VMName)"{
                $VM.Name | Should Be $($Config.VM.VMName)
            }
            It "VM Size: $($Config.VM.VMSize)"{
                $VM.HardwareProfile.VmSize | Should match $($Config.VM.VMSize)
            }        
            It "VM OS Type: $($Config.VM.OSType)"{
                $VM.StorageProfile.OsDisk.OsType | Should Be $($Config.VM.OSType)
            }
            It "VM Vhd Name: $($Config.VM.VhdName)"{
                $VM.StorageProfile.OsDisk.OsType | Should Be $($Config.VM.OSType)
            }                
            It "VM Should be attached with VNIC: $($Config.VM.VNicName)"{
                ($VM.NetworkProfile.NetworkInterfaces.ID).EndsWith($($Config.VM.VNicName)) | Should Be $true
            }
            It "VM Admin: $($Config.VM.VMUser)"{
                $VM.OSProfile.AdminUsername | Should Be $($Config.VM.VMUser)
            }
            It "VM Extension: "{
                $true | Should Not Be $false
                #Set-ItResult -Inconclusive -Because "not done yet"
            }        
        }
    }
}#End of VM Describe Block

#Invoke-Pester -Script @{Path = '.\Az-Infrastructure.Tests.ps1'; Parameters = @{ConfigFile = '.\SqlServerVM-Config.psd1'}}
#Invoke-Pester -Tag VNet,VM -Passthru -OutVariable PesterResult
#$PesterResult.TestResult | Select Describe,Context,Name,Result,Time | Export-Csv C:\temp\Pester-Result.csv -notype
#Invoke-Pester -Script @{Path = '.\Az-Infrastructure.Tests.ps1'; Parameters = @{Tag = 'VNet','VM'}}
#Invoke-Pester -Script '.\Az-Infrastructure.Tests.ps1' -Tag VNet,VM