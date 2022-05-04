# Azure 
Azure tips.

## Azure VM Instances
For a nice view of what VM instances Azure offers, with pricing, etc. go to <https://azureprice.net/?sortField=linuxPrice&sortOrder=true>

## Installing the Azure CLI Tool
The Azure CLI tool is essentially the [Azure Python SDK](https://docs.microsoft.com/en-us/azure/developer/python/configure-local-development-environment?tabs=bash) itself, since it is written in Python. Use below table to install in respective OS or environment:

| OS | Command |
| --- | --- |
| [macOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest) | `brew update && brew install azure-cli` |
| [Ubuntu Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest) | `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash` |
| [Windows](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli) | <== Click on link |
| [Docker](https://docs.microsoft.com/en-us/cli/azure/run-azure-cli-docker?view=azure-cli-latest)  | docker run -it mcr.microsoft.com/azure-cli |

## Create VM
Example of how to create an Azure VM using the `az` CLI tool.

- Create VM, resource, group and VNET all at once
```
az vm create --name myvm01 --resource-group myrs --admin-username admin --admin-password secure --image "OpenLogic:CentoOS:7.6:7.6.20190402" --vnet name myvnet --subnet mysubnet --size Standard_B1ms
```

- Create VM into existing subnet (need subnet ID)
```
az vm create --name myvm01 --resource-group myrs --admin-username admin --admin-password secure --image "OpenLogic:CentoOS:7.6:7.6.20190402" --subnet "/subscriptions/long-ass-name" --size Standard_B1ms
```

## SSH to AKS Cluster Node
This is not generally recommended, but there are time, while experimenting in a lower environment when you may need to SSH into an ASK cluster node:

- Set account: `az account set -s sub1000`

- Get AKS node resource group
```
az aks show -n myakscluster --resource-group myresgroup --query nodeResourceGroup -o tsv
MC_myakscluster1_resgroup_eastus2
```

- List nodes in that RS
```
az vmss list --resource-group MC_myakscluster1_resgroup_eastus2 --query [0].name -o tsv
aks-agentx-18680543-vmss
```

 - Locate your SSH public key
```
cat /home/user1/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdF94RyNcx7hrLqFrcymWrYhOUivuuGn3frnT1/g7g+ user1@example.com
```

- Add you SSH key to the set
```
az vmss extension set --resource-group MC_myakscluster1_resgroup_eastus2 --vmss-name aks-agentx-18680543-vmss --name VMAccessForLinux --publisher Microsoft.OSTCExtensions --version 1.4 --protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdF94RyNcx7hrLqFrcymWrYhOUivuuGn3frnT1/g7g+ user1@example.com\"}"
```

- Sync key across the set
`az vmss update-instances --instance-ids "*" --resource-group MC_myakscluster1_resgroup_eastus2 --name aks-agentx-18680543-vmss`

- View Connected Devices in subnet to locate the IP address of the specific AKS node, usually the 1st is `.4`, and SSH to it:
`ssh azureuser@10.197.165.4`

- To remove this SSH access, after you are done troubleshooting:
```
az login
az account set -s MYACCOUNT
NodeResGroup=$(az aks show -n CLUSTER-NAME -g CLUSTER-RES-GRP --query nodeResourceGroup -o tsv)
VmssList=$(az vmss list -g $NodeResGroup --query [0].name -otsv)
az vmss extension list -g $NodeResGroup --vmss-name $VmssList -o tsv
az vmss extension delete -g $NodeResGroup --vmss-name $VmssList -n VMAccessForLinux
az vmss update-instances --instance-ids "*" -g $NodeResGroup -n $VmssList
``` 
Try SSH'ing to node to confirm there's no longer access.

## IAM in Azure
At a **very high level**, the Identity and Access Management (IAM) components in Microsoft Azure can be summarized as follows.

**Azure Active Directory** (AAD) which extends an organization's On-Prem Active Directory (AD) using AD Connect and sync services. It is the core component that enables an organization to facilitate the right individuals (1) to access the right resources (2), at the right time (3), and for the right reason (4).

**Azure resources** are core service offerings that allow an organization to perform its cloud functions, and it uses Role Based Access Control (RBAC) with 3 built-in roles.
| Role | Rights |
| --- | --- |
| Reader | Read All |
| Contributor | Read All, Manage All |
| Owner | Read All, Manage All, Manage RBAC |

There are also resource-specific *built-in* roles such as for VMs, SQL, AKS, and other services. But if those built-in roles are too permissive, and organization can also create its own RBAC *custom roles* for more granual access control.

Granting access to resources is done with 3 key items: a security principal, a specific role, at a specific scope. Below table summarizes this triad.
| Element | Function/Example |
| --- | --- |
| Security Principal | User, Groups, Registered Application or Service Principal |
| Role | Reader, Contributor, Owner, CustomRoleX, CustomRoleY |
| Scope| Tenant (root MG), Management Group (MG), Subscription, Resource Group, Specific Resource |

All access is tracked via Activity Logs.

## PowerShell Commands
to run PowerShell from a Linux container: `docker run -it mcr.microsoft.com/azure-powershell pwsh`

Common PS commands:
```
$PSversionTable

Login-AzAccount

$r = Get-AzRoleDefinition "Monitoring Contributor"

Get-AzSubscription
Select-AzSubscription
Set-AzSubscription

Get-AzRoleDefinition | ? {$_.IsCustom -eq $true} | FT Name, IsCustom

# Update existing role
Get-AzRoleDefinition -Name "Existing Role" | ConvertTo-Json | Out-File existing-role.json
Set-AzRoleDefinition -InputFile "existing-role.json"

# Create new custom role, based on existing
Get-AzRoleDefinition -Name "Existing Role" | ConvertTo-Json | Out-File azure-support-basic.json
vi azure-support-basic # And edit accordingly
New-AzRoleDefinition -InputFile ./azure-support-basic.json

# Install YAML module
Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
# Grab from file:
$r = Get-Content -Raw -Path file-path.json | ConvertFrom-Json
# Or query Azure
$r = Get-AzRoleDefinition "Monitoring Contributor"
$j = $r | ConvertTo-Json
$y = $r | ConvertTo-YAML

# Get existing role assignment (to then create one)
$a = Get-AzRoleAssignment [-RoleDefinitionName <String>] -Scope <String> | ConvertTo-Json 

# Create role assignment
$id = (Get-AzAdGroup -DisplayName MYGROUP).Id
New-AzRoleAssignment -RoleDefinition "azure-support-basic" -ObjectId $id

# Remove role
Get-AzureRmRoleDefinition -Name "Virtual Machine Operator" | Remove-AzureRmRoleDefinition

# Remove role assignment
$id = (Get-AzAdGroup -DisplayName MYGROUP).Id
Remove-AzRoleAssignment -ObjectId $id -RoleDefinitionName "azure-support-basic" 
```

## PowerShell Service Principal Login
```
# Use the application ID as the username, and the secret as password
$credentials = Get-Credential
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant <tenant ID>
``` 

## Create Service Principal
To create a service principal using Azure CLI tool, and grant it RBAC role `Contributor` at a specific subscription scope, run the following:  
```
az ad sp create-for-rbac -n sp-cli-mgmt --role="Contributor" --scopes="/subscriptions/<SubscriptionId>"
{
  "appId": "0c96e907-3875-4989-9e94-ed2f163629cf",
  "displayName": "sp-cli-mgmt",
  "password": "EF-a0RixjI2FlrZbYGBbPR.qBqr1G70AEt",
  "tenant": "e6cbf564-8faa-455b-b339-7cee0c829cf2"
}
```
If you omit the `-n <Name>` option, Azure will automatically pick a name like `azure-cli-2022-04-03-23-15-00` for you.

