## DevOps-IaC
Infrastructure as Code Repo for Azure DevOps Pipeline

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




