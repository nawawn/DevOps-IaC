@{
    Description   = 'Azure-SQL2017VM'
    ResourceGroup = 'RG-SQL-01'
    Location      = 'uksouth'    
           
    Vnet = @{
        #Existing VNet Info
        VNetName   = 'Vnet-Test-Env'
        SubNetName = 'LAN-Subnet'
        VNetResourceGroup = 'RG-Vnet-Test-Env'
    }
    
    VM = @{
        VMName  = 'VM-SQL-01'
        VMSize  = 'Standard_B1s'        
        OSType  = 'Windows'        
        Offer   = 'SQL2017-WS2016'
        Skus    = 'SQLDEV'
        Version = 'Latest'
        VhdName = 'OSD-SQL-01.vhd'
        CreateOption  = 'FromImage'
        PublisherName = 'MicrosoftSQLServer'
        
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='

        VNicName = 'Vnic-SQL-01'
        PipName  = 'Pip-SQL-01'
        AllocationMethod = 'Dynamic'
    }      
}