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

Describe 'Test-VirtualNIC'{
    Mock -CommandName 'Get-AzNetworkInterface' -MockWith {}
    Mock -CommandName Test-VirtualNIC -MockWith {
        Return $true
    }
    It 'Should return Boolean'{
        Test-VirtualNIC -Name 'Test-VNic' -ResourceGroupName 'RG-VNic' | Should BeOfType [Bool]
    }
}

Describe 'Test-PublicIP'{
    Mock -CommandName 'Get-AzPublicIpAddress' -MockWith {}
    Mock -CommandName Test-VirtualNIC -MockWith {
        Return $true
    }
    It 'Should return Boolean'{
        Test-PublicIP -Name 'Test-Pip' -ResourceGroupName 'RG-Test-Pip' | Should BeOfType [Bool]
    }
}

Describe 'Test-PublicIpOnVNic'{
    Mock -CommandName 'Get-AzNetworkInterface' -MockWith {}
    Mock -CommandName 'Test-PublicIpOnVNic' -MockWith {
        Return $true
    }
    It 'Should return Boolean'{
        Test-PublicIpOnVNic -VNicName 'Test-VNic' -ResourceGroupName 'RG-Test-VNic' | Should BeOfType [Bool]
    }
}

Describe 'Test-VirtualMachine'{
    Mock -CommandName 'Get-AzVM' -MockWith {}
    Mock -CommandName 'Test-VirtualMachine' -MockWith {
        Return $true
    }
    It 'Should return Boolean'{
        Test-VirtualMachine -ResourceGroupName 'RG-Test-VM' -Name 'Test-VM' | Should BeOfType [Bool]
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

Describe 'New-VirtualNIC'{
    Mock -CommandName 'Get-AzVirtualNetwork' -MockWith {}
    Mock -CommandName 'Get-AzVirtualNetworkSubnetConfig' -MockWith {}
    Mock -CommandName 'New-VirtualNIC' -MockWith {
        $hash = @{
            Name              = 'VNic-Name'
            ResourceGroupName = 'RG-Test-VM'
            Location          = 'uksouth'
            VNetName          = 'VNet-Name'
            VNetResourceGroup = 'RG-VNet-Name'
            SubnetName        = 'Lan-Subnet'
        }
        return $hash
    }
    It 'Should create Virtual NIC'{
        New-VirtualNIC -Name 'VNic-Name' -ResourceGroupName 'RG-Test-VM' -Location 'uksouth' -VNetName 'Vnet-Name' -VNetResourceGroup 'RG-Vnet-Name' -SubnetName 'Lan-Subnet' | Should Not Be $null
    }
}

Describe 'Add-PublicIpToVNic'{
    Mock -CommandName 'Get-AzPublicIpAddress' -MockWith {}
    Mock -CommandName 'Get-AzNetworkInterface' -MockWith {}
    Mock -CommandName 'Add-PublicIpToVNic' -MockWith {
        return $null
    }
    It 'Should add Public Ip to VNic'{
        Add-PublicIpToVNic -PipName 'Pip-Name' -VNicName 'VNic-Name' -ResourceGroupName 'RG-Test-VM' | Should Be $null
    }
}

Describe 'New-VirtualMachine'{
    Mock -CommandName 'New-AzVMConfig' -MockWith {}
    Mock -CommandName 'Set-AzVMOperatingSystem' -MockWith {}
    Mock -CommandName 'Set-AzVMSourceImage' -MockWith {}
    Mock -CommandName 'Add-AzVMNetworkInterface' -MockWith {}
    Mock -CommandName 'Get-AzNetworkInterface' -MockWith {}
    Mock -CommandName 'Set-AzVMOSDisk' -MockWith {}
    Mock -CommandName 'Set-AzVMBootDiagnostic' -MockWith {}
    Mock -CommandName 'New-VirtualMachine' -MockWith {
        $hash = @{
            Name              = 'VM-Name'
            ResourceGroupName = 'RG-Test-VM'
            Location          = 'uksouth'
            VmSize            = 'Standard_B1s'
            OSType            = 'Windows'
            ProvisioningState = 'Succeeded'
        }
        return $hash
    }
    $Passwd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $MyCred = New-Object System.Management.Automation.PSCredential ("username", $Passwd)
    It 'Should return a VM'{
        New-VirtualMachine -ResourceGroupName 'RG-Test-VM' -Location 'uksouth'  `
            -VMName 'VM-Name'       `
            -VMSize 'Standard_B1s'  `
            -OSType 'Windows'       `
            -Offer 'WindowsServer'  `
            -Skus '2016-Datacenter' `
            -Version 'Latest'       `
            -VhdName 'OSD-IIS-01.vhd'       `
            -CreateOption 'FromImage'       `
            -PublisherName 'MicrosoftWindows' `
            -VMCred $MyCred         `
            -VMNicId 'Some VM Id' | Should Not Be $null
    }
}