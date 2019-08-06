Try{
    . "$PSScriptRoot\Modules\IaC.AzRG.ps1"
}
Catch{
    Write-Warning "Unable to load IaC Functions"
}

Function Invoke-Dsc{
<#
.Synopsis
   Publish and apply DSC to a VM on Azure
.DESCRIPTION
   This script publishes a dsc script to a blob container and apply it to a VM on the Azure environment.
   The script takes config files, dscfile and configuration name as parameters.
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   Invoke-Dsc -VmConfigFile ".\CoreVM-Config.psd1" -StorConfigFile ".\AzStor-Config.psd1" -DscFile ".\IIS-Dsc.ps1" -ConfigurationName 'WebServer'
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)][String]$VmConfigFile,
        [Parameter(Mandatory)][String]$StorConfigFile,
        [Parameter(Mandatory)][String]$DscFile,
        [Parameter(Mandatory)][String]$ConfigurationName
    )

    Write-Verbose "[*] Checking VM Config File..."
    If((Test-Path $vmConfigFile -PathType Leaf) -and (Test-PSDataFile $VmConfigFile)){
        $VmConfig = Import-PowerShellDataFile -Path $VmConfigFile
        Write-Verbose "[*] - Config File imported OK!"
    }
    Else {
        Write-Warning "$VmConfigFile : File not found or incorrect format"
        return
    }
    
    Write-Verbose "[*] Checking Storage Config File..."
    If((Test-Path $StorConfigFile -PathType Leaf) -and (Test-PSDataFile $StorConfigFile)){
        $StorConfig = Import-PowerShellDataFile -Path $StorConfigFile
        Write-Verbose "[*] - Config File imported OK!"
    }
    Else {
        Write-Warning "$StorConfigFile : File not found or incorrect format"
        return
    }
    Write-Verbose "[*] Checking DSC File Path..."
    If(Test-Path -Path $DscFile -PathType Leaf){
        Write-Verbose "[*] - Dsc File is present!"
    }
    Else {
        Write-Warning "$DscFile : File not found"
        return
    }

    Write-Verbose "[*] Checking Azure PowerShell Session..."
    If(-Not(Test-AzPSSession)){
        Connect-AzAccount    
    }

    $CfgParam = @{
        'ResourceGroupName'  = $StorConfig.ResourceGroup
        'StorageAccountName' = $StorConfig.Variables.StorageAccountName
        'ContainerName'      = $StorConfig.Variables.ContainerName
        'ConfigurationPath'  = $DscFile
    }
    Publish-AzVMDscConfiguration @CfgParam -Force

    $DscParam = @{
        'Version'           = '2.76'
        'ResourceGroupName' = $VmConfig.ResourceGroup
        'VmName'            = $VmConfig.VM.VMName
        'ArchiveResourceGroupName'  = $StorConfig.ResourceGroup
        'ArchiveStorageAccountName' = $StorConfig.Variables.StorageAccountName
        'ArchiveContainerName'      = $StorConfig.Variables.ContainerName
        'ArchiveBlobName'           = $((Get-Item -Path $DscFile).Name) + ".zip"
        'AutoUpdate'                = $true   
        'ConfigurationName'         = $ConfigurationName
    }
    Set-AzVMDscExtension @DscParam -Force
}

Measure-Command -Expression {
    Invoke-Dsc -VmConfigFile '..\Config\CoreVm-Config.psd1'  `
        -StorConfigFile '..\Config\AzStor-Config.psd1'       `
        -DscFile '..\DSC\IIS-Dsc.ps1'                           `
        -ConfigurationName 'WebServer' -Verbose
}