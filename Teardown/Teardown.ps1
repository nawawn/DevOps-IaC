#This should be an idependent script.
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
Function Remove-ResourceGroup{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)]
        [String[]]$ConfigFile
    )
    Process{
        $Config = Import-PowerShellDataFile -Path $ConfigFile
        Write-Verbose "[*] Processing Config File: $ConfigFile"
        If (Test-ResourceGroup -ResourceGroupName $Config.ResourceGroup){
            Write-Warning ">>> Removing Resource Group: $($Config.ResourceGroup)"
            Remove-AzResourceGroup -Name $Config.ResourceGroup -Force
        }
    }
}

Function Remove-TestEnvironment{
    [CmdletBinding()]
    Param(
        [ValidateRange(1,9)]
        [Byte]$Try = 1
    )
    $Count = 0
    Do{
        $FileList = (Get-ChildItem "..\Config").FullName 
        [Array]::Reverse($FileList) 
        $FileList | Remove-ResourceGroup
        $Count++        
    }Until($Count -ge $Try)
}

#Measure-Command -Expression {(Get-ChildItem "..\Config").FullName | Remove-ResourceGroup -Verbose}
#Try 2 times
Measure-Command -Expression {    
    Remove-TestEnvironment -Try 2 -Verbose
}