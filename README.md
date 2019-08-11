## DevOps-IaC  
[![Build Status](https://naweducation.visualstudio.com/AzureIaaS/_apis/build/status/nawawn.DevOps-IaC?branchName=master)](https://naweducation.visualstudio.com/AzureIaaS/_build/latest?definitionId=3&branchName=master)  
Infrastructure as Code Repo for Azure DevOps Pipeline 

![AzureNetworkDiagram](/images/DevOps-IaC.png)

### What it does 
The codes in this repo are purely PowerShell script, except for the azure-pipeline ymal file which obviously is the pipeline ymal file for Azure Devops pipeline. The scripts will create:
* Azure Virtual Network 
* Site-to-Site VPN Connection 
* Storage Account
* Virtual Machine 

### Folder Structure
__PScode__ This folder contains all the PowerShell scripts that create the required component in Azure IaaS platform. The subfolder **'Modules'** includes all the scripts composed of functions which are then called and used by the main scripts. Pester scripts to test each functions are also included in this subfolder.

__Config__ This folder contains all configuration data in psd1 file format for the required azure components. These are consumed by the main scripts in PScode folder.

__DSC__ This folder contains the PowerShell DSC script for the VM(s). More works to be continued for SqlServerDsc...

__Tests__ This folder contains infrastructure test script written in Pester. This script validate what has been built by the main sripts.

__Teardown__ This folder cotains the script to teardown the whole infrastructure built by the main scripts.

### What you need
1. an Azure account, create one if you don't have one already. https://portal.azure.com/
2. an Azure Devops account. It is free to use, limited to five collaborators. https://dev.azure.com/

### How to set this up
1. Create a project in Azure Devops then Create a new Azure Pipline within that project.
2. Where is your code? Choose Github Yaml.
3. Sign in to your github when prompt.
4. Grab the right repo and click on Approve and install
5. You may also need to authorize to be able to make changes into your Github repo
6. Once it's all set up, You can run your pipeline by pressing the Queue button. 

### Script explanation
**CreateAzVnet.ps1** - creates an Azure Virtual Network with LAN-Subnet and Gateway subnet. Network Security Group is also created and attached to the LAN-Subnet as part of the process.  
**DeployAzVpn.ps1** - sets up the site-to-site VPN connection to your On-Premises environment. This script can take up to 25 minutes.  
**CreateAzStor.ps1** - creates a storage account and provisions a blob container, an SMB file share and a table.  
**DeployAzVM.ps1** - deploys virtual machine(s) on Azure IaaS platform within the Virtual Network created by Vnet creation script.  
**ApplyDSC.ps1** - publishes the DSC script to blob container and apply the DSC on the virtual machine.  
**FileValidation.Tests.ps1** - validates the script files and folders structure after checkout.  
**Infrastructure.Tests.ps1** - runs Infrastructure test against the Azure environment after the build.  
**Teardown.ps1** - destroys the whole environment built.  

