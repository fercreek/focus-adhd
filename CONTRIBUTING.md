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

Bump `version` in `.claude-plugin/plugin.json` with every change to the skill, or
installed copies will not pick it up, and add the change under `## [Unreleased]` in
[CHANGELOG.md](CHANGELOG.md).
