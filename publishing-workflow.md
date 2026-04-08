# Publishing Workflow

## Purpose

This file defines how `tips` content moves from draft to published output.

## Platform

- GitHub Pages with Jekyll

## Workflow

1. choose the next draft or revision from `content-plan.md` or the current working tree
2. assign exactly one landing area: `Life`, `Mind`, `Society`, or `Tech`
3. choose the target file path and update the entry to match `style.md`
4. update the relevant area index and any nearby cross-links
5. review for category fit, clarity, factual support, grammar, and link correctness
6. publish by committing and pushing the reviewed changes to `main`
7. optionally create a tag only when an explicit snapshot or release marker is wanted

## Publishing Rules

- every new tip must land in exactly one top-level area
- ambiguous entries require an explicit classification rationale before they are considered ready
- changes to page paths or titles usually require an update to the relevant `*/index.md`
- do not publish a page that is linked from an index but still obviously incomplete
- preserve existing paths when practical; if a path changes, update incoming links in the same change
- keep content changes and planning updates aligned
- update this workflow when the platform or editorial process materially changes

## Editorial Variants

This repo currently uses:

- `style.md` as the primary editorial standard
- `content-plan.md` as the primary planning artifact

## Platform-Specific Notes

- `_config.yml` and `CNAME` are part of the publishing surface. Change them only intentionally.
- The public site is published from the repo's configured GitHub Pages source after a push to `main`.
- A normal publish is a reviewed commit pushed to `origin/main`.
- Tagged releases are optional snapshots, not a requirement for every content update.
