---
name: summarize-for-others
description: Rewrite prose meant for other readers — docs, READMEs, PR descriptions, release notes, summaries — into short, plain-English sentences. Never applies to code. STE-flavored (ASD-STE100-inspired), not the strict aerospace dictionary.
---

## What I do

Rewrite text intended for other people to read — not code, not messages back
to the user themself — into short, plain sentences that read as human, not
AI-generated filler. Loosely based on ASD-STE100 (Simplified Technical
English), in flavored mode only: modern everyday words are fine, but
sentence and paragraph discipline is strict.

Applies to: documentation, READMEs, PR descriptions, release notes, error
messages shown to users, comments meant for other engineers. Does not apply
to code, identifiers, or command syntax. Not for marketing copy — this
strips voice on purpose.

## Rules

**One idea per sentence.** Max ~20 words for an instruction, ~25 for
descriptive text. If a condition precedes a command, separate with a comma:
"If the test fails, read the log."

**Active voice.** "The parser reads the file," not "the file is read by the
parser." Passive is fine only when the actor is unknown or irrelevant. A
past participle as an adjective isn't passive: "the field is required" is
correct as-is.

**Simple tenses only.** Imperative, simple present, simple past, simple
future. No present perfect: "we received the report," never "we have
received the report." No stacked auxiliaries: not "it is important to note
that this may help to improve," just "this improves X."

**Verbs for actions, not nouns.** "Analyze the log," not "perform an
analysis of the log." No "-ing" main verb where a simple tense works. No
phrasal verbs: not "spin up," "dive into," "kick off," "roll out" — say
what actually happens.

**No semicolons.** Write two sentences instead.

**Multi-word nouns: max three words.** Unpack "the agent task queue priority
handler" into "the handler that sets task-queue priority."

**One name per thing.** Don't rotate check/verify/validate/confirm for the
same action — pick one, reuse it.

**No marketing adjectives.** Cut seamless, robust, powerful, cutting-edge,
effortless, world-class, next-generation, revolutionary.

**Define abbreviations at first use**, then use the abbreviation.

**One topic per paragraph, max six sentences.** Steps go in a numbered list,
one action per item, imperative form, condition before command.

## Common swaps

The ones that actually show up in software prose:

| Instead of | Write |
|---|---|
| ensure | make sure |
| however | but |
| therefore | thus / as a result |
| since (causal) | because — "since" is ambiguous (time or cause) |
| may | can (permission) |
| should / shall | must (if not optional) |
| perform an analysis | analyze |
| using the CLI, run... | run... with the CLI |

## Guards

- Never drop a fact, number, condition, or scope qualifier to hit a length
  cap — keep the longer sentence and flag it instead.
- Preserve code identifiers, error strings, and exact values verbatim.
- Change only the smallest span that fixes a violation — don't restyle text
  a rule doesn't touch.
- If the input already complies, return it unchanged and say so.
- Output only the requested text — no preamble, no summary of what changed.

## Modes

Three ways to use this:
- **write** — produce new text directly in this style.
- **rewrite** — convert existing text, keeping every fact.
- **review** — don't rewrite. Output a table (`Rule | Original | Simplified`),
  one row per violation, then one line on anything left alone and why.

## Verify

If a shell is available, lint the draft:

```
python3 ste-lint.py draft.md
```

Target: under 2.5 flagged issues per 100 words. Fix reported categories and
re-lint once or twice, then report the final score alongside the text. Don't
claim a draft is clean without running it.

Without shell access, self-check: any sentence over ~20-25 words? Any
semicolon or contraction? Any "has/have done" or modal stack? Any passive
voice with a known actor? Any noun cluster of 4+ words? Same thing named two
different ways? Fix each before sending.
