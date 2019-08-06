@{  
    Description   = 'Azure Storage Account'
    ResourceGroup = 'RG-Storage'
    Location      = 'uksouth'

    Parameters = @{}
    Variables  = @{
        StorageAccountName = "stordevtest"
        SkuName            = 'Standard_LRS'
        Kind               = 'StorageV2'
        AccessTier         = 'Hot'

        ContainerName      = 'powershell-dsc'
        Permission         = 'Blob'
        FileShareName      = 'az-share'
        TableName          = 'LogTable'
    }
}