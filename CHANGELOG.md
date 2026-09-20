# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.3.0]: https://github.com/fercreek/focus-adhd/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/fercreek/focus-adhd/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/fercreek/focus-adhd/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/fercreek/focus-adhd/releases/tag/v0.1.0
