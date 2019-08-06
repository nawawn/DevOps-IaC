@{
    Description   = 'Azure-WindowsCoreVM'
    ResourceGroup = 'RG-Core-01'
    Location      = 'uksouth'   
           
    Vnet = @{
        #Existing VNet Info
        VNetName   = 'Vnet-Test-Env'
        SubNetName = 'LAN-Subnet'
        VNetResourceGroup = 'RG-Vnet-Test-Env'
    }
    
    VM = @{
        VMName  = 'VM-Core-01'
        VMSize  = 'Standard_B1s'        
        OSType  = 'Windows'        
        Offer   = 'WindowsServer'
        Skus    = '2019-Datacenter-Core'
        Version = 'Latest'
        VhdName = 'OSD-Core-01.vhd'
        CreateOption  = 'FromImage'
        PublisherName = 'MicrosoftWindowsServer'
        
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='

        VNicName = 'Vnic-Core-01'
        PipName  = 'Pip-Core-01'
        AllocationMethod = 'Dynamic'
    }
}