# Solution Steps

## Create Azure account
- Personal Azure account was previously created, so just needed confirmation that Resource Group, Storage Account and Virtual Network could be created.

## Setup repository and folder/files
- Creating repository based on templates from [https://azure.microsoft.com/documentation/templates/](https://azure.microsoft.com/documentation/templates/)
- Added the deploy button based on [https://github.com/ehamai/HelloWorldDemo](https://github.com/ehamai/HelloWorldDemo)
- Install/Update VSCode extensions: [Azure templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-vscode-extension) and [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/core-powershell/vscode/using-vscode?view=powershell-6)

## Create initial deploy script
- Initial [deploy script for resource group](deploy.ps1) that assumes:
  - PowerShell v5.0+ is installed on machine and [Azure PowerShell modules](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps)
  - Running from the same folder as the [template file](azuredeploy.json)

## Add Storage Account to template file
- Add storage account to [template file](azuredeploy.json) that assumes:
  - Default SKU is `Standard_LRS`

## Add Virtual Network
- Add virtual network to template file

## Make templates more generic
- Tried to create a script myself to make virtual network more generic, but end it up instead using [this](https://github.com/Azure/azure-quickstart-templates/tree/master/301-subnet-driven-deployment)

## Add tag to resource group
- Research on how to add tag to resource group
- Find a solution to load from JSON file and convert to Hashtable

## Add policy definition and assignment
- Research on policy definition
- Create policy templates based on sample from [https://github.com/Azure/azure-policy/tree/master/samples](https://github.com/Azure/azure-policy/tree/master/samples)

## Final testing of script
- Tested the script for each part separately and then for the process as a whole. 