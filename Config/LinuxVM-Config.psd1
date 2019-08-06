@{
    Description   = 'Azure-LinuxVM'
    ResourceGroup = 'RG-NGX-01'
    Location      = 'uksouth'    
           
    Vnet = @{
        #Existing VNet Info
        VNetName   = 'Vnet-Test-Env'
        SubNetName = 'LAN-Subnet'
        VNetResourceGroup = 'RG-Vnet-Test-Env'
    }
    
    VM = @{
        VMName  = 'VM-NGX-01'
        VMSize  = 'Standard_B1s'        
        OSType  = 'Linux'        
        Offer   = 'UbuntuServer'
        Skus    = '18.04-LTS'
        Version = 'Latest'
        VhdName = 'OSD-NGX-01.vhd'
        CreateOption  = 'FromImage'
        PublisherName = 'Canonical'
        
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='

        VNicName = 'Vnic-NGX-01'
        PipName  = 'Pip-NGX-01'
        AllocationMethod = 'Dynamic'
    }      
}