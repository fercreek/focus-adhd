#!/usr/bin/env sh
# Cuts a release: gates, version bump, changelog, commit, tag, push, GitHub release.
#
#   scripts/release.sh patch|minor|major [--dry-run]
#   scripts/release.sh 1.0.0             [--dry-run]
#
# --dry-run stops before the first write and prints what the real run would do.
#
# The gates run FIRST and on the tree as it stands. A release that fails the
# personal-data scan or ships an incomplete manifest is worse than no release,
# and finding that out after the tag is published is too late.
set -eu

cd "$(git rev-parse --show-toplevel)"

bump=""
dry_run=""
for arg in "$@"; do
  case "$arg" in
    major|minor|patch) bump="--bump $arg" ;;
    --dry-run)         dry_run="--dry-run" ;;
    -h|--help)         sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *.*.*)             bump="--set $arg" ;;
    *) echo "✖ unknown argument: $arg" >&2; exit 1 ;;
  esac
done
[ -n "$bump" ] || { echo "✖ say what to release: patch, minor, major, or X.Y.Z" >&2; exit 1; }

step() { printf '\n▸ %s\n' "$1"; }

step "Checking the working tree"
branch=$(git branch --show-current)
[ "$branch" = "main" ] || { echo "✖ on branch '$branch'; release from main" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "✖ uncommitted changes; commit or drop them first" >&2; git status --short >&2; exit 1; }
git fetch --quiet origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || {
  echo "✖ main and origin/main differ; pull or push before releasing" >&2; exit 1; }
echo "  clean, on main, in sync with origin"

step "Running the gates"
scripts/check-personal.sh
python3 scripts/check-manifests.py
if command -v claude > /dev/null 2>&1; then
  claude plugin validate . --strict > /dev/null && echo "✓ plugin manifest valid (strict)"
else
  echo "! claude not on PATH — skipping 'claude plugin validate'"
fi

step "Version and release notes"
notes=$(mktemp)
trap 'rm -f "$notes"' EXIT
# shellcheck disable=SC2086  # $bump is two words on purpose
version=$(python3 scripts/bump_version.py $bump $dry_run --notes-out "$notes")

if [ -n "$dry_run" ]; then
  step "Dry run — nothing was written. A real run would:"
  echo "  1. set version $version in plugin.json and close the changelog entry"
  echo "  2. commit those two files as 'Release $version'"
  echo "  3. tag v$version and push main and the tag"
  echo "  4. open the GitHub release from the notes above"
  exit 0
fi

step "Committing"
python3 scripts/check-manifests.py > /dev/null
git add .claude-plugin/plugin.json CHANGELOG.md
git commit --quiet --message "Release $version" --message "$(cat "$notes")"
git tag --annotate "v$version" --message "focus-adhd $version"
echo "  $(git log --oneline -1)"

step "Pushing"
git push --quiet origin main
git push --quiet origin "v$version"
echo "  main and v$version are on origin"

step "GitHub release"
if command -v gh > /dev/null 2>&1 && gh repo view > /dev/null 2>&1; then
  gh release create "v$version" --title "v$version" --notes-file "$notes"
else
  echo "! gh unavailable or no GitHub remote — tag pushed, release not opened"
fi

step "Released $version"
echo "  Installed copies pick it up with: claude plugin update focus-adhd@focus-adhd"
