#requires -Module AzureRM.Resources

<#
.SYNOPSIS
  The purpose of this script is to create/update a Resource Group into Microsoft Azure with additional services.
.DESCRIPTION
  The purpose of this script is to create/update a Resource Group into Microsoft Azure with additional services.
.PARAMETER subscriptionId
  The subscription ID where resouce group will be updated (Default: current subscription).
.PARAMETER name
  The name of the resource group name to be updated (Default: azure-assessment).
.PARAMETER location
  The location of the resource group name to be updated (Default: westeurope).
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         eduardomourar
  Creation Date:  2018-06-11
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\deploy.ps1 -subscriptionId 15ce5c22-e175-4dbb-874a-fd0168d5081c -name azure-assessment -location westeurope
#>

#region Initialization and setup

param(
    [string] $subscriptionId,
    [string] $name = 'azure-assessment',
    [string] $location = 'westeurope'
)

Import-Module AzureRM -ErrorAction Stop

[hashtable] $commonParameters = @{
    ErrorAction = 'SilentlyContinue'
    Verbose = $true
    Debug = $false
}
[array] $resourceProviders = @('microsoft.authorization', 'microsoft.compute', 'microsoft.network', 'microsoft.storage')

#endregion

#region Functions

function retrieveSubscription([string] $subscription) {
    # Verify if user is logged in by querying his subscriptions.
    # If none is found assume he is not
    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Retrieving Azure subscription information..."
    Write-Host "**************************************************************************************************"
    try
    {
        $subscriptions = Get-AzureRmSubscription
        if (!($subscriptions)) {
            Login-AzureRmAccount 
        }
    }
    catch
    {
        Login-AzureRmAccount 
    }

    # Fail if we still can retrieve any subscription
    $subscriptions = Get-AzureRmSubscription
    if (!($subscriptions)) {
        Write-Host "Login failed or there are no subscriptions available with your account." -ForegroundColor Red
        Write-Host "Please logout using the command azure Remove-AzureAccount -Name [username] and try again." -ForegroundColor Red
        exit
    }

    if ($subscription.Length -gt 1) {
        Select-AzureRmSubscription -SubscriptionId $subscription
    } elseif ($subscriptions.Length -gt 1) { # If ID is not specified, get first subscription
        $subscription = $subscriptions.Get(0).SubscriptionId
    } else {
        $subscription = $subscriptions.SubscriptionId
    }

    $subscription = $subscription.Trim()

    Write-Host "Selected subscription ID: $subscription"

    return $subscription
}

function registerProviders([array] $resourceProviders) {
    # Register resource providers
    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Registering resource providers..."
    Write-Host "**************************************************************************************************"
    
    foreach ($resourceProvider in $resourceProviders) {
        Register-AzureRmResourceProvider -ProviderNamespace $resourceProvider @commonParameters
    }
}

function createResourceGroup([string] $groupName, [string] $groupLocation) {
    # Create or update the resource group
    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Creating resource group..."
    Write-Host "**************************************************************************************************"
    $resourceGroup = $null
    $resourceGroup = Get-AzureRmResourceGroup -Name $groupName -Location $groupLocation @commonParameters
    if (!$resourceGroup) {
        $resourceGroup = New-AzureRmResourceGroup -Name $groupName -Location $groupLocation -Force @commonParameters
    }

    Write-Host "Selected resource group name: $groupName"

    return $resourceGroup
}

function deployResources([string] $groupName) {
    # Deploy resources to Azure
    [string] $templateDeploy = '.\azuredeploy.json'
    [string] $parametersDeploy = '.\azuredeploy.parameters.json'
    [string] $deploymentName = ((Get-ChildItem $templateDeploy).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('yyMMdd-HHmm'))
    # [string] $templateUri = 'https://raw.githubusercontent.com/eduardomourar/azure-assessment/master/azuredeploy.json'
    $templateDeploy = [System.IO.Path]::Combine($PSScriptRoot, $templateDeploy)
    $parametersDeploy = [System.IO.Path]::Combine($PSScriptRoot, $parametersDeploy)
    
    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Deploying storage account and network resources..."
    Write-Host "**************************************************************************************************"
    $deployment = $null
    $deployment = New-AzureRmResourceGroupDeployment -Name $deploymentName `
                                                        -ResourceGroupName $groupName `
                                                        -TemplateParameterFile $parametersDeploy `
                                                        -TemplateFile $templateDeploy `
                                                        -Force @commonParameters
    if ($deployment.ProvisioningState -ne 'Succeeded') {
        Write-Error "Failed to provision the resources."
        exit 1
    }
    return $deployment
}

# From https://4sysops.com/archives/convert-json-to-a-powershell-hash-table/
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
 
    process {
        ## Return null if the input is null. This can happen when calling the function
        ## recursively and a property is null
        if ($null -eq $InputObject) {
            return $null
        }
 
        ## Check if the input is an array or collection. If so, we also need to convert
        ## those types into hash tables as well. This function will convert all child
        ## objects into hash tables (if applicable)
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $object
                }
            )
 
            ## Return the array but don't enumerate it because the object may be pretty complex
            Write-Output -NoEnumerate $collection
        } elseif ($InputObject -is [psobject]) { ## If the object has properties that need enumeration
            ## Convert it to its own hash table and return it
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        } else {
            ## If the object isn't an array, collection, or other object, it's already a hash table
            ## So just return it.
            $InputObject
        }
    }
}

function applyTags([string] $groupName) {
    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Applying tags to resource group..."
    Write-Host "**************************************************************************************************"
    [string] $resourceTags = '.\nested\resourcegroup-tags.json'
    $resourceTags = [System.IO.Path]::Combine($PSScriptRoot, $resourceTags)
    $resourceGroup = $null
    $resourceGroup = Get-AzureRmResourceGroup -Name $groupName @commonParameters
    $tags = $resourceGroup.Tags
    try {
        $tags += (Get-Content $resourceTags | ConvertFrom-Json | ConvertTo-Hashtable)
        $resourceGroup = Set-AzureRmResourceGroup -Name $groupName -Tag $tags -Force @commonParameters
    } catch {}
    if ($resourceGroup.ProvisioningState -ne "Succeeded") {
        Write-Error "Failed to tag resouce group."
        exit 1
    }
    return $resourceGroup
}

function assignPolicy([string] $assignmentScope) {
    # Define and assign policy
    [string] $templatePolicy = '.\nested\azurepolicy.json'
    [string] $parametersPolicy = '.\nested\azurepolicy.parameters.json'
    [string] $rulesPolicy = '.\nested\azurepolicy.rules.json'
    [string] $allowedResources = '.\nested\allowed-resourcetypes.json'
    [string] $assignmentName = ((Get-ChildItem $templatePolicy).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('yyMMdd-HHmm'))
    $parametersPolicy = [System.IO.Path]::Combine($PSScriptRoot, $parametersPolicy)
    $rulesPolicy = [System.IO.Path]::Combine($PSScriptRoot, $rulesPolicy)
    $allowedResources = [System.IO.Path]::Combine($PSScriptRoot, $allowedResources)

    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Defining and assigning policy..."
    Write-Host "**************************************************************************************************"
    $definition = $null
    $definition = New-AzureRmPolicyDefinition -Name "allowed-resourcetypes-custom" `
                                                -DisplayName "Allowed resource types (Custom)" `
                                                -Description "This policy enables you to specify the resource types that your organization can deploy." `
                                                -Policy $rulesPolicy `
                                                -Parameter $parametersPolicy `
                                                -Mode All @commonParameters

    $assignment = $null  
    $assignment = New-AzureRMPolicyAssignment -Name $assignmentName `
                                                -Scope $assignmentScope `
                                                -PolicyParameter $allowedResources `
                                                -PolicyDefinition $definition `
                                                @commonParameters
    return $assignment
}

#endregion

#region Azure deployment and policy assigment

$subscriptionId = retrieveSubscription($subscriptionId)
if ($subscriptionId.Length) {
    if ($resourceProviders.Length) {
        registerProviders -resourceProviders $resourceProviders
    }
    $resourceGroup = createResourceGroup -groupName $name -groupLocation $location
    deployResources -groupName $resourceGroup.ResourceGroupName
    applyTags -groupName $resourceGroup.ResourceGroupName
    assignPolicy -assignmentScope $resourceGroup.ResourceId

    Write-Host ""
    Write-Host "**************************************************************************************************"
    Write-Host "* Deployment of resources to Azure has been completed and policy has been assigned properly. "
    Write-Host "**************************************************************************************************"
}

#endregion
