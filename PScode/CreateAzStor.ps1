Try{
    . "$PSScriptRoot\Modules\IaC.AzRG.ps1"
    . "$PSScriptRoot\Modules\IaC.AzStor.ps1"
}
Catch{
    Write-Warning "Unable to load IaC Functions"
}
Function New-AzStorEnv{
<#
.Synopsis
   Create New Storage Account with Blob, FileShare and Table on Azure platform
.DESCRIPTION
   This script creates a Storage account, a Blob Container, a FileShare and a Table on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   New-AzStorEnv -ConfigFile "..\Config\AzStor-Config.psd1"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        $ConfigFile	
    )

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

    Write-Verbose "[*] Creating a storage account: $($Config.Variables.StorageAccountName)"
    If (-Not(Test-StorageAccount -ResourceGroupName $Config.ResourceGroup -Name $Config.Variables.StorageAccountName)){
        New-StorageAccount -ResourceGroupName $Config.ResourceGroup `
            -Name $Config.Variables.StorageAccountName  `
            -Location $Config.Location                  `
            -SkuName $Config.Variables.SkuName          `
            -Kind $Config.Variables.Kind                `
            -AccessTier $Config.Variables.AccessTier    
    }
    Else{ Write-Verbose "[*] >> $($Config.Variables.StorageAccountName) already exists!" }

    Write-Verbose "[*] Creating a blob container: $($Config.Variables.ContainerName)"
    If (-Not(Test-BlobContainer -ResourceGroupName $Config.ResourceGroup -StorageAccountName $Config.Variables.StorageAccountName -Name $Config.Variables.ContainerName)){
        New-BlobContainer -ResourceGroupName $Config.ResourceGroup   `
            -Name $Config.Variables.ContainerName                    `
            -StorageAccountName $Config.Variables.StorageAccountName `
            -Permission $Config.Variables.Permission
    }
    Else{ Write-Verbose "[*] >> $($Config.Variables.ContainerName) already exists!" }

    Write-Verbose "[*] Creating a file share: $($Config.Variables.FileShareName)"
    If (-Not(Test-FileShare -ResourceGroupName $Config.ResourceGroup -StorageAccountName $Config.Variables.StorageAccountName -Name $Config.Variables.FileShareName)){
        New-FileShare -ResourceGroupName $Config.ResourceGroup -Name $Config.Variables.FileShareName -StorageAccountName $Config.Variables.StorageAccountName
    }
    Else{ Write-Verbose "[*] >> $($Config.Variables.FileShareName) already exists!" }

    Write-Verbose "[*] Creating an azure table: $($Config.Variables.TableName)"
    If (-Not(Test-Table -ResourceGroupName $Config.ResourceGroup -StorageAccountName $Config.Variables.StorageAccountName -Name $Config.Variables.TableName)){
        New-Table -ResourceGroupName $Config.ResourceGroup -Name $Config.Variables.TableName -StorageAccountName $Config.Variables.StorageAccountName
    }
    Else{ Write-Verbose "[*] >> $($Config.Variables.TableName) already exists!" }
}

Measure-Command -Expression {
    New-AzStorEnv -ConfigFile ..\Config\AzStor-Config.psd1 -Verbose
}