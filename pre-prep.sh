#!/usr/bin/env bash
# pre-prep.sh — the Package gate in one command. Rules: AGENTS.md ## Project Rules
#   1. ./check.sh                 every entry changed since the last tag, links fetched
#   2. ./check.sh --no-net --all  the whole site offline: budgets, structure, indexes, register
#   3. gh issue list              no open "Link sweep" issue
# Exit: 0 when all three pass, 1 otherwise. CHECK_CMD overrides the check command for testing.
set -uo pipefail
cd "$(dirname "$0")" || exit 2
CHECK="${CHECK_CMD:-./check.sh}"
rc=0
last=$($CHECK 2>&1 | tail -n 1); printf 'release entries:    %s\n' "${last:-no result}"; [ "$last" = "failing entries: 0" ] || rc=1
last=$($CHECK --no-net --all 2>&1 | tail -n 1); printf 'whole site offline: %s\n' "${last:-no result}"; [ "$last" = "failing entries: 0" ] || rc=1
num=$(gh issue list --state open --search '"Link sweep" in:title' --json number,title --jq '.[] | select(.title=="Link sweep") | .number' 2>/dev/null | head -n 1)
if [ -n "$num" ]; then printf 'link sweep issue:   #%s open\n' "$num"; rc=1; else printf 'link sweep issue:   none open\n'; fi
exit "$rc"
