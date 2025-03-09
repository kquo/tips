## Github Workflow OIDC Access to Vault

**[ NEEDS REWRITE ]**

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


---

# How to Use GitHub OIDC to Fetch a GitHub Token from Vault

## 1. Enable OIDC Authentication in Vault
Vault supports OIDC authentication, allowing GitHub Actions to authenticate dynamically.

### 1.1: Enable OIDC in Vault

```bash
vault auth enable jwt
```

### 1.2: Configure Vault to Trust GitHub’s OIDC Provider
Replace `YOUR_GITHUB_ORG` and `YOUR_REPO_NAME` with your actual values.

```bash
vault write auth/jwt/config \
  oidc_discovery_url="https://token.actions.githubusercontent.com" \
  bound_issuer="https://token.actions.githubusercontent.com"
```

### 1.3: Create a Vault Role for GitHub Actions

```bash
vault write auth/jwt/role/github-actions \
  bound_audiences="sts.amazonaws.com" \
  bound_claims="repository=YOUR_GITHUB_ORG/YOUR_REPO_NAME" \
  policies="github-read-access" \
  user_claim="repository" \
  ttl="1h"
```

### 1.4: Create a Vault Policy for Reading the GitHub Token
Create a policy file (`github-read.hcl`):

```hcl
path "secret/data/github" {
  capabilities = ["read"]
}
```

Apply the policy:

```bash
vault policy write github-read-access github-read.hcl
```

---

## 2. Configure GitHub Actions Workflow to Use OIDC
GitHub Actions can now authenticate with Vault using OIDC.

### 2.1: Modify GitHub Workflow to Authenticate via OIDC
Update your **GitHub Actions workflow (**``**)**:

```yaml
jobs:
  checkout-all-repos:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for OIDC authentication
      contents: read
    steps:
      - name: Authenticate with Vault via OIDC
        id: vault-auth
        run: |
          export VAULT_ADDR="https://your-vault-server.com"
          
          VAULT_TOKEN=$(curl --request POST --data \
          '{"role": "github-actions", "jwt": "'"$(cat /token/github_oidc_token)"'"}' \
          $VAULT_ADDR/v1/auth/jwt/login | jq -r '.auth.client_token')

          echo "::add-mask::$VAULT_TOKEN"
          echo "VAULT_TOKEN=$VAULT_TOKEN" >> $GITHUB_ENV

      - name: Fetch GitHub Token from Vault
        run: |
          GH_TOKEN=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
          $VAULT_ADDR/v1/secret/data/github | jq -r '.data.data.org_read_token')

          echo "::add-mask::$GH_TOKEN"
          echo "GH_TOKEN=$GH_TOKEN" >> $GITHUB_ENV

      - name: List all repositories
        run: |
          curl -H "Authorization: token $GH_TOKEN" \
               -H "Accept: application/vnd.github.v3+json" \
               https://api.github.com/orgs/YOUR_GITHUB_ORG/repos
```

## Why Use OIDC Instead of a Static Token?
- **No Static Secrets** – OIDC removes the need to store GitHub tokens in GitHub Secrets.
- **Better Security** – Vault dynamically issues a token **only when the GitHub Action runs**.
- **Automatic Rotation** – Tokens expire after use, reducing risk.
- **Granular Access Control** – You can restrict access to specific repositories.

---

# Connecting to HashiCorp Vault from GitHub Actions Using OIDC
To connect to HashiCorp Vault from GitHub Actions using **OIDC (OpenID Connect)**, you can leverage the `hashicorp/vault-action` to simplify the process. OIDC allows your workflow to authenticate to Vault without managing long-lived credentials, making it secure and ideal for CI/CD pipelines.


### Prerequisites
1. **Vault Configuration for OIDC Authentication**:
   - Ensure your Vault instance is configured to use OIDC with GitHub as the trusted identity provider (IDP).

   Example Vault policy and role configuration:
   ```hcl
   # Create an OIDC role for GitHub Actions
   vault write auth/jwt/role/github-actions \
       bound_issuer=https://token.actions.githubusercontent.com \
       user_claim=repository \
       bound_claims_format=glob \
       bound_claims={"repository":"<your_org_or_repo>/*"} \
       token_policies=github-actions-policy \
       ttl=1h

   # Define the policy to grant access
   vault policy write github-actions-policy - <<EOF
   path "some/path/github/sub/folder/*" {
     capabilities = ["read"]
   }
   EOF
   ```

2. **Vault OIDC URL**:
   - Use the OIDC discovery URL from GitHub: `https://token.actions.githubusercontent.com`.

3. **Enable the JWT Auth Method in Vault**:
   - Enable the `jwt` auth method in Vault:
     ```bash
     vault auth enable jwt
     ```


### GitHub Actions Workflow with OIDC*
Below is an example GitHub Actions workflow to authenticate to Vault using OIDC:

```yaml
name: Retrieve Secret from Vault with OIDC

on:
  workflow_dispatch:

jobs:
  oidc-to-vault:
    runs-on: ubuntu-latest

    permissions:
      id-token: write  # Required for OIDC
      contents: read   # Default read permissions

    steps:
      # Step 1: Set up Vault OIDC Authentication and Retrieve Secret
      - name: Authenticate with Vault and Retrieve Secret
        id: vault
        uses: hashicorp/vault-action@3.1.0
        with:
          url: https://vault.example.com
          method: oidc
          role: github-actions
          secrets: |
            github_token=some/path/github/sub/folder/read-access-file:github_token

      # Step 2: Use the Retrieved Secret
      - name: Use the secret
        run: |
          echo "GitHub Token: $GITHUB_TOKEN"
        env:
          GITHUB_TOKEN: ${{ steps.vault.outputs.github_token }}
```

### Key Details
1. **OIDC Token Permissions**:
   - In the `permissions` block, set:
     ```yaml
     permissions:
       id-token: write
     ```
     This allows GitHub Actions to request an OIDC token to authenticate with Vault.

2. **`hashicorp/vault-action` Configuration**:
   - The `method: oidc` input specifies OIDC authentication.
   - `role: github-actions` maps to the Vault role created earlier (`auth/jwt/role/github-actions`).
   - Secrets mapping works the same way as in other Vault authentication methods.

3. **OIDC Authentication**:
   - The action fetches an OIDC token from GitHub's identity provider (`https://token.actions.githubusercontent.com`) and uses it to authenticate with Vault.

### Vault Setup Recap
To recap, ensure the following is configured in Vault:
1. Enable the JWT/OIDC auth method:
   ```bash
   vault auth enable jwt
   ```

2. Write the GitHub OIDC role:
   ```bash
   vault write auth/jwt/role/github-actions \
       bound_issuer=https://token.actions.githubusercontent.com \
       user_claim=repository \
       bound_claims_format=glob \
       bound_claims={"repository":"<your_org_or_repo>/*"} \
       token_policies=github-actions-policy \
       ttl=1h
   ```

3. Define the necessary Vault policy:
   ```hcl
   path "some/path/github/sub/folder/*" {
     capabilities = ["read"]
   }
   ```

### Benefits of Using OIDC
1. **No Long-Lived Tokens**:
   - OIDC uses short-lived JWTs for secure, ephemeral authentication.

2. **Granular Access**:
   - You can scope the Vault role to specific repositories, branches, or workflows using `bound_claims`.

3. **Seamless GitHub Integration**:
   - Works directly with GitHub’s identity provider, simplifying the setup.


