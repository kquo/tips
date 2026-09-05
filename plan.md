# Content Plan

## Content Direction

Public static bits site organized as short reference notes, published via GitHub Pages with Jekyll.

## Ideas To Explore

Ideas captured for future discussion. Each entry uses an `IE<N>:` prefix (sequential N) for stable references. An IE is either a pre-rubric idea or a pointer to a drafted AC stub (shape (b)). Remove entries when the underlying idea is closed — rejected, retired, or (for AC pointers) the pointed-to AC has shipped. Promotion path: shape (a) IE → discussion → objective-fit rubric → AC drafted (IE converts to shape (b) pointer, same `IE<N>` number) → AC ships (IE removed). Governance and director-originated ACs originate separately and do not pass through this section.

- IE8: split index.md into two columns
- IE14: propose a pre-prep hook in govna canon so `build.sh prep` runs `check.sh`
- IE16: make `check.sh --register` detect a stale owning entry, one that exists but no longer states the position, since row 10 pointed at `society/politics.md` after the monuments split
- IE17: retitle the site How I See It and decide whether to rename the repository
- IE24: add a product-name allow-list to the `W-NAME` detector, since Azure Management and Microsoft Graph on `tech/azure/ms-token-validation.md` warn on every sweep
- IE25: make `X-LANG` catch a lone short Spanish sentence by scoring per entry as well as per line, and lowercase accented capitals without relying on `tr`, since the four-word line threshold misses a one-sentence quote outside a block quote
- IE26: broaden `X-QA` to lowercase interrogatives, questions inside a paragraph, and bold `Q`/`A` markers without a colon, since the detector matches only capitalized list-item questions and `Q:`-style prefixes
- IE27: retry a rate-limited external fetch with backoff in `check.sh`, since B'Tselem and GitHub answer 429 on most sweeps and each shows as a warning
- IE28: verify the fragment of an external link against the target page's anchors, since the chess entry links three Wikipedia section anchors that the check does not test
- IE29: make the `W-PLAIN` sentence split ignore initials and common abbreviations, since "J. J. C. Smart" counts as four sentences and lowers the mean
