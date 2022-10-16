# Terraform
What is [Terraform](https://www.terraform.io/)?

Hashicorp Terraform is an open-source IaC (Infrastructure-as-Code) tool for provisioning and managing cloud infrastructure. It codifies infrastructure in configuration files that describe the desired state for your topology. Terraform enables the management of any infrastructure - such as public clouds, private clouds, and SaaS services - by using [Terraform providers](https://www.terraform.io/language/providers). Each provider adds a set of resource types and/or data sources that Terraform can manage.

## Azure
Tips on managing your Azure tenant with Terraform.

- These instructions assume you're managing your Azure tenant from an Apple Mac host, using BASH as a shell terminal
- Of course you can do the same on a Windows host running GitBASH, or a Linux host using regular BASH, making the necessary adjustments
- Install 1) Terraform and 2) Azure CLI tools on macOS:
`brew install terraform azure-cli`
- Create a new, private source code repository in your SCM system
- Call it "myaztf"
- It will hold `main.tf` and all other Infrastructure-as-Code Terraform `*.tf` configuration files
- Use <https://github.com/github/gitignore/blob/main/Terraform.gitignore> to avoid checking in the wrong files
- Create a new Service Principal (SP) in your Azure tenant
- Call it `sp-myaztf` 
- Grant this SP all required permissions to allow TF to deploy and managed required services
- Capture and set below 4 parameters accordingly:
```
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```
    - WARNING! Exposing an SP secret as a BASH variable is poor security, and should only be done for testing.
    - For a production system you'll need to do this in a more secure fashion, which is beyond this tutorial
    - Typically that is done using a secrets manager such as HashiCorp Vault, Azure Key Vault, CyberArk
- Create an Azure Storage Account (SA) to have Terraform store its "state" there
```
    az group create --name mytfstates --location eastus2
    az storage account create --resource-group mytfstates --name mytf --sku Standard_LRS --encryption-services blob
```
- NOTE: Another way to store TF state is to use Terraform Cloud (https://cloud.hashicorp.com/products/terraform),
    which is a paid service 
- Create a container with this SA and set up its access key password
```
    az storage container create --name mytfstate --account-name mytf
    az storage account keys list --resource-group mytfstates --account-name mytf --query '[0].value' -o tsv
    export ARM_ACCESS_KEY="use_above_storage_account_container_access_key"
```
    - WARNING! Again, exposing secrets via BASH variables is poor security, and should only be done for testing.
    - For production systems make sure you do this more securely
- Checkout/clone myaztf repo mentioned above and create `main.tf` with these recommended initial values: 

```
# main.tf

terraform {
  required_version = ">= 1.3.2"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  backend "azurerm" {
    # To create below 3 parameters do:
    #   az group create --name mytfstates --location eastus2
    #   az storage account create --resource-group mytfstates --name mytf --sku Standard_LRS --encryption-services blob
    #   az storage container create --name mytfstate --account-name mytf
    resource_group_name  = "mytfstates"
    storage_account_name = "mytf"
    container_name       = "mytfstate"
    key                  = "terraform.tfstate"
  }
  
  # Optional: To instead use Terraform Cloud (https://cloud.hashicorp.com/products/terraform) to store state 
  # cloud {
  #   organization = "MyOrg"   # Or whatever name you setup via your TF Cloud setup
  #   workspaces {
  #     name = "OrgAzure"        # Or whatever name you setup
  #   }
  # }

}

provider "azurerm" {
  # If you leave this out, you might need to grant provider registration permissions to the service principal created earlier
  # Setting it to true will skip that step, but you will only be able to create resources with providers already registered
  # in your Azure subscription. Find out more about resource providers here: 
  # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types
  skip_provider_registration = true
  features {
  }
}
```

- Create a test Resource Group as an example of how to use TF to create Azure resources
- Create file `rg-myaz01.tf`: 
```
    resource "azurerm_resource_group" "rg" {
        name     = "rg-myaz01"
        location = "eastus2"
    }
```
- Run `terraform plan` to see what TF will do
- Run `terraform apply` to do it (that is, create above resource group)
    - Note that TF scans all `*.tf` files in this working repo when you do scan/apply
    - Note that TF may not be able to create the intended resources if its `sp-myaztf` SP doesn't grant the necessary rights
    - Grant those rights carefully and at the proper scope within your tenant
- Use `terraform import` to import existing resources into the TF state
- Note that the import goes to the state, NOT to a configuration file
- In `fact, to import an existing resource, you MUST create a minimalist configuration file for that resource
- After import, then run "terraform state list" to locate the imported resource names
- Then do `terraform state show <imported-resource-type.name>` to show full details
- You can then recreate the minimalist config file, based on above fuller details, removing IDs, etc
- Example:
    - Edit `my-rbac-role.tf`:
    ```
    # my-rbac-role.tf:
    # Minimalist file for existing "my-rbac-role" to be imported
    data "azurerm_management_group" "primary" {
        name = "<UUID>"
    }
    resource "azurerm_role_definition" "my-rbac-role" {
        name  = "my-rbac-role"
        scope = data.azurerm_management_group.primary.id
    }
    ```  
    - Then do:
    `terraform import azurerm_role_definition.my-rbac-role-def "/providers/Microsoft.Authorization/roleDefinitions/<UUID>|/providers/Microsoft.Management/managementGroups/<UUID>"`
    - Similarly, for an existing role assignment you'd do:
    `terraform import azurerm_role_assignment.my-rbac-role-assign "/providers/Microsoft.Management/managementGroups/<UUID>/providers/Microsoft.Authorization/roleAssignments/<UUID>"`

- References:
- This article is a helpful intro into this <https://blog.devgenius.io/beginners-guide-to-using-terraform-for-azure-90861bc8b9cf>
- To create more resources see the more detailed tutorial at <https://learn.hashicorp.com/collections/terraform/azure-get-started>
