@{
    Description   = 'Azure Virtual Network'
    ResourceGroup = 'RG-Vnet-Test-Env'
    Location      = 'uksouth'    
           
    VNet = @{
        VNetName   = 'Vnet-Test-Env'
        VNetAddr   = '10.7.0.0/16'
        SubNetName = 'LAN-Subnet'
        SubNetAddr = '10.7.0.0/24'
        GatewaySub = '10.7.1.0/24'
        NSGName    = 'NSG-Test-Env'
    }
    
    NsgRules = @{
        Rdp = @{
            Name                     = 'RDP'
            Description              = 'Allow RDP'
            Access                   = 'Allow'
            Protocol                 = 'TCP'
            Direction                = 'Inbound'
            Priority                 = 100
            SourceAddressPrefix      = 'Internet'
            SourcePortRange          = '*'
            DestinationAddressPrefix = '*' 
            DestinationPortRange     = 3389
        }
        Http = @{
            Name                     = 'HTTP'
            Description              = 'Allow HTTP'
            Access                   = 'Allow'
            Protocol                 = 'TCP'
            Direction                = 'Inbound'
            Priority                 = 110
            SourceAddressPrefix      = 'Internet'
            SourcePortRange          = '*'
            DestinationAddressPrefix = '*' 
            DestinationPortRange     = 80
        }
        Https = @{
            Name                     = 'HTTPS'
            Description              = 'Allow Secure HTTP'
            Access                   = 'Allow'
            Protocol                 = 'TCP'
            Direction                = 'Inbound'
            Priority                 = 111
            SourceAddressPrefix      = 'Internet'
            SourcePortRange          = '*'
            DestinationAddressPrefix = '*' 
            DestinationPortRange     = 443
        }
        Sql = @{
            Name                     = 'SQL'
            Description              = 'Allow SQL'
            Access                   = 'Allow'
            Protocol                 = 'TCP'
            Direction                = 'Inbound'
            Priority                 = 120
            SourceAddressPrefix      = 'VirtualNetwork'
            SourcePortRange          = '*'
            DestinationAddressPrefix = '*' 
            DestinationPortRange     = 1433
        }
        SSH = @{
            Name                     = 'SSH'
            Description              = 'Allow SSH'
            Access                   = 'Allow'
            Protocol                 = 'TCP'
            Direction                = 'Inbound'
            Priority                 = 130
            SourceAddressPrefix      = 'VirtualNetwork'
            SourcePortRange          = '*'
            DestinationAddressPrefix = '*' 
            DestinationPortRange     = 22
        }     
    }      
}