@{
    Description   = 'Azure Site to Site VPN'
    #Resource group needs to be the same as VNet's
    ResourceGroup = 'RG-Vnet-Test-Env'
    Location      = 'uksouth'

    VNet = @{ 
        #This is for existing Vnet 
        Name          = 'Vnet-Test-Env'                      
        GatewaySub    = 'GatewaySubnet'
        
        VpnGwName   = 'VpnGw-Test-Env'
        GatewayType = 'Vpn'
        VpnType     = 'RouteBased'
        GatewaySku  = 'Basic'
        GwIpCfgName = 'VpnGw-IpConfig'
    }
    LAN =@{
        LanGwName  = 'OnPrem-Site'
        LanGwPip   = '202.135.4.18'
        LanAddress = @('10.4.0.0/16','10.132.0.0/16')
    }      
    VPN = @{      
        PipName = 'VpnGw-IP'
        AllocationMethod = 'Dynamic'       

        Name           = 'Conn-S2S-VPN'
        ConnectionType = 'IPSec'
        RoutingWeight  = '10'
        SharedKey      = 'R3VuRG9uP3RLMWxsUGUwcGxlUmFwcGVyc2Qw'
    }
}