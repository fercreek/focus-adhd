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

   It runs `scripts/check-personal.sh`, which blocks home paths, emails and phone
   numbers. You can add your own private words to a local `.personal-blocklist`
   (one pattern per line); it is git-ignored.

Bump `version` in `.claude-plugin/plugin.json` with every change to the skill, or
installed copies will not pick it up.
