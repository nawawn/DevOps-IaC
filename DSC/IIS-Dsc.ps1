Configuration WebServer {
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Node 'localhost'
    {   
        WindowsFeature IIS
        {
            Name   = 'Web-Server'             
            Ensure = 'Present'    
        }
        WindowsFeature InetMgr
        {
            Name   = "Web-Mgmt-Console"
            Ensure = "Present"
        }
        File WebSiteRoot
        {
            DestinationPath = 'C:\inetpub\wwwroot\Reports'
            Type            = 'Directory'
            Ensure          = 'Present'
            DependsOn       = '[WindowsFeature]IIS'
        }    
    }
}