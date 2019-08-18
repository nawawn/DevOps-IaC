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
        File Index
        {
            DestinationPath = 'C:\inetpub\wwwroot\index.html'
            Type            = 'File'
            Contents        = $html
            Ensure          = 'Present'
            DependsOn       = '[WindowsFeature]IIS'
        }    
    }
}
$html = @'
<html>
    <head><title>Azure Infrastructure</title>
        <style>
            .center{
                margin: auto; width: 50%; border: 4px solid #93BD25; padding: 10px;
            }
        </style>
    </head>
    <body>
    <div class="center" style="background-color:lightgray;">
        <h3>A Journey to One Click of a Button</h3><hr />
        <p>Or is it rather two clicks with <button type="button">Queue</button> and <button type="button"> Run </button></p>
        <p>Or no click at all (using CI pipeline)</p>
        <br /><br /><br /><br /><br />
    </div>
    </body>
</html>
'@