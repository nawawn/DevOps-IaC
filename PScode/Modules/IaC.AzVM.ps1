Function Test-VirtualNIC{
    [CmdletBinding()]    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroupName
    )
    process{         
        return ($null -ne (Get-AzNetworkInterface -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    }
}

Function Test-PublicIp{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$Name,        
        [Parameter(Mandatory)][String]$ResourceGroupName
    )
    Process{
        return ($null -ne (Get-AzPublicIpAddress -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'))
    } 
}

Function Test-PublicIpOnVNic{
    [OutputType([Bool])]
    Param(                
        [Parameter(Mandatory)][String]$VNicName,
        [Parameter(Mandatory)][String]$ResourceGroupName       
    )
    Process{        
        $Nic = Get-AzNetworkInterface -Name $VNicName -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'
        Return ($null -ne $($Nic.IpConfigurations[0].PublicIpAddress))
        
    }
}

Function Test-VirtualMachine{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name        
    )
    process{         
        return ($null -ne (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction 'SilentlyContinue'))
    }
}

Function New-PublicIP{
    #[Mircosoft.Azure.Commands.Network.Models.PSPublicIpAddress]
    Param(
        [Parameter(Mandatory)][String]$Name,        
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Location,
        [Parameter(Mandatory)][String]$AllocationMethod
    )
    Process{
        #Only Dynamic IP address assignment is supported for VPN gateway
        New-AzPublicIpAddress -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod $AllocationMethod
    }
}

Function New-VirtualNIC{
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Location,
        [Parameter(Mandatory)][String]$VNetName,
        [Parameter(Mandatory)][String]$VNetResourceGroup,
        [Parameter(Mandatory)][String]$SubnetName
    )
    Process{
        $PSVNet   = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroup
        $SubnetId = (Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $PSVNet).Id
        New-AzNetworkInterface -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $SubnetId
    }    
}

Function Add-PublicIpToVNic{
    Param(
        [Parameter(Mandatory)][String]$PIpName,        
        [Parameter(Mandatory)][String]$VNicName,
        [Parameter(Mandatory)][String]$ResourceGroupName       
    )
    Process{
        $PIp = Get-AzPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName
        $Nic = Get-AzNetworkInterface -Name $VNicName -ResourceGroupName $ResourceGroupName
        $Nic.IpConfigurations[0].PublicIpAddress = $PIp
        Set-AzNetworkInterface -NetworkInterface $Nic
    }
}

Function New-VirtualMachine{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Location,
        [Parameter(Mandatory)][String]$VMName,
        [Parameter(Mandatory)][String]$VMSize, 
        [ValidateSet("Windows","Linux")]$OSType,
        [Parameter(Mandatory)][String]$Offer,  
        [Parameter(Mandatory)][String]$Skus,   
        [Parameter(Mandatory)][String]$Version,
        [Parameter(Mandatory)][String]$VhdName,
        [Parameter(Mandatory)][String]$CreateOption,
        [Parameter(Mandatory)][String]$PublisherName,        
        [Parameter(Mandatory)][PSCredential]$VMCred,
        [Parameter(Mandatory)][String]$VMNicId
    )
    Process{
        Write-Information "Creating the VM Configuration..."
        $VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize
        $VMConfig = If ($OSType -eq 'Windows') { 
                        Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential $VMCred
                    }
                    Else { 
                        Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $VMName -Credential $VMCred
                    }
        $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $Skus -Version $Version
        $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $VMNicId
        $VMConfig = Set-AzVMOSDisk -VM $VMConfig -Name $VhdName -CreateOption $CreateOption
        $VMConfig = Set-AzVMBootDiagnostic -VM $VMConfig -Disable
    
        Write-Information "Deploying the Virtual Machine..."
        New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig
    }
}