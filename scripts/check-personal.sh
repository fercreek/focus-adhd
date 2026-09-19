#!/usr/bin/env sh
# Blocks personal data from reaching this public repo.
#
# Two layers:
#   1. Generic patterns, checked everywhere (CI included): absolute home paths,
#      email addresses, long phone-like digit runs.
#   2. A local, git-ignored `.personal-blocklist` (one pattern per line), checked
#      only where it exists. Names, private repo names and numbers live there so
#      the list itself is never published.
#
# Usage: scripts/check-personal.sh [--staged]
set -eu
cd "$(git rev-parse --show-toplevel)"

if [ "${1:-}" = "--staged" ]; then
  files=$(git diff --cached --name-only --diff-filter=ACM)
else
  files=$(git ls-files; git ls-files --others --exclude-standard)
fi
files=$(printf '%s\n' "$files" | grep -v -e '^scripts/check-personal.sh$' -e '^$' || true)
[ -z "$files" ] && exit 0

fail=0
scan() {  # $1 = label, $2 = extended regex, $3 = grep case flag
  hits=$(printf '%s\n' "$files" | xargs grep -nE $3 -- "$2" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "✖ $1:"; printf '%s\n' "$hits" | sed 's/^/    /'; fail=1
  fi
}

scan "absolute home path" '/(Users|home)/[A-Za-z0-9._-]+' ''
scan "email address" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' ''
scan "phone-like number" '(^|[^0-9a-f])[0-9]{10,13}([^0-9a-f]|$)' ''

if [ -f .personal-blocklist ]; then
  while IFS= read -r p; do
    case "$p" in ''|'#'*) continue ;; esac
    scan "private word «$p»" "$p" '-i'
  done < .personal-blocklist
fi

if [ "$fail" -ne 0 ]; then
  echo; echo "Personal data found. Remove it before committing."; exit 1
fi
echo "✓ no personal data"
