Function Get-OAuth2Token{
    Param()
    Process{
        If (-Not(Get-AzContext)){
            Write-Warning "Sign in to Azure PowerShell first!"
            Return
        }
        $TenantID  = (Get-AzTenant).Id
        $AzProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $RMProfile = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
        $Token = $RMProfile.AcquireAccessToken($TenantID)
        Return ($Token.AccessToken)
    } 
}

Function Test-NameAvailability{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$StorageName,
        [ValidateNotNullOrEmpty()][String]$SubscriptionID = (Get-AzSubscription -ErrorAction 'SilentlyContinue').ID,
        [Parameter(Mandatory)][String]$Token
    )
    Process{
        $Headers = @{
            'Host'          = 'management.azure.com'
            'Content-Type'  = 'application/json';
            'Authorization' = "Bearer $Token";
        }
        $RequestBody = @{
            'name' = $StorageName.ToLower()
            'type' = "Microsoft.Storage/storageAccounts"
        } | ConvertTo-Json

        $BaseUri = "https://management.azure.com/subscriptions/{0}/providers/Microsoft.Storage/checkNameAvailability?api-version=2019-04-01"
        $Uri = $BaseUri -f $SubscriptionID

        Return ((Invoke-RestMethod -Uri $Uri -Method POST -Headers $Headers -Body $RequestBody).NameAvailable)
    }
<#
.EXAMPLE    
    Test-NameAvailability -StorageName 'storagetest' -Token (Get-OAuth2Token)
#>
}

Function Test-StorageAccount{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name
    )
    Return ($null -ne (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $Name.ToLower() -ErrorAction 'SilentlyContinue'))
}

Function Test-BlobContainer{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$Name
    )
    $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName.ToLower() -ErrorAction 'SilentlyContinue').Context
    Return ($null -ne (Get-AzStorageContainer -Name $($Name.ToLower()) -Context $Context -ErrorAction 'SilentlyContinue'))
}

Function Test-FileShare{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$Name
    )
    $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName.ToLower() -ErrorAction 'SilentlyContinue').Context
    Return ($null -ne (Get-AzStorageShare -Name $($Name.ToLower()) -Context $Context -ErrorAction 'SilentlyContinue'))
}

Function Test-Table{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$Name
    )
    $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName.ToLower() -ErrorAction 'SilentlyContinue').Context
    Return ($null -ne (Get-AzStorageTable -Name $Name -Context $Context -ErrorAction 'SilentlyContinue'))
}

Function Test-Queue{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$Name
    )
    $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName.ToLower() -ErrorAction 'SilentlyContinue').Context
    Return ($null -ne (Get-AzStorageQueue -Name $($Name.ToLower()) -Context $Context -ErrorAction 'SilentlyContinue'))
}

Function New-StorageAccount{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String][ValidatePattern("[a-z]*")]$Name,
        [Parameter(Mandatory)][String]$Location,
        [Parameter(Mandatory)][String]$SkuName,
        [Parameter(Mandatory)][String]$Kind,
        [Parameter(Mandatory)][String]$AccessTier
    )
    Process{
        If (Test-NameAvailability -StorageName $Name -Token (Get-OAuth2Token)){
            New-AzStorageAccount -Name $($Name.ToLower()) -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $SkuName -Kind $Kind -AccessTier $AccessTier
        }
        Else { 
            Write-Warning "Name already taken, unable to create the storage account!"
        }        
    }
}

Function New-BlobContainer{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$StorageAccountName,        
        [Parameter(Mandatory)][String]$Permission
    )
    Process{
        $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
        New-AzStorageContainer -Name $($Name.ToLower()) -Permission $Permission -Context $Context
    }
}

Function New-FileShare{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$StorageAccountName        
    )
    Process{
        $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
        New-AzStorageShare -Name $($Name.ToLower()) -Context $Context
    }
}

Function New-Table{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$StorageAccountName
    )
    Process{
        #Allow Capital letter and Number on the name
        $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
        New-AzStorageTable -Name $Name -Context $Context
    }
}

Function New-Queue{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroupName,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$StorageAccountName
    )
    Process{
        $Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
        New-AzStorageQueue -Name $($Name.ToLower()) -Context $Context
    }
}