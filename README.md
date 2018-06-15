# Azure Assessment

## Resources to be deployed

- Storage Account
- Virtual Network

## Deployment

### PowerShell Script

You can run the script to create/update a Resource Group into Microsoft Azure with additional services:
```
.\deploy.ps1 -subscriptionId 15ce5c22-e175-4dbb-874a-fd0168d5081c -name azure-assessment -location westeurope
```

- `subscriptionId`: The subscription ID where resouce group will be updated (Default: **current subscription**).
- `name`: The location of the resource group name to be updated (Default: **westeurope**).
- `location`: The name of the resource group name to be updated (Default: **azure-assessment**).

### Deploy Button

By clicking on the deploy button below, the basic template (it does not include tagging and policy creation) will be deployed to Azure subscription selected.

[![Deploy Resources to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/) [![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Feduardomourar%2Fazure-assessment%2Fmaster%2Fazuredeploy.json)

## More details

* [Assessment](docs/assessment.md)

* [Time log](docs/time-log.md)

* [Solution Steps](docs/solution-steps.md)