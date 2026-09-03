#!/usr/bin/env bash
# check.sh — publishing-filter checks for this site. Rules: govna/publishing-filter.md
#
# Targets Bash 3.2+ (macOS system Bash): no associative arrays, mapfile,
# ${var^^}, or &>>. Needs rg, curl, awk, and coreutils.
#
# Usage:
#   ./check.sh [paths...]   check the given files, or every .md changed since the latest tag
#   ./check.sh --all        check the whole site
#   ./check.sh --selftest   prove each detector on temporary fixtures
#   ./check.sh --register   validate govna/stance-register.md only
#   ./check.sh --no-net     skip external link fetching (combinable)
# Output: one "file:line: CODE message" per finding, then "failing entries: N".
# Exit: 0 clean, 1 findings, 2 usage error. W-* codes are warnings and never fail.
set -uo pipefail
SELF=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")

ROOT="${CHECK_ROOT:-}"
[ -z "$ROOT" ] && ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT" || exit 2

NET=1
MODE=paths
DENYLIST="${BITS_DENYLIST:-$HOME/.config/bits/denylist.txt}"
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'
TMP=$(mktemp -d "${TMPDIR:-/tmp}/check.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
OUT="$TMP/findings"; : >"$OUT"
URLCACHE="$TMP/urlcache"; : >"$URLCACHE"
INDEXDIRS="$TMP/indexdirs"; : >"$INDEXDIRS"

GUID_RE='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
GUID_OK='1950a258-227b-4e31-a9cf-717495945fc2|00000000-0000-0000-0000-000000000000'
SSH_RE='ssh-(ed25519|rsa|ecdsa|dss) AAAA[A-Za-z0-9+/]{20,}'
HEX_RE='\b[0-9a-f]{40,}\b'
HEX_OK='sha256|shasum|sha512|md5sum|\.(iso|gz|tgz|zip|tar|dmg|img|xz|7z|pem|crt)\b'
MAC_RE='\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b|\b0800[0-9A-F]{8}\b'
EMAIL_RE='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
EMAIL_OK='@(example\.(com|org|net)|mydomain\.com|somewhere\.com|contoso\.com|users\.noreply\.github\.com|github\.com|tty[0-9])|YOUR-[A-Z-]*@'
PATH_RE='/(Users|home)/[A-Za-z0-9._-]+'
PATH_OK='/(Users|home)/(myuser|myusername|someuser|user1|USERNAME|username|pi|linuxbrew|roms|test|<)'
ORG_RE='(github\.com|githubusercontent\.com)/kquo/'
FP_RE="\\b(I|my|me|myself|I'm|I've|I'd)\\b"
YEAR_RE='\b(19[0-9]{2}|20[0-9]{2})\b'
PERSONAL_RE='\b(wife|husband|partner|kids?|children|daughter|son|mother|father|parents?|employer|my company|my job|my boss|my doctor|diagnos|my house|my apartment|I live in|my neighborhood|my hometown|my salary)\b'
MARKER_RE='NEEDS REWRITE|\(need link\)|\[Need sources\]|Needs clean up'
MARKER_CS_RE='\b(TODO|FIXME|TBD)\b'
HEADING_RE='^#{1,6}[[:space:]]*(Conclusion|Final Thoughts|Bottom Line|Key Insight|Summary|Question|Answer)[[:space:]]*:?[[:space:]]*$'
URL_SKIP='mydomain\.com|example\.(com|org|net)|somewhere\.com|contoso\.com|169\.254\.169\.254|://(10|192\.168|127)\.|localhost|\{|%s|<|\$|/\.default$|token\.actions\.githubusercontent\.com|management\.azure\.com/?$|graph\.microsoft\.com/?$'
HOST_ALLOW='stackoverflow\.com|stackexchange\.com|medium\.com|congress\.gov|sagepub\.com|politico\.com|devgenius\.io'
HOST_SHORT='youtu\.be|youtube\.com|a\.co|aka\.ms|bit\.ly|t\.co|amazon\.com'
FENCE_MAX=40

usage() {
  sed -n '2,15p' "$SELF" | sed 's/^# \{0,1\}//'
}

emit() { # file line code message
  printf '%s:%s: %s %s\n' "$1" "$2" "$3" "$4" >>"$OUT"
}

kind_of() {
  case "$1" in
    life/index.md | mind/index.md | society/index.md | tech/index.md) echo index ;;
    life/*/index.md | mind/*/index.md | society/*/index.md | tech/*/index.md) echo index ;;
    life/*.md | mind/*.md | society/*.md | tech/*.md) echo entry ;;
    about.md | index.md | timeline.md) echo root ;;
    *.md) echo other ;;
    *) echo skip ;;
  esac
}

front_value() { # file key -> value or empty
  awk -v key="$2" 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1 && index($0,key":")==1 {v=$0; sub("^" key ":[[:space:]]*","",v); gsub(/^["'"'"']|["'"'"']$/,"",v); print v; exit}' "$1"
}

prose_words() { # file -> word count outside front matter, fences, html comments
  awk 'NR==1 && $0=="---"{fm=1; next} fm==1 && $0=="---"{fm=0; next} fm==1{next}
       /^(```|~~~)/{fence=!fence; next} fence{next}
       {gsub(/<!--[^>]*-->/,""); print}' "$1" | wc -w | tr -d ' '
}

fence_max() { # file -> longest fenced block line count
  awk '/^(```|~~~)/{ if(fence){ if(n>max)max=n; fence=0 } else { fence=1; n=0 }; next } fence{n++} END{print max+0}' "$1"
}

slugs_of() { # file -> kramdown and gfm slugs of every heading, one per line
  rg -N -e '^#{1,6} ' "$1" 2>/dev/null | sed -E 's/^#+[[:space:]]*//; s/[[:space:]]*#*[[:space:]]*$//' \
    | tr '[:upper:]' '[:lower:]' | sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g; s/[^a-z0-9 _-]//g; s/ /-/g' \
    | awk '{print; g=$0; sub(/^[^a-z]+/,"",g); if(g!=$0) print g}'
}

linksrc() { # file -> same line count with fenced blocks and code spans blanked
  awk '/^(```|~~~)/{fence=!fence; print ""; next} fence{print ""; next} {gsub(/`[^`]*`/,""); print}' "$1"
}

budget_for() {
  case "$1" in take) echo 250 ;; note) echo 400 ;; howto) echo 500 ;; quote) echo 300 ;; reference) echo 0 ;; *) echo 400 ;; esac
}

# ── privacy (every file) ────────────────────────────────────────────────────
check_privacy() {
  local f="$1" l
  rg -n -e "$GUID_RE" "$f" | rg -v -e "$GUID_OK" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-GUID "GUID in content"; done
  rg -n -e "$SSH_RE" "$f" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-SSH "SSH key material"; done
  rg -n -e "$HEX_RE" "$f" | rg -v -e "$HEX_OK" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-HEX "long hex string"; done
  rg -n -e "$MAC_RE" "$f" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-MAC "MAC address"; done
  rg -n -e "$EMAIL_RE" "$f" | rg -v -e "$EMAIL_OK" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-EMAIL "email address outside placeholder domains"; done
  rg -n -e "$PATH_RE" "$f" | rg -v -e "$PATH_OK" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-PATH "home directory path"; done
  if [ "$f" != CHANGELOG.md ]; then
    rg -n -e "$ORG_RE" "$f" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-ORG "reference to the retired kquo org"; done
  fi
  if [ -s "$DENYLIST" ]; then
    rg -n -i -F -f "$DENYLIST" "$f" | cut -d: -f1 | while read -r l; do emit "$f" "$l" P-DENY "denylisted literal"; done
  fi
  rg -n -e "$FP_RE" "$f" | rg -e "$YEAR_RE" | cut -d: -f1 | while read -r l; do emit "$f" "$l" W-YEAR "exact year in a first-person sentence"; done
  rg -n -e "$FP_RE" "$f" | rg -i -e "$PERSONAL_RE" | cut -d: -f1 | while read -r l; do emit "$f" "$l" W-PERSONAL "personal detail keyword in a first-person sentence"; done
}

# ── links (every file) ──────────────────────────────────────────────────────
norm_url() { printf '%s' "$1" | sed -E 's#^https?://##; s#^www\.##; s#[?#].*$##; s#/$##'; }

fetch_url() { # url -> "code final"
  local hit
  hit=$(awk -F'\t' -v u="$1" '$1==u{print $2; exit}' "$URLCACHE")
  if [ -n "$hit" ]; then printf '%s' "$hit"; return; fi
  hit=$(curl -sL -A "$UA" --max-time 20 -r 0-0 -o /dev/null -w '%{http_code} %{url_effective}' "$1" 2>/dev/null || printf '000 -')
  printf '%s\t%s\n' "$1" "$hit" >>"$URLCACHE"
  printf '%s' "$hit"
}

check_external() { # file line url
  local f="$1" l="$2" u="$3" res code final
  printf '%s' "$u" | rg -q -e 'https?://que\.one' && { emit "$f" "$l" L-ABS "absolute que.one link, use a relative path"; return 0; }
  printf '%s' "$u" | rg -q -e "$URL_SKIP" && return 0
  [ "$NET" -eq 1 ] || return 0
  printf '%s' "$u" | rg -q -e "://([^/]*\.)?($HOST_ALLOW)" && { emit "$f" "$l" W-EXT "host on the bot-block allowlist, verify in a browser: $u"; return 0; }
  res=$(fetch_url "$u"); code="${res%% *}"; final="${res#* }"
  case "$code" in
    2*) ;;
    429) emit "$f" "$l" W-EXT "rate limited, retry: $u"; return 0 ;;
    *) emit "$f" "$l" L-EXT "dead ($code): $u"; return 0 ;;
  esac
  printf '%s' "$u" | rg -q -e "://([^/]*\.)?($HOST_SHORT)" && return 0
  if [ "$(norm_url "$u")" != "$(norm_url "$final")" ]; then emit "$f" "$l" L-EXT "moved to $final"; fi
}

check_links() {
  local f="$1" d line l t p a target src="$TMP/links.src"
  d=$(dirname "$f")
  linksrc "$f" >"$src"
  { rg -n -o -e '\]\(([^)]+)\)' -r '$1' "$src"; rg -n -o -e 'href="([^"]+)"' -r '$1' "$src"; rg -n -o -e '<(https?://[^>]+)>' -r '$1' "$src"; } 2>/dev/null \
  | sort -u | sort -t: -k1,1n | while IFS= read -r line; do
    l="${line%%:*}"; t="${line#*:}"
    t="${t%% *}"
    case "$t" in
      http://* | https://*) check_external "$f" "$l" "$t" ;;
      mailto:* | tel:* | \{\{*) ;;
      \#*) a="${t#\#}"; slugs_of "$f" | rg -q -x -F "$a" || emit "$f" "$l" L-ANCHOR "no heading for #$a in this page" ;;
      *)
        p="${t%%#*}"; a=""; case "$t" in *\#*) a="${t#*#}" ;; esac
        target="$d/$p"; [ "$d" = . ] && target="$p"
        if [ -e "$target" ]; then :
        elif [ -e "$target.md" ]; then target="$target.md"
        else emit "$f" "$l" L-REL "missing target $t"; continue; fi
        if [ -n "$a" ] && [ -f "$target" ]; then
          slugs_of "$target" | rg -q -x -F "$a" || emit "$f" "$l" L-ANCHOR "no heading for #$a in $p"
        fi ;;
    esac
  done
}

# ── structure and budgets (entries and root pages) ──────────────────────────
check_structure() {
  local f="$1" kind="$2" l t words budget fmax
  { rg -n -i -e "$MARKER_RE" "$f"; rg -n -e "$MARKER_CS_RE" "$f"; } | cut -d: -f1 | sort -n -u | while read -r l; do emit "$f" "$l" X-MARKER "placeholder marker"; done
  rg -n -i -e "$HEADING_RE" "$f" | cut -d: -f1 | while read -r l; do emit "$f" "$l" X-HEADING "boilerplate section heading"; done
  t=$(front_value "$f" type)
  if [ "$kind" = entry ]; then
    if [ -z "$t" ]; then
      if [ "$MODE" = all ]; then emit "$f" 1 W-TYPE "no type front matter, treated as note"; else emit "$f" 1 B-TYPE "type front matter required on a changed entry"; fi
      t=note
    else
      case "$t" in take | note | howto | reference | quote) ;; *) emit "$f" 1 B-TYPE "unknown type $t"; t=note ;; esac
    fi
  else
    t=note
  fi
  budget=$(budget_for "$t"); words=$(prose_words "$f")
  if [ "$budget" -gt 0 ] && [ "$words" -gt "$budget" ]; then emit "$f" 1 B-WORDS "$words prose words, budget $budget for $t"; fi
  fmax=$(fence_max "$f")
  if [ "$t" != reference ] && [ "$fmax" -gt "$FENCE_MAX" ]; then emit "$f" 1 B-FENCE "fenced block of $fmax lines, limit $FENCE_MAX"; fi
}

# ── index completeness (directories with an index.md) ───────────────────────
check_index_dir() { # dir
  local d="$1" idx="$1/index.md" f name
  [ -f "$idx" ] || return 0
  for f in "$d"/*.md "$d"/*/index.md; do
    [ -e "$f" ] || continue
    [ "$f" = "$idx" ] && continue
    name="${f#$d/}"
    rg -q -F -e "]($name)" -e "]($name#" -e "href=\"$name\"" "$idx" || emit "$idx" 1 I-INDEX "missing entry $name"
  done
}

# ── stance register ─────────────────────────────────────────────────────────
check_register() {
  local reg="govna/stance-register.md" l row status tok
  [ -f "$reg" ] || { emit "$reg" 1 R-PATH "register missing"; return; }
  rg -n -e '^\| *[0-9]+ *\|' "$reg" | while IFS= read -r row; do
    l="${row%%:*}"; row="${row#*:}"
    status=$(printf '%s' "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$5); print $5}')
    case "$status" in settled | unresolved) ;; *) emit "$reg" "$l" R-PATH "status must be settled or unresolved" ;; esac
    printf '%s' "$row" | awk -F'|' '{print $4}' | rg -o -e '`[^`]+`' | tr -d '`' | while read -r tok; do
      [ -e "$tok" ] || emit "$reg" "$l" R-PATH "owning path missing: $tok"
    done
  done
}

# ── driver ──────────────────────────────────────────────────────────────────
check_file() {
  local f="$1" kind
  kind=$(kind_of "$f")
  [ "$kind" = skip ] && return 0
  [ -f "$f" ] || { emit "$f" 1 L-REL "file not found"; return 0; }
  check_privacy "$f"
  check_links "$f"
  case "$kind" in
    entry) check_structure "$f" entry; printf '%s\n' "$(dirname "$f")" >>"$INDEXDIRS" ;;
    root) check_structure "$f" root ;;
    index) printf '%s\n' "$(dirname "$f")" >>"$INDEXDIRS" ;;
  esac
}

changed_set() {
  local tag
  tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
  { if [ -n "$tag" ]; then git diff --name-only "$tag" -- . ; else git ls-files; fi; git ls-files --others --exclude-standard; } 2>/dev/null \
    | rg -e '\.md$' | sort -u | while read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done
}

all_set() {
  { fd -e md . life mind society tech govna 2>/dev/null || find life mind society tech govna -name '*.md'; printf '%s\n' about.md index.md timeline.md AGENTS.md plan.md CHANGELOG.md README.md; } \
    | sed 's#^\./##' | sort -u | while read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done
}

report() {
  local fails
  sort -u "$OUT"
  fails=$(rg -v -e ': W-' "$OUT" | cut -d: -f1 | sort -u | wc -l | tr -d ' ')
  printf 'failing entries: %s\n' "$fails"
  [ "$fails" -eq 0 ]
}

# ── selftest ────────────────────────────────────────────────────────────────
selftest() {
  local fx="$TMP/fx" clean="$TMP/clean" res ok=0 c
  mkdir -p "$fx/life/sub" "$fx/govna" "$clean/life" "$clean/govna"
  printf 'secretword\n' >"$TMP/deny.txt"
  {
    printf -- '---\ntype: take\n---\n## Dirty\n'
    printf 'Id 12345678-abcd-4bcd-8bcd-123456789abc here.\n'
    printf 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIabcdefghijklmnopqrstuvwxyz0123 user@host\n'
    printf 'hash 0123456789abcdef0123456789abcdef0123456789abcdef\n'
    printf 'mac 08:00:27:AE:2F:12 and 080027AE2F12\n'
    printf 'mail someone@realcompany.com\n'
    printf 'path /%s/realname/code\n' Users
    printf 'org https://github.com/kquo/thing\n'
    printf 'the SecretWord appears\n'
    printf 'I first read it in 1992 and my wife agreed.\n'
    printf 'see [broken](nowhere.md) and [anchor](#no-such-heading) and [abs](https://que.one/x) and [dead](https://nonexistent.invalid/x)\n'
    printf 'TODO fix\n## Conclusion\n'
    printf '```\n'; c=0; while [ $c -lt 45 ]; do printf 'line %s\n' "$c"; c=$((c+1)); done; printf '```\n'
    c=0; while [ $c -lt 300 ]; do printf 'word '; c=$((c+1)); done; printf '\n'
  } >"$fx/life/dirty.md"
  printf '## Untyped\n\nShort.\n' >"$fx/life/untyped.md"
  printf '## Life\n\n- [Dirty](dirty.md)\n' >"$fx/life/index.md"
  printf '## Sub\n' >"$fx/life/sub/index.md"
  printf '# Register\n\n| # | Position | Owning entry | Status |\n|---|---|---|---|\n| 1 | X. | `life/missing.md` | settled |\n| 2 | Y. | `life/dirty.md` | bogus |\n' >"$fx/govna/stance-register.md"
  printf -- '---\ntype: note\n---\n## Clean\n\nA clean [entry](index.md) with one [ref](https://en.wikipedia.org/wiki/Main_Page).\n' >"$clean/life/clean.md"
  printf '## Life\n\n- [Clean](clean.md)\n' >"$clean/life/index.md"
  printf '# Register\n\n| # | Position | Owning entry | Status |\n|---|---|---|---|\n| 1 | X. | `life/clean.md` | settled |\n' >"$clean/govna/stance-register.md"

  res=$( (CHECK_ROOT="$fx" BITS_DENYLIST="$TMP/deny.txt" "$SELF" life/dirty.md life/untyped.md; CHECK_ROOT="$fx" "$SELF" --register) 2>&1 )
  for c in P-GUID P-SSH P-HEX P-MAC P-EMAIL P-PATH P-ORG P-DENY W-YEAR W-PERSONAL B-TYPE B-WORDS B-FENCE L-REL L-ANCHOR L-ABS L-EXT X-MARKER X-HEADING I-INDEX R-PATH; do
    if printf '%s\n' "$res" | rg -q -e " $c "; then printf 'PASS %s\n' "$c"; else printf 'FAIL %s\n' "$c"; ok=1; fi
  done
  res=$( (CHECK_ROOT="$clean" BITS_DENYLIST="$TMP/deny.txt" "$SELF" --all; CHECK_ROOT="$clean" "$SELF" --register) 2>&1 )
  if printf '%s\n' "$res" | rg -q -e ': [A-Z]-'; then printf 'FAIL clean fixture produced findings:\n%s\n' "$res"; ok=1; else printf 'OK clean-fixture\n'; fi
  return $ok
}

# ── main ────────────────────────────────────────────────────────────────────
main() {
  local files='' a d
  for a in "$@"; do
    case "$a" in
      -h | -\? | --help) usage; return 0 ;;
      --all) MODE=all ;;
      --selftest) MODE=selftest ;;
      --register) MODE=register ;;
      --no-net) NET=0 ;;
      -*) printf 'unsupported option %s\n' "$a" >&2; usage >&2; return 2 ;;
      *) files="$files$a"$'\n' ;;
    esac
  done
  case "$MODE" in
    selftest) selftest; return $? ;;
    register) check_register; report; return $? ;;
  esac
  [ -s "$DENYLIST" ] || printf 'W-DENY denylist not found at %s (set BITS_DENYLIST)\n' "$DENYLIST" >&2
  if [ "$MODE" = all ]; then files=$(all_set); elif [ -z "$files" ]; then files=$(changed_set); fi
  [ -n "$files" ] || { printf 'nothing to check\n'; printf 'failing entries: 0\n'; return 0; }
  printf '%s\n' "$files" | while read -r a; do [ -n "$a" ] && check_file "$a"; done
  if [ "$MODE" = all ]; then
    for a in life mind society tech; do [ -d "$a" ] || continue; check_index_dir "$a"; for d in "$a"/*/; do [ -d "$d" ] && check_index_dir "${d%/}"; done; done
    check_register
  else
    sort -u "$INDEXDIRS" | while read -r a; do [ -n "$a" ] && check_index_dir "$a"; done
  fi
  report
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
  exit $?
fi
