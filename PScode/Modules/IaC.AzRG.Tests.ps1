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
Describe 'Test-AzPSSession'{
    Mock -CommandName 'Get-AzContext' -MockWith {
        $AzCtx = New-Object Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext
        return ($null -ne $AzCtx)
    }
    It 'Should return Boolean'{
        Test-AzPSSession | Should BeOfType [Bool]
    }
    It 'Should return true'{
        Test-AzPSSession | Should Be $true
    }
}
Describe 'Test-PSDataFile'{
    Mock -CommandName 'Test-PSDataFile' -MockWith {        
        [Bool]$Result = $true
        return ($Result)
    }
    It 'Should return Boolean'{
        Test-PSDataFile -FilePath $here | Should BeOfType [Bool]
    }
}
Describe 'Test-ResourceGroup'{
    Mock -CommandName 'Get-AzResourceGroup' -MockWith {
        $AzRG = New-Object Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup
        return ($null -ne $AzRG)
    }
    It 'Should return Boolean'{
        Test-ResourceGroup -ResourceGroupName 'RG-Name' | Should BeOfType [Bool]
    }
}
Describe 'New-ResourceGroup'{
    Mock -CommandName 'New-AzResourceGroup' -MockWith {
        $AzRG = New-Object Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup
        return ($AzRG)
    }
    It 'Should return PSResourceGroup'{
        New-ResourceGroup -Name 'RG-Name' -Location 'uksouth' | Should BeOfType [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]
    }
}
Describe 'Base64'{
    Mock -CommandName Base64 -MockWith{
        return ('SomeText')
    }
    It 'Should return some text'{
        Base64 -Text 'SomeText' | Should Be 'SomeText'
    }
}
Describe 'New-Base64Credential'{
    Mock -CommandName Base64 {}
    Mock -CommandName New-Base64Credential -MockWith{
        $Credential = New-Object PSCredential -ArgumentList ([pscustomobject] @{ 
            UserName = '';
            Password = (ConvertTo-SecureString -AsPlainText -Force -String 'abc123')[0]
        })
        return ($Credential)
    }
    It 'Should return Credential Object'{
        New-Base64Credential -UserName 'RootAdmin' -Base64 'abc123' | Should BeOfType [PSCredential]
    }
}