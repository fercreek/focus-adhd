# focus-adhd

**Your coding agent writes more when it works more. You need it to write more only when you have more to decide.**

A Claude Code skill that shapes every response for a reader with ADHD. One law drives it:

> Response length scales with the **decisions and actions that belong to you** — never with how much work the agent did.

## Before / after

**Without it**, after a long task:

```
I've gone ahead and looked through the auth module. First I checked the
middleware, which was fine. Then I looked at the token service and noticed
the expiry was hardcoded, so I updated that. I also ran the test suite —
all 42 tests passed. Along the way I noticed the README is outdated and a
dependency is two versions behind. Let me know if you'd like me to look at
any of those, or if there's anything else I can help with!
```

**With it:**

```
Token expiry now reads from config (was hardcoded to 1 h). 42 tests green.

Separately: one dependency is two versions behind. Update it next?
```

One decision for you, so two lines. The steps that went fine are invisible.

## What it does

- **Decision budget.** 0 decisions → 1 line. 1 → up to 3 lines. 2-4 → a numbered list. 5+ → split into "now" and "the rest".
- **Small working set.** Lists cap at 3, options at 3 with the recommended one first, tables at 3 columns. The cap shapes *presentation*, never analysis.
- **No number alone.** "18%" becomes "18%, almost one in five".
- **Concrete time, visible progress.** "About 15 min if tests exist", and "step 3 of 5" every turn.
- **One question per turn**, and only when genuinely blocked.
- **Simple mode.** Say "I didn't get it" and it re-explains in one idea, no jargon, with an everyday analogy.
- **Honest limits.** It never invents a cause to fit a format, and keeps a "maybe" that carries real doubt.

Every rule lists its source at the bottom of [`SKILL.md`](skills/focus-adhd/SKILL.md), and the gaps where no evidence exists are declared, not filled.

## Install

In Claude Code:

```
/plugin marketplace add fercreek/focus-adhd
/plugin install focus-adhd@focus-adhd
```

Then say **"adhd mode"** in any session. Say **"stop adhd mode"** to turn it off.

Update later with `/plugin marketplace update focus-adhd`.

## Add your own layer

Keep this skill generic and put what is only yours — your trigger words, your hooks, your closing format — in a small private skill or in your `CLAUDE.md`. Improvements to the general rules come back here as a PR; your personal layer never has to be published.

## Credits

Built on ideas from [`ayghri/i-have-adhd`](https://github.com/ayghri/i-have-adhd) (pre-send check, escape hatches, concrete estimates, evals), `alexh/i-really-have-adhd` (the decision budget) and `webbrain-one/adhd-and-47-tabs` (response contracts). The difference here is the decision budget as the core law, the 3-item cap grounded in working-memory research, and the numbers-need-meaning rule.

## Contributing

`scripts/check-personal.sh` runs in CI and as a pre-commit hook (`git config core.hooksPath .githooks`). It blocks home paths, emails and phone numbers from being committed.

## License

MIT
