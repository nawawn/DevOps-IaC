@{
    Description   = 'Azure-WindowsVM'
    ResourceGroup = 'RG-IIS-01'
    Location      = 'uksouth'    
           
    Vnet = @{
        #Existing VNet Info
        VNetName   = 'Vnet-Test-Env'
        SubNetName = 'LAN-Subnet'
        VNetResourceGroup = 'RG-Vnet-Test-Env'
    }
    
    VM = @{
        VMName  = 'VM-IIS-01'
        VMSize  = 'Standard_B1s'        
        OSType  = 'Windows'        
        Offer   = 'WindowsServer'
        Skus    = '2016-Datacenter'
        Version = 'Latest'
        VhdName = 'OSD-IIS-01.vhd'
        CreateOption  = 'FromImage'
        PublisherName = 'MicrosoftWindowsServer'
        
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='

        VNicName = 'Vnic-IIS-01'
        PipName  = 'Pip-IIS-01'
        AllocationMethod = 'Dynamic'
    }      
}