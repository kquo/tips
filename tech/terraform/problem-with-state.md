---
type: note
---
## Terraform State

Terraform's state file is a snapshot of what Terraform believes the infrastructure looks like, not the infrastructure itself, and that gap is where most of the tool's pain lives. The criticisms are well known, and I share most of them.

- **Drift.** Any change made outside Terraform, in a console or by another tool, leaves the state stale. `terraform plan` detects some of it, never all of it.
- **Single point of failure.** Lose or corrupt the file and Terraform can no longer track the resources it created. Remote backends mitigate this at the cost of more moving parts.
- **Concurrency.** One writer at a time. Locking backends prevent corruption but turn into a bottleneck across teams.
- **Secrets.** State can hold passwords, tokens, and keys in plain text, so storing and sharing it is a security problem of its own.
- **Size.** Thousands of resources make `plan`, `apply`, and `destroy` slow.
- **Manual surgery.** `terraform state mv` and `terraform state rm` are error-prone, and hand-editing the JSON is worse.
- **Lock-in.** When the state file is the source of truth, moving to another tool means migrating state, and Pulumi and the CDKs carry the same burden.
- **Backend overhead.** Remote backends need their own permissions, network access, and configuration.

The remedies are the usual ones: a remote backend with locking, encryption at rest with secrets kept out of state, `ignore_changes` and data sources to shrink what is tracked, workspaces per environment, and small modules with separate states. They work, and they all add machinery.

My view is that the state file is a symptom rather than a design flaw. Terraform needs it because the platforms it manages keep no versioned history of their own configuration. Give every operating system and cloud a built-in, versioned, queryable record of its own state and most of this list disappears, which is the argument in [The Problem with Infrastructure-as-Code](problem-with-iac.md).
