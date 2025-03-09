## Github Workflow OIDC Access to Azure

**[ NEEDS REWRITE ]**

OIDC allows workflows to authenticate and interact with Azure using short-lived tokens. This eliminates the need for long-lived personal access tokens (PAT) or service principal with a secrets, providing a more secure and manageable approach to accessing cloud resources directly from GitHub Actions.

### How It Works
1. **Configuration**: You configure your Azure AD App Registration to trust an external identity provider by setting up a federation with that IdP. This involves specifying details about the IdP, such as the issuer URL, and possibly uploading metadata documents for SAML-based federations.

2. **Authentication Flow**: A user or service attempts to access an application protected by Azure AD and is redirected to sign in. Instead of presenting Azure AD credentials, the user or service presents credentials from the federated IdP. The federated IdP authenticates the user or service and issues a token. This token is presented to Azure AD, which validates it based on the trust configuration. Upon successful validation, Azure AD issues its own token to the user or service, granting access to the application.

### Setting Up
1. Enable OIDC in Azure
    - You still need an App Registration and Service Principal
    - Assign it the required Azure RBAC and Entra roles, at the required scope, to be able to do what you want it to do
    - But instead of configuring a **secret**, you configure a "federated" credential
    - [Configure a federated identity credential on an app](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp#github-actions)
    - click "Certificates & secrets" -> "Federated credentials", and "Add credential" and select "Github Actions deploying Azure resources"
    - Enter the Github Organization
    - The Github Repository name
    - The Entity type = "Branch"
    - And Based on selection = "main", or whatever that may be

2. Set below variables as secrets in your GitHub repository:
    - AZURE_AD_APPLICATION_CLIENT_ID: The client ID of the Azure AD application
    - AZURE_TENANT_ID: Your Azure tenant ID
    - AZURE_SUBSCRIPTION_ID: Your Azure subscription ID (may not be needed)

3. Setup a workflow that authenticates to Azure using OIDC, does something useful
    - Can be used with [Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
    - Requires azurerm provider version 3.7.0 or higher
    - Azure CLI is set up with the token automatically, of course
    - Terraform picks up the token automatically also
    - Anything running within the Github Action job can use Azure CLI to get respective API tokens, as shown below
    - Example OIDC Github Action job using Azure CLI:

    ```yaml 
      permissions:
        id-token: write  # This is required for requesting the JWT
        contents: read   # This is required for actions/checkout

      jobs:
        task_leveraging_oidc_login:
          runs-on: ubuntu-latest
          steps:

            - name: checkout_github_action_code
              uses: actions/checkout@v4
              with:
                ref: main

            # Option 1: Using azure-cli
            - name: azure_oidc_login
              uses: azure/login@v1
              with:
                client-id: ${{secrets.CLIENT_ID}}
                tenant-id: ${{secrets.TENANT_ID}}
                allow-no-subscriptions: true  

            - name: capture_azure_tokens
              run: |
                # https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-get-access-token
                # [--resource-type {aad-graph, arm, batch, data-lake, media, ms-graph, oss-rdbms}]
                export MG_TOKEN="$(az account get-access-token --resource-type ms-graph --query accessToken -o tsv)"
                export AZ_TOKEN="$(az account get-access-token --resource-type arm --query accessToken -o tsv)"
                echo "MG_TOKEN=$MG_TOKEN" >> $GITHUB_ENV  # To use in another step 
                echo "AZ_TOKEN=$AZ_TOKEN" >> $GITHUB_ENV
                curl -sH "Content-Type: application/json" -H "Authorization: Bearer ${AZ_TOKEN}" -X GET "https://management.azure.com/subscriptions?api-version=2022-12-01" | jq

            # Option 2: Using custom Python script (RECOMMENDED)
            # See https://github.com/git719/tips/blob/main/scripts/get_oidc_tokens.py

            - name: some_other_step
              run: |
                curl -sH "Content-Type: application/json" -H "Authorization: Bearer ${{env.MG_TOKEN}}" -X GET "https://graph.microsoft.com/v1.0/users" | jq
    ```

## Overview

A Github workflow action can be setup to You can - Using Azure as a sample cloud provider
- At high level
  - Create a role on AWS, add trust policy specifying which github Organization + Repo are allowed to access this AWS role
  - Create an identity provider for github actions
  - Use the setup-aws action, specify the role and it will take care of the rest
- At lowel level:
  - Github spins up an Action with your pipeline code
  - Every action job comes with a token as an environment variable for authenticated calls to github
  - You send a post request to github, asking for a “web identity token“
  - You send this token to AWS, exchanging it for (you guest it) a pair of keys and session token
  - You use this set of keys to authenticate with AWS services as normal
- Notes:
  - The key point is that the JWT token is signed by github and its content can be verified by AWS using github’s public key
  - The token also contains scopes such as organization, repo, branch, that AWS can either grant or deny access to

### OIDC Flow Diagram

```bash
GitHub             GitHub Workflow Action             Microsoft
│                           │                             │
│   1. Give me JWT token    │                             │
│ ◄──────────────────────── │                             │
│                           │                             │
│   2. Returns JWT token    │                             │
│ ────────────────────────► │                             │
│                           │                             │
│                           │                             │
│                           │  3. Give me Azure ARM       │
│                           │     and MS Graph tokens     │
│                           │ ──────────────────────────► │
│                           │                             │
│                           │  4. Returns each token      │
│                           │ ◄────────────────────────── │
                            │                             
                            │                             
MS Graph                    │                         Azure ARM
│                           │                             │
│   5. Update MS Graph X    │                             │
│      object using token   │                             │
│ ◄──────────────────────── │                             │
│                           │                             │
│   6. Update done          │                             │
│ ────────────────────────► │                             │
│                           │                             │
│                           │  7. Update Azure ARM X      │
│                           │     object using token      │
│                           │ ──────────────────────────► │
│                           │                             │
│                           │  8. Update done             │
│                           │ ◄────────────────────────── │
```

### References
- [Example Python Get OIDC Token Script](https://github.com/git719/tips/blob/main/scripts/get_oidc_tokens.py)
- [What is Github Action for Azure](https://learn.microsoft.com/en-us/azure/developer/github/github-actions) 
- [Configuring OpenID Connect in Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure login action](https://github.com/marketplace/actions/azure-login)
- [Configuring OpenID Connect in cloud providers](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers)
- [OpenID Connect on the Microsoft identity platform](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc)
- [Create ASCII Diagrams](https://asciiflow.com/#/)
