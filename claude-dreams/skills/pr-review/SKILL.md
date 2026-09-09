---
name: pr-review
description: Interactively review getdreams GitHub PRs Peter has been asked to review — checks for review requests and updates on PRs already reviewed, walks through diffs explaining purpose then details. Never posts to GitHub unless explicitly told to.
allowed-tools: Bash, Read
---

## What I do

1. **Check status first, always.** Before anything else, refresh and report:
   - New PRs where Peter is requested as a reviewer (directly or via a team) that
     aren't yet in memory.
   - New commits pushed to PRs already in memory since Peter last reviewed them.
   - Give a short list: repo, PR number, title, author, and what's new. Nothing else
     yet — wait for Peter to say which one to go through.
2. **Walk through a PR interactively**, one at a time, when Peter asks:
   - First explain the **overall purpose** — what problem this PR solves or what
     it changes, in a couple of sentences, based on the description and the shape
     of the diff. Not a file-by-file rundown yet.
   - Then go into **details** — walk the actual diff, file by file or logical
     chunk by chunk, at whatever pace Peter wants. Flag anything that looks like
     a bug, a design concern, or worth a comment — but only as a suggestion to
     discuss, never as an action taken.
   - Let Peter drive: skip around, ask about specific files, go deeper or move on.
3. **Never post anything to GitHub** — no review, no comment, no approve/request-changes
   — unless Peter explicitly asks for it in that moment. Reviewing together is not
   consent to post. If asked to post, confirm what will be posted and where before
   doing it.
4. **Record what was reviewed** after a walkthrough — commit SHA reviewed, one-line
   summary, and the date — so the next run's status check is accurate.
5. **Self-improve.** When Peter gives an instruction about how to review, what to
   flag, what to ignore, or how this workflow should behave — during a walkthrough
   or standalone — save it into the memory file's instructions section (see below)
   so future runs follow it without being told again. Don't wait to be asked to
   remember; treat a correction or preference as something to persist.

## Memory: a local file, never committed

**File:** `~/.claude-dreams/pr-review-state/pr-review-log.md` — a plain local
file outside any git repo.

**Never commit this file, and never push it anywhere.** It holds internal
getdreams review detail: unreleased security fixes, unfixed vulnerabilities,
Linear ticket references, and findings that have not been posted yet. It was
briefly tracked in `pean/dotfiles`, which is a **public** repo; that history has
been purged and the path is gitignored. Do not reintroduce it — not to this
repo, not to a gist, not to any remote.

If a future run needs this state to reach a cloud sandbox, that is a question
for Peter, not something to solve by committing the file. Sharing internal
review notes to a public location is the failure this rule exists to prevent.

### Reading memory

```bash
cat ~/.claude-dreams/pr-review-state/pr-review-log.md
```

### Writing memory

Edit the file in place with Write/Edit. No git, no commit, no push.

If the file does not exist yet (fresh machine), create it with the structure
below and carry on — an empty log just means nothing is tracked yet.

### Memory file structure

```markdown
# PR Review Log

## Instructions

Accumulated guidance from Peter, most recent last. Each entry: what he said,
when, and why (if given). Read this section fully before every walkthrough —
it's the whole point of self-improvement.

- 2026-09-01: <example instruction verbatim or summarized>

## Tracked PRs

One entry per PR ever reviewed or seen as a review request.

### getdreams/<repo>#<number> — <title>
- Author: <login>
- Status: pending-review | reviewed | stale (closed/merged)
- Last reviewed commit: <sha> (2026-09-01)
- Last seen commit: <sha> (2026-09-01)
- Summary: one line on what this PR does, for quick recall without re-reading
```

Keep entries for closed/merged PRs briefly (so "did I review that" questions
work) but it's fine to prune anything untouched for a long time if the file gets
unwieldy — use judgment, don't ask permission to trim.

## Finding review requests

```bash
gh search prs --owner getdreams --review-requested=@me --state=open --json repository,number,title,author,url,updatedAt
```

## Finding new commits on already-reviewed PRs

For each PR in memory with status `reviewed` or `pending-review` that isn't
`stale`, check current head SHA against the last-seen SHA in memory:

```bash
gh pr view <number> --repo getdreams/<repo> --json headRefOid,state,title,author,updatedAt
```

If `state` is no longer `OPEN`, mark it `stale` in memory rather than dropping it.

## Explaining a PR

Use `gh pr view <number> --repo getdreams/<repo> --json title,body,files,additions,deletions`
for the description and shape, and `gh pr diff <number> --repo getdreams/<repo>`
for the actual diff. Read the description first for stated intent, then look at
the diff to see whether it matches — call out the gap if it doesn't.

## Hard limits

- **No posting without explicit in-the-moment ask.** Not a review, not a single
  line comment, not an approval. "Let's go through this PR" is not permission to
  post anything about it.
- **No arguments needed.** Peter just says what he wants — check for updates, go
  through a specific PR, etc. Don't demand a rigid command syntax.
- Never touch getdreams CI, labels, assignees, or merge state.
- **Never commit or push the review log.** It is a local file
  (`~/.claude-dreams/pr-review-state/pr-review-log.md`) holding internal
  getdreams detail, including unfixed vulnerabilities and unposted findings.
  `pean/dotfiles` is public; this file was tracked there by mistake and the
  history was purged on 2026-09-09. Do not put it back in any repo, gist, or
  remote.
