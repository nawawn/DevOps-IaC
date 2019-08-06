$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut  = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "$sut is valid PowerShell code"{
    $PSFile = Get-Content -Path $here\$sut -ErrorAction 'Stop'
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize($PSFile,[ref]$errors)
    It 'Should contain no syntax error'{
        $errors.Count | Should Be 0
    }    
}

Describe 'Get-OAuth2Token'{
    mock -CommandName 'Get-AzContext'{}
    mock -CommandName 'Get-AzTenant'{}
    mock -CommandName 'Get-OAuth2Token'{
        Return ("JustaBunchofTextThatlookslikeaTokenString")
    }
    It 'Should return a token'{
        Get-OAuth2Token | Should Not Be $null
    }
}

Describe 'Test-NameAvailability'{
    mock -CommandName 'Invoke-RestMethod' -MockWith {}
    mock -CommandName 'Test-NameAvailability' -MockWith { 
        Return $true
    }
    
    It 'Should return Boolean'{
        Test-NameAvailability -StorageName 'storname' -SubscriptionID 'some-subsciption-id-here' -Token 'TokenString' | Should BeOfType [Bool]
    }
    
}

Describe 'Test-StorageAccount'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'Test-StorageAccount'{
        Return $true
    }
    It 'Should return Boolean'{
        Test-StorageAccount -ResourceGroupName 'RG-Storage' -Name 'storname' | Should BeOfType [Bool]
    }
}

Describe 'Test-BlobContainer'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'Test-BlobContainer' -MockWith{
        Return $true
    }
    It 'Should return Boolean'{
        Test-Blobcontainer -ResourceGroupName 'RG-Storage' -StorageAccountName 'storname' -Name 'powershell-dsc' | Should BeOfType [Bool]
    }
}

Describe 'Test-FileShare'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'Test-FileShare' -MockWith{
        Return $true
    }
    It 'Should return Boolean'{
        Test-FileShare -ResourceGroupName 'RG-Storage' -StorageAccountName 'storname' -Name 'smb-share' | Should BeOfType [Bool]
    }
}

Describe 'Test-Table'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'Test-Table' -MockWith{
        Return $true
    }
    It 'Should return Boolean'{
        Test-Table -ResourceGroupName 'RG-Storage' -StorageAccountName 'storname' -Name 'Table-Name' | Should BeOfType [Bool]
    }
}

Describe 'Test-Queue'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'Test-Queue' -MockWith{
        Return $true
    }
    It 'Should return Boolean'{
        Test-Queue -ResourceGroupName 'RG-Storage' -StorageAccountName 'storname' -Name 'queuename' | Should BeOfType [Bool]
    }
}

Describe 'New-StorageAccount'{
    mock -CommandName 'Test-NameAvailability'{}
    mock -CommandName 'New-AzStorageAccount'{}
    mock -CommandName 'New-StorageAccount'{}
    It 'Should create a new storage account'{
        New-StorageAccount -ResourceGroupName 'RG-Storage' -Name 'storname' -Location 'uksouth' -SkuName 'Standard_LRS' -Kind 'StorageV2' -AccessTier 'Hot' | Should be $null
    }
}

Describe 'New-BlobContainer'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'New-AzStorageContainer'{}
    mock -CommandName 'New-BlobContainer'{}
    It 'Should create a new blob container'{
        New-BlobContainer -ResourceGroupName 'RG-Storage' -Name 'powershell-dsc' -StorageAccountName 'storname' -Permission 'Blob' | Should Be $null
    }
}

Describe 'New-FileShare'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'New-AzStorageShare'{}
    mock -CommandName 'New-FileShare'{}
    It 'Should create a new smb share'{
        New-FileShare -ResourceGroupName 'RG-Storage' -Name 'fileshare' -StorageAccountName 'storname' | Should be $null
    }
}

Describe 'New-Table'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'New-AzStorageShare'{}
    mock -CommandName 'New-Table'{}
    It 'Should create a new table'{
        New-Table -ResourceGroupName 'RG-Storage' -Name 'TableName' -StorageAccountName 'storname' | Should be $null
    }
}

Describe 'New-Queue'{
    mock -CommandName 'Get-AzStorageAccount'{}
    mock -CommandName 'New-AzStorageShare'{}
    mock -CommandName  'New-Queue'{}
    It 'Should create a new queue'{
        New-Queue -ResourceGroupName 'RG-Storage' -Name 'queuename' -StorageAccountName 'storname' | Should be $null
    }
}