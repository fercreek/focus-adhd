# focus-adhd

**Your coding agent writes more when it works more. You need it to write more only when you have more to decide.**

A Claude Code skill that shapes every response for a reader with ADHD. One law drives it:

> Response length scales with the **decisions and actions that belong to you** — never with how much work the agent did.

## How it differs from i-have-adhd

[`ayghri/i-have-adhd`](https://github.com/ayghri/i-have-adhd) is excellent and this skill borrows from it. The difference is what decides the length:

| | i-have-adhd | focus-adhd |
|---|---|---|
| What sets the length | formatting rules | **your pending decisions** (0 → 1 line) |
| Work that went fine | shown as wins | invisible — only surprises earn words |
| List cap | 5, by convention | 3, from working-memory research (Cowan 2001) |
| Numbers | — | never alone: "18%, almost one in five" |

**Use one or the other, not both** — their rules overlap and both answer to "stop adhd mode".

It is also honest about its limits: the skill lists the source for every rule and declares the three places where no evidence exists, instead of filling them in.

## Before / after

**Without it**, after migrating a CSV import job:

```
I started by reading the importer to understand the current flow. Then I
checked the CSV parser, which looked fine. I refactored the row mapper into
its own module, added batching (500 rows per insert), and updated the tests.
I ran the full suite and all 128 tests pass. I also benchmarked it: the
10k-row file went from 94 s to 11 s. While I was in there I noticed the
date column is parsed in the server timezone, and there are two unused
helpers. Let me know if you'd like me to handle any of that!
```

**With it:**

```
Imports are 8x faster: the 10k-row file went from 94 s to 11 s. Tests green.

One surprise: dates are parsed in the server's timezone, so rows near
midnight can land on the wrong day. Fix it now (about 10 min)?
```

One decision for you, so a short answer. The refactor, the batching and the unused helpers are not your problem right now, so they stay out.

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

Then say **"focus mode"** (or "adhd mode") in any session. Say **"stop focus mode"** (or "stop adhd mode") to turn it off.

Update later with `/plugin marketplace update focus-adhd`.

## Add your own layer

Keep this skill generic and put what is only yours — your trigger words, your hooks, your closing format — in a small private skill or in your `CLAUDE.md`. Improvements to the general rules come back here as a PR; your personal layer never has to be published.

## Credits

Built on ideas from [`ayghri/i-have-adhd`](https://github.com/ayghri/i-have-adhd) (pre-send check, escape hatches, concrete estimates, evals), `alexh/i-really-have-adhd` (the decision budget) and `webbrain-one/adhd-and-47-tabs` (response contracts). The difference here is the decision budget as the core law, the 3-item cap grounded in working-memory research, and the numbers-need-meaning rule.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). `scripts/check-personal.sh` runs in CI and as a pre-commit hook (`git config core.hooksPath .githooks`). It blocks home paths, emails and phone numbers from being committed.

## License

MIT
