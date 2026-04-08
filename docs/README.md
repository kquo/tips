# Docs Overview

This directory holds maintainer-facing documentation for working on `tips`.

`tips` is a public GitHub Pages site, but the root `README.md` doubles as the site homepage and intentionally stays minimal. Operational and editorial guidance belongs here instead.

## Core Maintenance Files

- `AGENTS.md`: shared governance contract for agent behavior in this repo
- `style.md`: editorial standards, category routing, and linking rules
- `content-plan.md`: current backlog and publishing priorities
- `publishing-workflow.md`: intake, review, and publication flow
- `release.md`: routine publishing and optional tagged snapshot guidance
- `CHANGELOG.md`: human-readable history of tagged snapshots

## Agent Roles

- `docs/agent-roles/maintainer.md`: default single-agent mode for drafting, review, and repo maintenance
- `docs/agent-roles/dev.md`: drafting and editing mode
- `docs/agent-roles/qa.md`: review mode focused on category fit, clarity, and factual support

Use `Maintainer` unless you explicitly want drafting and review separated.

## Workflow Summary

1. Choose the next draft or revision from `content-plan.md` or the current working tree.
2. Assign exactly one landing area: `Life`, `Mind`, `Society`, or `Tech`.
3. Edit the target page to match `style.md`.
4. Update the relevant area index and nearby links.
5. Review category fit, clarity, support, grammar, and link correctness.
6. Publish by committing and pushing to `main`.
7. Create a tag only when you want a named snapshot.

## Notes

- Root `README.md` is public site content, not the operator handbook.
- Prefer a small number of natural Wikipedia links when they improve trust and readability.
- Keep governance and workflow docs current when the editorial process changes.
