---
name: commit
description: Commit staged/unstaged changes and optionally create a PR. Groups changes into isolated standalone commits when multiple concerns are present.
allowed-tools: Bash, Read
---

## What I do

Commit changes on the current branch and optionally push and open a pull request.
I analyze all pending changes, group them by concern, and produce isolated standalone
commits — one logical change per commit. If everything belongs together, one commit.

## Usage

```
/commit                   → commit only
/commit and pr            → commit, push, create PR
/commit and create pr     → same as above
/pr                       → push and create PR (skip commit step)
/pr only                  → same as above
```

If working across multiple repos, say so:
```
/commit and pr dreams-web-api dreams-web-app
```

## Rules

- Never commit directly to `main`, `master`, or `develop`
- Never credit yourself in commits or PRs
- Conventional Commits format for both commit messages and PR titles
- Each commit must be isolated and standalone: it should make sense on its own,
  pass CI on its own, and not bundle unrelated changes
- Split changes into multiple commits when they touch different concerns
  (e.g. a bug fix and a refactor should never be one commit)
- Never add unrelated files to a commit just because they happen to be dirty
- PR descriptions: explain the *why*, not what changed line by line — no iterations,
  no test coverage mentions
- Use the PR template from `.github/pull_request_template.md` if it exists
- Create PRs as draft and assign `pean`
- Multi-repo: commit/push/PR each repo separately, then cross-link the PRs

## Steps

### 1. Parse intent from args

Determine what to do:
- **commit only** — default when no PR-related words in args
- **PR only** — args contain `pr only`, `only pr`, or `/pr` was invoked directly
- **commit + PR** — args contain `and pr`, `and create pr`, `create pr`, `pr`

If repos are named in args, scope all steps to those repos. Otherwise operate on
the current working directory.

### 2. Check branch safety

```bash
git branch --show-current
```

If the current branch is `main`, `master`, or `develop`:
- Refuse to commit and tell the user to create a feature branch first

### 3. Commit (skip if PR-only)

**a) Assess all pending changes**

```bash
git status --short
git diff --stat HEAD
```

If there is nothing to commit, skip this step and say so.

**b) Read and understand the changes**

Read every changed file. Understand what each change does before deciding
how to group them. Do not write commit messages before understanding the full diff.

**c) Group changes into logical commits**

Identify distinct concerns across the changed files. A concern is a single
self-contained reason for a change. Examples of things that must be separate commits:
- A bug fix vs. a refactor vs. a new feature
- Changes to unrelated parts of the codebase that happen to be in the same diff
- Config/tooling changes vs. application logic changes
- Dependency updates vs. code that uses the new dependency

If all changes belong to one concern: one commit.
If changes span multiple concerns: plan a sequence of commits, ordered so each
builds cleanly on the previous one.

Present the plan to the user before committing if more than one commit will be made:
```
I'll make 2 commits:
1. fix(auth): correct token expiry check
2. chore(deps): bump devise to 4.9.3
Proceed?
```

**d) Stage and commit each group**

For each commit in the plan, stage only the relevant files/hunks:

```bash
git add <specific-files>
# or for partial file staging
git add -p <file>
```

Then commit:
```bash
git commit -m "<type>(<scope>): <short description>"
```

Subject line: under 72 characters. Add a body only when the *why* is non-obvious.
Never use `--no-verify`. If a pre-commit hook fails, fix the underlying issue before retrying.

### 4. Push + PR (skip if commit-only)

**a) Push the branch**

```bash
git push -u origin <branch>
```

If push is rejected (non-fast-forward), tell the user and stop — do not force push
without explicit instruction.

**b) Check for PR template**

```bash
cat .github/pull_request_template.md 2>/dev/null
```

**c) Create the PR**

The PR title describes the overall goal of the branch, not one individual commit.
Use Conventional Commits format.

```bash
gh pr create \
  --title "<conventional-commits-title>" \
  --body "..." \
  --draft \
  --assignee pean
```

PR body guidelines:
- Follow the template if one exists
- Brief: 2–5 bullet points on *why* this change was made
- Include a `## Related PRs` section if you know of any, with URLs
- No "what I did step by step", no test coverage commentary

**d) Multi-repo cross-linking**

After all PRs are created, edit each PR body to add the others under `## Related PRs`.

### 5. Report

Print a short summary:
- Each commit SHA and message (if committed)
- PR URL (if created)
- Any repos skipped and why
