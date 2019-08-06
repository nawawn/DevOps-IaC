Function Test-AzPSSession{
    return($null -ne (Get-AzContext))
}
Function Test-PSDataFile{
    [CmdletBinding()]
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$FilePath
    )
    Process{         
        return ([IO.Path]::GetExtension($FilePath) -eq ".psd1")
    }
}
Function Test-ResourceGroup{
    [CmdletBinding()]    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$ResourceGroupName
    )
    process{         
        return ($null -ne (Get-AzResourceGroup -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue))
    }
}
Function New-ResourceGroup{
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$Location 
    )
    Process{
        New-AzResourceGroup -Name $Name -Location $Location
    }
}
Function Base64{
    Param([String]$Text)      
    return ([system.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Text)))   
}
Function New-Base64Credential{
    [OutputType([PSCredential])]
    Param(
        [Parameter(Mandatory)][String]$UserName,
        [Parameter(Mandatory)][String]$Base64            
    )    
    Return (New-Object -TypeName System.Management.Automation.PSCredential($UserName,(Base64 $Base64 | ConvertTo-SecureString -AsPlainText -Force)))
}