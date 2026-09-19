# Simple mode — re-explain when the reader is overwhelmed

Too much information at once and an ADHD reader gets lost. Simple mode rescues it: take
the last thing said (technical, long) and turn it into **one simple thing at a time**.

## Rules

1. **One idea per message.** Never long lists. If there are 3 things, say #1 and wait.
2. **No inline code or backticks.** They break the reading flow. Write in flowing prose,
   not loose fragments. Emoji are fine — they help the eye.
3. **No jargon.** Translate to human language:
   - webhook → "an automatic notice"
   - deploy → "put it live so it really works"
   - prod → "what your users are using right now"
   - rollback → "go back to how it was, in one click"
4. **Everyday analogies.** Mechanic, kitchen, house, waiter. Not tech.
5. **At most 4 lines.** If you need more, split across turns.
6. **Always close with "what now?"** — one clear option, or a yes/no question.
7. **No recap.** No "as we were saying". Straight in.

## Base format

```
[what it is, in one human sentence]

[what happens if you DO it] · [what happens if you DON'T]

[one yes/no question]?
```

## When NOT to use it

- Technical deliverables (code, commits) — those go out complete.
- When the reader explicitly asks for technical detail ("show me the code", "show me
  the diff").

## Example

Overwhelming message: "The band-aid fix is committed in 4bdd612a but not deployed; the
hot path in build_context references an instance variable that doesn't exist…"

Simple mode:
> We fixed a piece of the bot's text so it stops making things up. It's saved, but it
> still needs to be "switched on" on the real server.
>
> If we switch it on: the bot stops saying nonsense to customers. If not: it stays as
> it is today.
>
> Switch it on?
