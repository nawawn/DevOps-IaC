$DirStruct = @(
    '.\Config',
    '.\DSC',
    '.\PScode',
    '.\Teardown',
    '.\Tests',
    '.\azure-pipelines.yml',
    '.\Get-MyAzEnv.ps1',
    '.\Config\AzStor-Config.psd1',
    '.\Config\AzVnet-Config.psd1',
    '.\Config\AzVPN-Config.psd1',
    '.\Config\CoreVm-Config.psd1',
    '.\Config\LinuxVM-Config.psd1',
    '.\Config\SqlVM-Config.psd1',
    '.\Config\WinVM-Config.psd1',
    '.\DSC\IIS-Dsc.ps1',
    '.\PScode\Modules',
    '.\PScode\ApplyDSC.ps1',
    '.\PScode\CreateAzStor.ps1',
    '.\PScode\CreateAzVnet.ps1',
    '.\PScode\DeployAzVM.ps1',
    '.\PScode\DeployAzVpn.ps1',
    '.\PScode\Modules\IaC.AzRG.ps1',
    '.\PScode\Modules\IaC.AzRG.Tests.ps1',
    '.\PScode\Modules\IaC.AzStor.ps1',
    '.\PScode\Modules\IaC.AzStor.Tests.ps1',
    '.\PScode\Modules\IaC.AzVM.ps1',
    '.\PScode\Modules\IaC.AzVM.Tests.ps1',
    '.\PScode\Modules\IaC.AzVNet.ps1',
    '.\PScode\Modules\IaC.AzVNet.Tests.ps1',
    '.\PScode\Modules\IaC.AzVPN.ps1',
    '.\PScode\Modules\IaC.AzVPN.Tests.ps1',
    '.\Teardown\Teardown.ps1',
    '.\Tests\FileValidation.Tests.ps1',
    '.\Tests\Infrastructure.Tests.ps1'    
)

Describe "Directory Structure Validation"{   
    Foreach ($item in $DirStruct){
        It "Should exist: $item" {
            Test-Path $item | Should be $true
        }
        If (-Not (Get-Item $item).PSIsContainer){
            It "File should not be empty" {
                (Get-Item $item).length | Should BeGreaterThan 1
            }
        }
    }    
}
