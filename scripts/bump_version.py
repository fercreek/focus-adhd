#!/usr/bin/env python3
"""Moves the version forward in plugin.json and closes the changelog entry.

The changelog is the source of the release notes: `## [Unreleased]` becomes
`## [X.Y.Z] - <date>`, a fresh empty `## [Unreleased]` takes its place, and the
comparison links at the bottom are rewritten. Refusing to release with an empty
`## [Unreleased]` is deliberate — a release nobody can read is not a release.

Prints the new version on stdout; everything else goes to stderr, so a caller
can do `new=$(bump_version.py --bump minor)`.

    bump_version.py --bump patch|minor|major [--set X.Y.Z]
                    [--date YYYY-MM-DD] [--notes-out FILE] [--dry-run]
"""
import argparse
import datetime
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PLUGIN = ROOT / ".claude-plugin/plugin.json"
CHANGELOG = ROOT / "CHANGELOG.md"
SEMVER = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")
UNRELEASED_HEADING = "## [Unreleased]"


def die(message):
    print(f"✖ {message}", file=sys.stderr)
    sys.exit(1)


def next_version(current, bump):
    match = SEMVER.match(current)
    if not match:
        die(f"plugin.json version `{current}` is not X.Y.Z")
    major, minor, patch = (int(part) for part in match.groups())
    if bump == "major":
        return f"{major + 1}.0.0"
    if bump == "minor":
        return f"{major}.{minor + 1}.0"
    return f"{major}.{minor}.{patch + 1}"


def split_unreleased(text):
    """Returns (notes, start, end) for the Unreleased section's body."""
    start = text.find(UNRELEASED_HEADING)
    if start == -1:
        die(
            f"CHANGELOG.md has no `{UNRELEASED_HEADING}` section. Add one and "
            "describe the change under it before releasing."
        )
    body_start = start + len(UNRELEASED_HEADING)
    next_heading = re.search(r"^## ", text[body_start:], re.MULTILINE)
    body_end = body_start + next_heading.start() if next_heading else len(text)
    return text[body_start:body_end].strip(), start, body_end


def repo_url():
    """The compare links need the repo URL; take it from the manifest."""
    manifest = json.loads(PLUGIN.read_text())
    url = manifest.get("repository") or manifest.get("homepage", "")
    return url.split("#")[0].rstrip("/")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bump", choices=("major", "minor", "patch"))
    parser.add_argument("--set", dest="exact", help="use this exact version")
    parser.add_argument("--date", default=datetime.date.today().isoformat())
    parser.add_argument("--notes-out", type=pathlib.Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if bool(args.bump) == bool(args.exact):
        die("pass exactly one of --bump or --set")

    manifest_text = PLUGIN.read_text()
    current = json.loads(manifest_text)["version"]
    new = args.exact or next_version(current, args.bump)
    if not SEMVER.match(new):
        die(f"`{new}` is not X.Y.Z")
    if tuple(map(int, new.split("."))) <= tuple(map(int, current.split("."))):
        die(f"{new} does not come after the current {current}")

    changelog = CHANGELOG.read_text()
    notes, start, body_end = split_unreleased(changelog)
    if not notes:
        die(
            f"`{UNRELEASED_HEADING}` is empty. Describe what changed before releasing."
        )

    released = (
        f"{UNRELEASED_HEADING}\n\n## [{new}] - {args.date}\n\n{notes}\n\n"
    )
    updated = changelog[:start] + released + changelog[body_end:].lstrip("\n")

    url = repo_url()
    old_link = f"[Unreleased]: {url}/compare/v{current}...HEAD"
    new_links = (
        f"[Unreleased]: {url}/compare/v{new}...HEAD\n"
        f"[{new}]: {url}/compare/v{current}...v{new}"
    )
    if old_link in updated:
        updated = updated.replace(old_link, new_links)
    else:
        print(
            f"! no `[Unreleased]` link found for v{current}; appending the new one",
            file=sys.stderr,
        )
        updated = updated.rstrip("\n") + f"\n[{new}]: {url}/compare/v{current}...v{new}\n"

    manifest_updated = manifest_text.replace(
        f'"version": "{current}"', f'"version": "{new}"', 1
    )
    if manifest_updated == manifest_text:
        die(f'could not find `"version": "{current}"` in plugin.json')

    print(f"{current} -> {new} ({args.date})", file=sys.stderr)
    print(notes, file=sys.stderr)

    if args.notes_out:
        args.notes_out.write_text(notes + "\n")

    if not args.dry_run:
        PLUGIN.write_text(manifest_updated)
        CHANGELOG.write_text(updated)

    print(new)


if __name__ == "__main__":
    main()
