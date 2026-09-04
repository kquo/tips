# Content Plan

## Content Direction

Public static bits site organized as short reference notes, published via GitHub Pages with Jekyll.

## Ideas To Explore

Ideas captured for future discussion. Each entry uses an `IE<N>:` prefix (sequential N) for stable references. An IE is either a pre-rubric idea or a pointer to a drafted AC stub (shape (b)). Remove entries when the underlying idea is closed — rejected, retired, or (for AC pointers) the pointed-to AC has shipped. Promotion path: shape (a) IE → discussion → objective-fit rubric → AC drafted (IE converts to shape (b) pointer, same `IE<N>` number) → AC ships (IE removed). Governance and director-originated ACs originate separately and do not pass through this section.

- IE1: polish `mind/famous-quotes.md`
- IE8: split index.md into two columns
- IE9: move `tech/scripts/` to the `queone/scripts` repository and rewrite every reference
- IE11: apply the publishing filter to Mind, including its links and exact-year replacement
- IE12: apply the publishing filter to Tech, including its links
- IE13: apply the publishing filter to Life, including its links
- IE14: propose a pre-prep hook in govna canon so `build.sh prep` runs `check.sh`
- IE16: make `check.sh --register` detect a stale owning entry, one that exists but no longer states the position, since row 10 pointed at `society/politics.md` after the monuments split
- IE17: retitle the site How I See It and decide whether to rename the repository
- IE18: simpler-English companion pages as pre-generated static variants with a staleness check tied to the source entry
- IE19: in the Mind pass, verify and link the nearest studied concepts to cold logic: Arendt's tyranny of logicality, Smart's rule worship, Weber's value versus instrumental rationality
- IE20: add an English-only rule to the publishing filter and a Spanish-prose detector to `check.sh`, since the AC32 inventory missed `mind/optimism.md`
