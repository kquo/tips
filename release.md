# Release

## Purpose

This repo uses a lightweight release helper for committing, tagging, and pushing reviewed changes.

## Canonical Command

Use the release helper with a concrete message based on the actual change set:

```bash
./rel.sh vX.Y.Z "<concrete release message>"
```

## Shell Convenience

If the repo includes `rel.sh`, the same release can be triggered with:

```bash
./rel.sh vX.Y.Z "<concrete release message>"
```

## Notes

- this repo is not a Go module, so the shell wrapper is the preferred entrypoint
- the helper previews `git status --short`, then stages, commits, tags, and pushes after confirmation
- the message should summarize the real changes in the release, not use a generic label
- when presenting release prep to the user, default to showing only the canonical `./rel.sh ...` command unless the full git sequence is explicitly requested
- the only supported option is help: `-h`, `-?`, or `--help`
