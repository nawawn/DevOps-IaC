Try{
    . "$PSScriptRoot\Modules\IaC.AzRG.ps1"
    . "$PSScriptRoot\Modules\IaC.AzVM.ps1"
}
Catch{
    Write-Warning "Unable to load IaC Functions"
}
Function Deploy-VM{
<#
.Synopsis
   Deploy VM on the Azure IaaS platform
.DESCRIPTION
   This script deploys Virtual Machine on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   Deploy-VM -ConfigFile "..\Config\WindowsVM-Config.psd1"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        $ConfigFile	
    )

    #region VM Deployment
    
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

    Write-Verbose "[*] Creating a Virtual NIC: $($Config.VM.VNicName)"
    If (-Not(Test-VirtualNIC -Name $Config.VM.VNicName -ResourceGroupName $Config.ResourceGroup)){
        New-VirtualNIC -Name $Config.VM.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location `
                       -VNetName $Config.VNet.VNetName -VNetResourceGroup $Config.VNet.VNetResourceGroup -SubnetName $Config.VNet.SubnetName
    }
    Else { Write-Verbose "[*] >> $($Config.VM.VNicName) already exists!" }

    Write-Verbose "[*] Acquiring a Public Ip: $($Config.VM.PipName)"
    If (-Not(Test-PublicIP -Name $Config.VM.PipName -ResourceGroupName $Config.ResourceGroup)){
        New-PublicIP -Name $Config.VM.PipName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AllocationMethod $Config.VM.AllocationMethod
    }
    Else { Write-Verbose "[*] >> $($Config.VM.PipName) already exists!" }

    Write-Verbose "[*] Assigning Public Ip to VNic: $($Config.VM.PipName) -> $($Config.VM.VNicName)"
    If (-Not(Test-PublicIpOnVNic -VNicName $Config.VM.VNicName -ResourceGroupName $Config.ResourceGroup)){
        Add-PublicIpToVNic -PipName $Config.VM.PipName -VNicName $Config.VM.VNicName -ResourceGroupName $Config.ResourceGroup
    }
    Else { Write-Verbose "[*] >> $($Config.VM.VNicName) already has Public Ip!" }

    Write-Verbose "[*] Creating a Virtual Machine: $($Config.VM.VMName)"
    If (-Not(Test-VirtualMachine -Name $Config.VM.VMName -ResourceGroupName $Config.ResourceGroup)){
        $NewVM = @{}
        $NewVM.Add('ResourceGroupName',$($Config.ResourceGroup))
        $NewVM.Add('Location',      $($Config.Location))
        $NewVM.Add('VMName',        $($Config.VM.VMName))
        $NewVM.Add('VMSize',        $($Config.VM.VMSize))
        $NewVM.Add('OSType',        $($Config.VM.OSType))
        $NewVM.Add('Offer',         $($Config.VM.Offer))
        $NewVM.Add('Skus',          $($Config.VM.Skus))
        $NewVM.Add('Version',       $($Config.VM.Version))        
        $NewVM.Add('VhdName',       $($Config.VM.VhdName))
        $NewVM.Add('CreateOption',  $($Config.VM.CreateOption))
        $NewVM.Add('PublisherName', $($Config.VM.PublisherName))
        $NewVM.Add('VMCred',        $(New-Base64Credential -UserName $($Config.VM.VMUser) -Base64 $($Config.VM.VMPass)))
        $NewVM.Add('VMNicId',       $((Get-AzNetworkInterface -Name $($Config.VM.VNicName) -ResourceGroupName $($Config.ResourceGroup)).Id))
        
        New-VirtualMachine @NewVM
    }
    Else { Write-Verbose "[*] >> $($Config.VM.VMName) already exists!" }
}

Measure-Command -Expression {
    Deploy-VM -ConfigFile ..\Config\CoreVm-Config.psd1 -Verbose
    #Deploy-VM -ConfigFile ..\Config\WinVM-Config.psd1 -Verbose
    #Deploy-VM -ConfigFile ..\Config\SqlVM-Config.psd1 -Verbose
    #Deploy-VM -ConfigFile ..\Config\LinuxVM-Config.psd1 -Verbose
}