# Assessment
Please be aware of the following:
- We are looking for not only the actual solution but also the road to the solution, please include that as well in GIT.
  - The focus will be on why you have chosen a certain way to approach this assignment
  - We could understand that you might need to make some assumptions during this assessment, please write down the assumptions you make as well
- Please include a simple time log as well of the activities performed by you, so we have some indication of your speed ;-)
  - TIP: If your time log is really fast, we will expect this from you constantly :-)
- Do not be afraid to use your own creativity and show us more than we have requested if you think some things could be handy as well
- Key aspect we would like to see are:
  - Reusability
  - Flexibility
  - Robustness

The assignment:
- Sign up for a free Azure account at [https://azure.microsoft.com/nl-nl/free/](https://azure.microsoft.com/nl-nl/free/)

Create a deployment script, using template and parameter files, to deploy below-listed items, in a secure manner, to the Azure subscription:
- a Resource Group in West Europe
- a Storage Account in the above created Resource Group, using encryption and an unique name, starting with the prefix 'sentia'
- A Virtual Network in the above created Resource Group with three subnets, using 172.16.0.0/12 as the address prefix
- Apply the following tags to the resource group: Environment='Test', Company='Sentia'
- Create a policy definition using a template and parameter file, to restrict the resourcetypes to only allow: compute, network and storage resourcetypes
- Assign the policy definition to the subscription and resource group you created previously

Deliverable:
- Provide us with a public GitHub repository containing the assignment.

Interesting readups:
GIT:
- [https://git-scm.com/book/en/v2/Getting-Started-Git-Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [http://readwrite.com/2013/09/30/understanding-github-a-journey-for-beginners-part-1](http://readwrite.com/2013/09/30/understanding-github-a-journey-for-beginners-part-1)

ARM:
- [https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)

Azure Policy:
- [https://docs.microsoft.com/en-us/azure/azure-policy/azure-policy-introduction](https://docs.microsoft.com/en-us/azure/azure-policy/azure-policy-introduction)