## Github Workflow OIDC Access to Vault

OIDC allows workflows to authenticate and interact with HashiCorp Vault using short-lived tokens. This eliminates the need for long-lived tokens or static credentials, providing a more secure and manageable approach to accessing secrets directly from GitHub Actions.

### How It Works

1. **Configuration**: You configure your Vault server to trust GitHub as an external identity provider by setting up a role for JWT-based authentication. This involves specifying details such as the issuer URL and configuring the Vault role with appropriate policies.

2. **Authentication Flow**: GitHub Actions workflows use the GitHub-provided JWT token to authenticate with Vault. Vault validates the token against the GitHub OIDC issuer and verifies claims like repository, branch, or environment. Upon successful validation, Vault issues a Vault token with permissions specified in the configured policies.

### Setting Up

1. Enable OIDC in Vault
   - Enable the JWT authentication method in Vault:
     ```bash
     vault auth enable jwt
     ```

   - Configure a role in Vault to trust GitHub’s OIDC token:
     ```bash
     vault write auth/jwt/role/github-actions          bound_issuer=https://token.actions.githubusercontent.com          user_claim=repository          bound_claims_format=glob          bound_claims={"repository":"<your_org_or_repo>/*"}          token_policies=github-actions-policy          ttl=1h
     ```

   - Define a policy in Vault to grant access to the required secrets:
     ```hcl
     path "some/path/github/sub/folder/*" {
       capabilities = ["read"]
     }
     ```

2. Set Up Secrets in GitHub
   - Add any necessary Vault-related secrets in your GitHub repository:
     - `VAULT_ADDR`: The URL of your Vault server.
     - `VAULT_ROLE`: The name of the Vault role (e.g., `github-actions`).
     - `VAULT_NAMESPACE` (if applicable): Your Vault namespace.
   - These secrets will be referenced in the workflow.

3. Create a Workflow to Authenticate with Vault Using OIDC
Below is an example GitHub Actions workflow to authenticate to Vault using OIDC and retrieve a secret:

```yaml
name: Retrieve Secret from Vault with OIDC

on:
  workflow_dispatch:

jobs:
  oidc-to-vault:
    runs-on: ubuntu-latest

    permissions:
      id-token: write  # Required for requesting the JWT
      contents: read   # Default read permissions

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Authenticate with Vault and Retrieve Secret
        id: vault
        uses: hashicorp/vault-action@3.1.0
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: oidc
          role: ${{ secrets.VAULT_ROLE }}
          secrets: |
            github_token=some/path/github/sub/folder/read-access-file:github_token

      - name: Use the Retrieved Secret
        run: |
          echo "GitHub Token: $GITHUB_TOKEN"
        env:
          GITHUB_TOKEN: ${{ steps.vault.outputs.github_token }}
```

## Benefits of Using OIDC

1. **No Long-Lived Tokens**:
   - OIDC uses short-lived JWTs for secure, ephemeral authentication.

2. **Granular Access**:
   - You can scope the Vault role to specific repositories, branches, or workflows using `bound_claims`.

3. **Seamless GitHub Integration**:
   - Works directly with GitHub’s identity provider, simplifying the setup.

### References
- [What is GitHub Action for Vault](https://developer.hashicorp.com/vault/docs/auth/jwt)
- [Configuring OIDC in GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-github-actions)
- [Vault Action on GitHub Marketplace](https://github.com/marketplace/actions/hashicorp-vault-action)
