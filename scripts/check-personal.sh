#!/usr/bin/env sh
# Blocks personal data from reaching this public repo.
#
# Two layers:
#   1. Generic patterns, checked everywhere (CI included): home paths, email
#      addresses, phone numbers.
#   2. A local, git-ignored `.personal-blocklist` (one literal word per line),
#      checked only where it exists. Names, private repo names and numbers live
#      there so the list itself is never published.
#
# Usage:
#   scripts/check-personal.sh                # tracked + untracked files on disk
#   scripts/check-personal.sh --staged       # exactly what the next commit holds
#   scripts/check-personal.sh --range A..B   # commits about to be pushed:
#                                            # messages, file names, identities
#
# Any grep error (exit 2) is a failure, never a silent pass.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 2

mode="${1:-}"
fail=0
self=':(exclude)scripts/check-personal.sh'
blocklist=.personal-blocklist

report() {  # $1 label, $2 search output, $3 search exit code
  if [ "$3" -eq 0 ]; then echo "✖ $1:"; printf '%s\n' "$2" | sed 's/^/    /'; fail=1
  elif [ "$3" -ge 2 ]; then echo "✖ $1: the search itself failed (exit $3)"; fail=1; fi
}

# git grep over the right snapshot: the index for --staged, the working tree
# (untracked included) otherwise. It handles spaces in names and never reads a
# file on disk when the commit holds a different version.
search() {  # $1 flags, $2 pattern
  if [ "$mode" = "--staged" ]; then
    git grep --cached -I -n $1 -e "$2" -- . "$self"
  else
    git grep --untracked -I -n $1 -e "$2" -- . "$self"
  fi
}

PAT_PATH='(/(Users|home)/[A-Za-z0-9._-]+|~/[A-Za-z0-9._-]+/)'
PAT_MAIL='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
PAT_PHONE='(\+[0-9]{1,3}[ .-]?)?\(?[0-9]{2,3}\)?[ .-]?[0-9]{3,4}[ .-]?[0-9]{4}([^0-9]|$)'

scan_words() {  # $1 label, $2 text — private words only
  [ -f "$blocklist" ] || return 0
  while IFS= read -r w; do
    case "$w" in ''|'#'*) continue ;; esac
    hit=$(printf '%s\n' "$2" | grep -niF -e "$w"); report "$1: private word" "$hit" $?
  done < "$blocklist"
}

scan_text() {  # $1 label, $2 text — generic patterns + private words
  for pair in "home path|$PAT_PATH" "email|$PAT_MAIL" "phone|$PAT_PHONE"; do
    label=${pair%%|*}; pat=${pair#*|}
    hit=$(printf '%s\n' "$2" | grep -nE -e "$pat"); report "$1: $label" "$hit" $?
  done
  scan_words "$1" "$2"
}

if [ "$mode" = "--range" ]; then
  range="${2:?usage: --range A..B}"
  for c in $(git rev-list "$range"); do
    # The only email allowed in history is GitHub's noreply address.
    bad=$(git log -1 --format='%ae%n%ce' "$c" | grep -vE '@users\.noreply\.github\.com$')
    report "commit $c email" "$bad" $?
    scan_words "commit $c name" "$(git log -1 --format='%an%n%cn' "$c")"
    scan_text "commit $c message" "$(git log -1 --format='%B' "$c")"
    scan_text "commit $c file names" "$(git show --name-only --format= "$c")"
  done
  mode=""   # then scan the tree as it will be published
fi

out=$(search -E "$PAT_PATH");  report "home path" "$out" $?
out=$(search -E "$PAT_MAIL");  report "email address" "$out" $?
out=$(search -E "$PAT_PHONE"); report "phone number" "$out" $?

if [ -f "$blocklist" ]; then
  while IFS= read -r w; do
    case "$w" in ''|'#'*) continue ;; esac
    out=$(search "-i -F" "$w"); report "private word" "$out" $?
  done < "$blocklist"
fi

if [ "$mode" = "--staged" ]; then
  scan_words "commit name" "$(git config user.name)"
  git config user.email | grep -qE '@users\.noreply\.github\.com$' || {
    echo "✖ commit email: use GitHub's noreply address first:"
    echo "    git config user.email <id>+<user>@users.noreply.github.com"; fail=1; }
fi

if [ "$fail" -ne 0 ]; then echo; echo "Personal data found. Remove it before committing."; exit 1; fi
echo "✓ no personal data"
