---
type: note
---
## Terraform State

Terraform's state file is a snapshot of what Terraform believes the infrastructure looks like. It is not the infrastructure itself. That gap is where most of the tool's pain lives. The criticisms are well known, and I share most of them.

- **Drift.** Any change made outside Terraform, in a console or by another tool, leaves the state out of date. `terraform plan` catches some of it, never all of it.
- **Single point of failure.** Lose or corrupt the file and Terraform can no longer track the resources it created. Remote backends reduce this risk at the cost of more moving parts.
- **Concurrency.** One writer at a time. Locking backends prevent corruption but become a bottleneck across teams.
- **Secrets.** State can hold passwords, tokens, and keys in plain text. Storing and sharing it is a security problem of its own. This one is being fixed. Terraform's [ephemeral resources and write-only attributes](https://developer.hashicorp.com/terraform/language/manage-sensitive-data/ephemeral) keep secrets out of state, and [OpenTofu encrypts state](https://opentofu.org/docs/language/state/encryption/).
- **Size.** Thousands of resources make `plan`, `apply`, and `destroy` slow.
- **Manual surgery.** `terraform state mv` and `terraform state rm` are easy to get wrong. Editing the JSON by hand is worse.
- **Lock-in.** Weaker than it sounds. State is open JSON with [import and move commands](https://developer.hashicorp.com/terraform/cli/state). The real lock-in is the provider ecosystem and HCL, and Pulumi and the CDKs keep state of their own.
- **Backend overhead.** Remote backends need their own permissions, network access, and configuration.

The remedies are the usual ones. Use a remote backend with locking. Encrypt at rest and keep secrets out of state. Use `ignore_changes` and data sources to shrink what is tracked. Use workspaces per environment, and small modules with separate states. They work, and they all add machinery.

My view is that the state file is a symptom rather than a design flaw. Terraform needs it because the platforms it manages keep no versioned record of their own configuration. A platform that does, as Kubernetes does, moves the state store inside the platform rather than removing it. It keeps the same drift and reconciliation concerns. That is the narrower argument in [The Problem with Infrastructure-as-Code](problem-with-iac.md).
