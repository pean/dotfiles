---
name: deploy-to-staging
description: Merges a feature branch into develop and pushes for one or more repos
disable-model-invocation: true
allowed-tools: Bash
---

## What I do

Deploy a feature branch to staging by merging it into `develop` and pushing for
one or more repos. Each repo uses the worktree pattern at
`~/src/getdreams/<repo>.git/develop/`.

## Usage

```
/deploy-to-staging <repo1> [repo2] ...
```

Example:
```
/deploy-to-staging dreams-registry dreams-web-app
```

## Steps

### 1. Detect branch

Run:
```bash
git branch --show-current
```
from the current working directory (`pwd`).

- If a branch name is returned, use it
- If the result is empty (detached HEAD) or the directory is not a git repo,
  ask the user to provide the branch name explicitly before continuing

### 2. Confirm

Show the user a summary and ask for confirmation before doing anything:

```
About to merge `<branch>` into `develop` for: <repo1>, <repo2>
Proceed? (yes/no)
```

Stop immediately if the answer is not yes.

### 3. For each repo

Repo worktree root: `~/src/getdreams/<repo>.git/`
Develop worktree path: `~/src/getdreams/<repo>.git/develop/`

**a) Ensure develop worktree exists**

Check if the `develop/` directory exists inside the bare repo:
```bash
ls ~/src/getdreams/<repo>.git/develop
```

If it does not exist, add it:
```bash
git -C ~/src/getdreams/<repo>.git worktree add develop develop 2>/dev/null \
  || git -C ~/src/getdreams/<repo>.git worktree add develop -b develop origin/develop
```

**b) Sync develop with origin**

```bash
git -C ~/src/getdreams/<repo>.git/develop fetch origin
git -C ~/src/getdreams/<repo>.git/develop reset --hard origin/develop
```

**c) Merge the feature branch**

```bash
git -C ~/src/getdreams/<repo>.git/develop merge --no-ff <branch>
```

If the merge fails (conflicts or branch not found), report the error and stop
for this repo. Do not proceed to push.

**d) Push to origin**

```bash
git -C ~/src/getdreams/<repo>.git/develop push origin develop
```

If the push is rejected:
- Show the exact error output
- Explain that the most likely fix is to reset `develop` to `origin/develop`
  and re-merge (steps b and c above)
- Ask: "Push was rejected. Reset develop to origin/develop and retry the
  merge+push? (yes/no / force-push)"
- If yes: repeat steps b and c, then push again
- If force-push: run `git push --force-with-lease origin develop`
- If no: skip this repo and continue with the next

### 4. Report

After processing all repos, print a summary:
- Which repos were successfully pushed
- Which repos were skipped or failed, and why
