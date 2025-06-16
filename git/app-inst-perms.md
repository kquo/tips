# GitHub App Installation Permissions
This document outlines the three sets of permissions a GitHub App can request upon installation, and lists the available permissions in each category with brief descriptions.

## 1. Repository Permissions
Permissions that apply to repositories the app is installed on.

1. **actions** - Access workflows and workflow runs.
2. **administration** - Manage repository settings, webhooks, collaborators.
3. **checks** - Access checks created by the app.
4. **codespaces** - Manage Codespaces within the repository.
5. **codespaces_lifecycle_admin** - Full lifecycle management of Codespaces.
6. **codespaces_metadata** - Read-only access to Codespaces info.
7. **code_scanning_alerts** - Access code scanning results.
8. **contents** - Read/write access to repository files and commits.
9. **dependabot_secrets** - Manage Dependabot secrets.
10. **deployments** - Access deployment environments and statuses.
11. **environments** - Read/write access to environments and secrets.
12. **issues** - Read/write access to issues and issue comments.
13. **metadata** - Read-only access to repo metadata (always granted).
14. **packages** - Manage GitHub Packages.
15. **pages** - Manage GitHub Pages settings and builds.
16. **pull_requests** - Read/write access to PRs and PR reviews.
17. **repository_hooks** - Manage repo webhooks.
18. **repository_projects** - Manage repository projects (classic projects).
19. **secret_scanning_alerts** - Access secret scanning alerts.
20. **secrets** - Manage repository-level secrets.
21. **security_events** - Read access to security events (like Dependabot alerts).
22. **single_file** - Read/write access to a single file in the repo.
23. **statuses** - Create and read commit statuses.
24. **vulnerability_alerts** - Read access to dependency alerts.

## 2. Organization Permissions
Permissions that apply across an organization when the app is installed on it.

1. **administration** - Manage org settings and webhooks.
2. **blocks** - View users blocked from the organization.
3. **code_scanning_alerts** - Access org-level code scanning data.
4. **codespaces** - Manage Codespaces across org.
5. **dependabot_secrets** - Manage org-level Dependabot secrets.
6. **events** - Read org audit logs.
7. **hooks** - Manage org webhooks.
8. **members** - Read/manage organization members.
9. **organization_packages** - Manage GitHub Packages at org level.
10. **organization_personal_access_tokens** - View personal access token requests.
11. **organization_plan** - Read billing and plan details.
12. **organization_projects** - Manage org-level projects.
13. **organization_secrets** - Manage org secrets.
14. **organization_self_hosted_runners** - Manage org’s self-hosted GitHub Actions runners.
15. **organization_user_blocking** - Manage org-level user blocks.
16. **pages** - Manage GitHub Pages for the org.
17. **personal_access_token_requests** - Manage fine-grained token requests.
18. **profile** - Read organization profile info.
19. **secret_scanning_alerts** - Access org-wide secret scanning alerts.
20. **self_hosted_runners** - Manage org’s self-hosted runners.
21. **team_discussions** - Read/write access to team discussions.
22. **teams** - Read org teams and team members.
23. **users** - View users that can interact with the org.

## 3. Account (User-to-Server) Permissions
Permissions used when an app acts on behalf of a user (via OAuth).

1. **emails** - Read user email addresses.
2. **profile** - Read user profile information.
3. **read:org** - Read org membership.
4. **read:user** - Read user profile and data.
5. **user** - Full read/write user data access.
6. **repo** - Full control of private and public repositories.
7. **public_repo** - Access public repositories only.
8. **gist** - Create and manage gists.
9. **notifications** - Read user notifications.
10. **write:discussion** - Start or comment on discussions.
11. **workflow** - Manage GitHub Actions workflows.
