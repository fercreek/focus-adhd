# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `evals/RESULTS.md`: first blind evaluation on the `i-have-adhd` harness, against a bare
  baseline and `i-have-adhd` itself (14 cases, 3 trials). focus-adhd scores 4.46 of 5,
  above the bare model's 4.30 and below i-have-adhd's 4.58, and fails the release gate on
  a safety regression in the `destructive-action` case.

## [1.0.0] - 2026-09-20

This release declares the skill stable. Nothing in how it behaves changed — the rules
have been untouched since 0.2.1, and 0.3.0 and 0.4.0 were packaging. What changes is the
promise:

- **The trigger phrases are a contract.** "focus mode" / "adhd mode" turn it on,
  "stop focus mode" / "stop adhd mode" / "normal mode" turn it off. Removing or renaming
  any of them is a breaking change and will be a major version.
- **The names are a contract.** The plugin, the marketplace and the skill are all
  `focus-adhd`; installs and any private layer built on top depend on that.
- **Rules may be sharpened, not silently reversed.** A change that flips what the skill
  does in a case it already covered ships as a major, with the reason in this file.

The decision budget, the 3-item cap and the numbers-need-meaning rule stay as they are,
with their sources listed in `SKILL.md` and the three gaps still declared rather than
filled in.

## [0.4.0] - 2026-09-20

### Added
- `scripts/release.sh`: runs the gates, bumps the version, closes the changelog entry,
  commits, tags, pushes and opens the GitHub release. `--dry-run` shows the whole plan
  without writing anything.
- `scripts/bump_version.py`, which the release script uses to move the version forward
  and turn `## [Unreleased]` into a dated entry. It refuses to release when that section
  is empty — a release nobody can read is not a release.

## [0.3.0] - 2026-09-20

First public release. No change to the skill's rules — this is packaging.

### Added
- `CHANGELOG.md`.
- `repository`, `displayName` and a `homepage` pointing at the README in `plugin.json`;
  the same metadata on the marketplace entry, so the catalog entry stands on its own.
- `workflow_dispatch` on the `check` workflow, so the gate can be run without a push.
- `scripts/check-manifests.py`: fails when a manifest is missing a field Claude Code
  needs. Valid JSON was not enough — a `marketplace.json` without `owner` parses fine
  and breaks every install. It runs in CI and in the pre-commit hook.

### Changed
- Keywords now describe what the plugin does (`focus`, `concise-responses`) and not only
  what it is.

## [0.2.1] - 2026-09-18

### Added
- The pre-push hook checks every commit that is about to leave: identities, messages and
  file names, not only the working tree. CI runs after the push, which is too late.

### Changed
- The gate scans the right snapshot with `git grep` — the index for `--staged`, the
  working tree otherwise — and matches private words literally.
- The skill announces itself when it turns the mode on by itself, and says how to leave.
- Only a question that genuinely blocks the work waits for an answer.

### Fixed
- The list cap contradicted itself: it now shapes presentation only, never analysis.

## [0.2.0] - 2026-09-18

### Added
- `CONTRIBUTING.md`.
- A comparison with `ayghri/i-have-adhd` at the top of the README, and a before/after
  example.

### Changed
- Distinct phrases to turn the mode on and off, so neither fires by accident.

## [0.1.0] - 2026-09-18

### Added
- First release: the `focus-adhd` skill, the plugin and marketplace manifests, and the
  personal-data gate with its hooks and CI job.

[Unreleased]: https://github.com/fercreek/focus-adhd/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/fercreek/focus-adhd/compare/v0.4.0...v1.0.0
[0.4.0]: https://github.com/fercreek/focus-adhd/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/fercreek/focus-adhd/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/fercreek/focus-adhd/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/fercreek/focus-adhd/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/fercreek/focus-adhd/releases/tag/v0.1.0
