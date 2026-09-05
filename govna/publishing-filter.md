# Publishing Filter

Use this document as the owning rulebook for every entry published on the site. `AGENTS.md` `## Project Rules` carries the gates. This file carries the rules, their rationale, and the detectors behind `check.sh`. Positions the site holds live in `stance-register.md`.

## Purpose

- Apply this filter to every entry created or edited under `life/`, `mind/`, `society/`, or `tech/`, and to the root site pages `about.md` and `index.md`.
- Pass every rule below before an entry counts as implementation-complete.
- Treat the site as how the author sees the world: a short first-person take supported by external references, or a practical how-to, never a full treatment.
- Prefer removing text over explaining it when an entry exceeds its budget.

Note: the site is public and attributable through its GitHub repository. Anonymity is not the defense. Accuracy, fairness, and brevity are.

## Entry Types And Budgets

- Declare exactly one `type` in front matter on every entry: `take`, `note`, `howto`, `reference`, or `quote`.
- Keep a `take` to 250 prose words.
- Keep a `note` to 400 prose words.
- Keep a `howto` to 500 prose words.
- Keep a `quote` to 300 words including the quoted text.
- Keep a `reference` skimmable, with no prose cap.
- Count prose words after removing front matter, fenced code blocks, and HTML comments.
- Split an entry that cannot meet its budget into two entries with one topic each.
- Treat a missing `type` as `note` during the site-wide sweep only.

Note: a `take` is opinion on a subject, a `note` is an explainer, a `howto` is steps to a result, a `reference` is a cheat-sheet or list, a `quote` is a collection of other people's words. Anything longer than these budgets reads like an encyclopedia entry, and Wikipedia already does that better.

## Privacy

- Publish no real name of the author or of a private individual.
- Publish no handle derived from a real name.
- Publish no credential, token, key, or password, even one that is expired or was never real.
- Publish no device identifier: serial number, hardware UUID, MAC address, or USB device ID.
- Publish no employer name, employer domain, internal hostname, job name, or internal URL.
- Publish no private network detail beyond generic RFC1918 examples.
- Publish no personal health, family, or location detail.
- Replace each removed value with a placeholder in the site's `<NAME>` or `mydomain.com` style, inside a code span or fence.
- Keep an exact year that narrows the author's age out of first-person sentences; use a decade instead.
- Keep the private denylist outside the repository at `~/.config/bits/denylist.txt` or at the path in `BITS_DENYLIST`.
- Keep one literal per denylist line.
- Add every newly found personal literal to the denylist before the entry ships.
- Treat the site's own `kquo` and `queone` handles as allowed.
- Treat attribution through the GitHub repository as accepted, not as a leak.

Note: the two blood-pressure pages stay. A generic health how-to is not personal health detail. This section is class-based on purpose. Naming an instance here would publish it. Blank lines and lines starting with `#` in the denylist are ignored.

## Voice

- Write a reflective entry as one continuous first-person argument under its page title.
- Write each reflective entry as how the author sees the subject, not as a report on it.
- Write every `take` and `note` in plain English: short sentences and common words.
- Keep a `take` or `note` near 16 words per sentence or fewer.
- Open with one grounding sentence in that same voice.
- Carry the general reference, usually Wikipedia, as an inline link where the concept first appears.
- Use external links to support the argument, never as a detached summary of what others say.
- Use no heading that labels a passage as opinion, such as `My take`, `Opinion`, `Thoughts`, or `Verdict`.
- Use a `###` heading only to separate distinct sub-topics, steps, or reference sections.
- Prefer no internal heading in a `take`.
- Condense AI-drafted text into that shape before publishing any of it.
- Use no section headed Conclusion, Final Thoughts, Bottom Line, Key Insight, Summary, Question, or Answer.
- Publish no question-and-answer transcript.
- Write every entry in English.
- Quote a non-English source in the original only inside a block quote, followed by an English rendering.
- Publish no placeholder such as NEEDS REWRITE, need link, Need sources, Needs clean up, TODO, FIXME, or TBD.
- Write a how-to as the shortest sequence of steps that reaches the result.

Note: the banned headings are the fingerprint of an unedited machine draft. The text under them is usually the only part worth keeping. The question-form and Spanish-prose detectors in `check.sh` back the transcript and English rules.

## Fairness And Corrections

- Criticize positions and actions, never mental states.
- Use no psychiatric or medical characterization of a named person.
- State the strongest version of a view before disagreeing with it.
- Apply no blanket moral label to a group.
- Name a living person only for what that person said or did in public.
- Source every factual claim about a named person.
- State each such claim no more strongly than its source supports.
- Fix or cite a disputed claim in the next release.
- Keep the corrections channel on `about.md` pointing at the repository's Issues page.

Note: the entries on the Principle of Charity, Hanlon's Razor, and Bulverism already state this standard. This section makes the site hold itself to it. A sourced fact plus a judgment plainly in the author's own voice is the defensible stance. A diagnosis of a stranger is not.

## Consistency And The Stance Register

- Record every settled position in `stance-register.md` as one line with its owning entry.
- Check every stance-bearing claim in a changed entry against the register before Implement completion.
- Match, extend, or explicitly supersede the registered line; never contradict it silently.
- Return to Refine when a changed entry contradicts a registered line.
- Record a new or changed position in the register in the same pass as the entry.
- Mark a position `unresolved` when two entries disagree.
- Settle each `unresolved` line with the Director before either entry ships again.
- Run `./check.sh --register` after every register edit.

Note: the register is what turns "no contradictions" from a one-time review into an ongoing check.

## Linking And Repetition

- Give each concept one owning entry.
- Link to the owning entry instead of restating the concept.
- Use a repo-relative path for every internal link.
- Use no absolute `que.one` URL inside the site.
- Add an inbound link from at least one related entry when a new entry ships.
- Keep each area index listing every entry in its directory.

Note: the 2026-09-03 review found attention-economy mechanics explained in six entries and the reflexivity limitation in five. Each should be one page and five links.

## Accuracy And Sourcing

- Source every contested factual claim.
- Write every fact-claiming entry as defensibly as its sources allow.
- State every factual claim no more strongly than its source supports.
- Prefer Wikipedia or a primary source over commentary.
- Attribute every quotation to a person and a source.
- Mark a quotation `attributed` when its source cannot be verified.
- Remove a quotation that is documented as misattributed.
- State a consensus claim such as "most would say" only with a source.
- Date a time-sensitive claim in text instead of using words like recently or nowadays.

## Link Stability

- Store the final URL, never a redirecting alias.
- Link a release page or listing, never a version-specific download asset.
- Link no private repository page.
- Reference only the `queone` GitHub organization.
- Resolve every relative link and anchor before an entry ships.
- Fetch every external URL before an entry ships.
- Rewrite a link whose target now redirects to a different path.
- Verify a host on the bot-block allowlist in a browser.
- Run the site-wide link sweep at every Package.

Note: the allowlist covers hosts that reject scripted requests: Stack Overflow and Stack Exchange, Medium, congress.gov, SAGE, Politico, and devgenius. Liveness decays between releases, which is why the sweep repeats.

## Code Hosting

- Host no executable code on the site.
- Keep every script in the `queone/scripts` repository and link to it.
- Keep a fenced block on a `take`, `note`, `howto`, or `quote` entry to 40 lines or fewer.
- Tag every fenced block with a language, or `text` for plain output.
- Show a snippet inline only when reading it is the point of the entry.

## Check Command

- Run `./check.sh` on every changed entry before Implement completion.
- Run `./check.sh --all` during Package prep and report the failing-entry count.
- Run `./check.sh --selftest` after every change to `check.sh`.
- Treat any non-warning finding in a changed entry as blocking.
- Treat a warning as a review prompt, not a failure.

Detector codes. Privacy: `P-GUID`, `P-SSH`, `P-HEX`, `P-MAC`, `P-EMAIL`, `P-PATH`, `P-ORG`, `P-DENY`. Warnings: `W-YEAR`, `W-PERSONAL`, `W-NAME`, `W-PLAIN`, and the informational `W-DENY`, `W-TYPE`, `W-EXT`. Budgets: `B-TYPE`, `B-WORDS`, `B-FENCE`. Links: `L-REL`, `L-ANCHOR`, `L-ABS`, `L-EXT`. Structure: `X-MARKER`, `X-HEADING`, `X-LANG`, `X-QA`, `X-FENCE`. Index: `I-INDEX`. Register: `R-PATH`. Privacy and link checks run on every checked file. Budget, fence, marker, heading, and index checks run only on entries and the root site pages. The plain-English warning measures mean words per sentence over prose lines, with front matter, fences, block quotes, headings, table rows, link targets, and code spans removed. `CHANGELOG.md` is exempt from `P-ORG` because its historical rows are immutable.

## Self-Enhancement

- Record each filter gap found in a closure audit as an `IE<N>:` item in `plan.md` in the same completion report.
- Add a detector to `check.sh` for every leak class found in an entry, in the same pass that fixes the entry.
- Add the literal of every personal leak found to the private denylist.
- Review this document at every Package for a rule that failed to prevent a finding.
- Retire a rule only through a Director decision.
