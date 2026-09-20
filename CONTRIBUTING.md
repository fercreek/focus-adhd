# Contributing

Improvements to the rules are welcome. Three things keep the skill honest:

1. **Every rule needs a reason.** Add the source to the table at the bottom of
   `skills/focus-adhd/SKILL.md`. If there is no evidence, say so in the
   "declared gaps" list instead of inventing one.
2. **Shape, never delete.** A rule may change how an answer is presented. It must
   never drop information, invent a cause, or skip a safety confirmation.
3. **No personal data.** Enable the hook once per clone:

   ```sh
   git config core.hooksPath .githooks
   ```

   `pre-commit` checks exactly what you staged; `pre-push` also checks commit
   messages, file names and author emails (only GitHub's `noreply` address is
   allowed). Set it before your first commit:

   ```sh
   git config user.email <id>+<user>@users.noreply.github.com
   ```

   The scan blocks home paths, emails and phone numbers. You can add your own private words to a local `.personal-blocklist`
   (one pattern per line); it is git-ignored.

## Before opening a pull request

```sh
scripts/check-personal.sh      # the same scan CI runs
python3 scripts/check-manifests.py
claude plugin validate . --strict
```

Describe the change under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md). Don't bump
the version by hand — the release script does it, and it reads that section for the
release notes.

## Cutting a release

From a clean `main` that is in sync with `origin`:

```sh
scripts/release.sh minor --dry-run   # the whole plan, nothing written
scripts/release.sh minor             # gates, bump, changelog, commit, tag, push, release
```

It runs the gates first, turns `## [Unreleased]` into a dated entry, commits, tags
`vX.Y.Z`, pushes and opens the GitHub release. It stops if the tree is dirty, if you are
not on `main`, if `main` and `origin/main` differ, or if `## [Unreleased]` is empty.

Installed copies pick the release up with `claude plugin update focus-adhd@focus-adhd`.
