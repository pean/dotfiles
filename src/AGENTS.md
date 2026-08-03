# Git and Code Management

- Always remember to branch off work from main or master branch
- I want lines to break att 88 chars
- Keep PR descriptions very brief and do not just state the obvious, but rather explain
  the "why" behind the changes
- Never add `Co-Authored-By` trailers to commits (for any tool, model, or agent).
- Never add AI-generated footers (e.g. "🤖 Generated with Claude Code") to PR descriptions.
- Never leave trailing whitespace nor empty line at the end of the file
- Only commit code when I ask for it
- Only push code to remote when I ask for it
- Some repositories have pull request template, use it when available, located in
  `.github/pull_request_template.md`
- When creating pull requests, always create as draft and assign me
- When referring to other pulls requests in pr description, try to add the PR url in a
  list item
- do not leave empty rows behind when removing code
- use conventional commit messages and pull request titles
- Do not use name or username in branch names
- When creating branches, use the format `type/description` (e.g., `feature/login`,
  `bugfix/payment`, `chore/update-deps`)
- If there is linear or jira reference, put reference in branch name (e.g.,
  `feature/login-LIN-123/`, `bugfix/payment-JIRA-456`)
- Always use the worktree pattern when starting new work

## Coding Behaviour

### Code Style

- Default to no comments in code. Only add one when the *why* is non-obvious — a
  hidden constraint, a subtle invariant, a workaround for a specific bug. If removing
  the comment wouldn't confuse a future reader, don't write it.
- Before writing code, check for linter/formatter config files (`.rubocop.yml`,
  `.standard.yml`, `.eslintrc*`, `biome.json`, etc.) to understand project rules.
- After making changes, run the linter and fix all violations before considering the
  task done. Never present code with known linting errors.

### Think Before Coding

- State assumptions explicitly before implementing. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop and name what's confusing before proceeding.

### Simplicity First

- Write the minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" that wasn't requested.
- If it could be half the size, rewrite it.

### Confirm Before Destructive Actions

- Before deleting files, overwriting existing code, dropping database records, or
  removing dependencies: stop, list exactly what will be affected, and wait for explicit
  confirmation before proceeding.
- Hard stops — always require explicit in-session confirmation, no exceptions: deploying
  or pushing to any environment, running migrations or schema changes, executing any
  command with irreversible side effects.

### Surgical Changes

- Touch only what the task requires. Don't improve adjacent code.
- Don't refactor things that aren't broken.
- Match existing style even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that *your* changes made unused,
  but leave pre-existing dead code alone.

## Git Worktrees Pattern

I use a bare repo + worktrees pattern for all projects:

- `~/src/<org>/repo-name/` — main repo, always on main/master
- `~/src/<org>/repo-name.git/` — bare repo; each branch is a subdirectory worktree
  ```
  repo-name.git/
  ├── main/
  ├── feature-login/
  └── bugfix-payment/
  ```
- The `tw` fish function manages tmux sessions per worktree (`repo-name/branch-name`)
- To create a new worktree for a branch, always use the Twine CLI — never raw
  `git worktree add`:
  ```
  twine worktree --create <repo> <branch>
  # or: tw -c <repo> <branch>
  ```
- The worktree directory name is derived from the branch name by Twine. Never
  specify a path that diverges from the branch name — `tw repo/branch` session
  switching depends on them matching.

## Stacked Pull Requests

A stack is a chain of branches/PRs where each one is based on the layer below it,
letting a large change be reviewed and merged as independent, ordered pieces
instead of one big PR. Manage stacks with the `gh stack` CLI (`github/gh-stack`
extension) — never construct stacked branches/PRs by hand.

Core commands:
- `gh stack init <branch>` — start a stack (or adopt existing branches) off the
  default branch
- `gh stack add -Am "<msg>" <branch>` — add a layer on top with a commit
- `gh stack submit` — push all branches, create/update PRs, link them as a stack
- `gh stack sync` — fetch, cascade-rebase, push, and resync PR state; run this
  before resuming work on a stack or before merging
- `gh stack rebase` — cascading rebase only, without the push/sync (`--continue`/
  `--abort` for conflicts)
- `gh stack modify` — reorder/drop/fold/insert/rename layers via an interactive TUI
- `gh stack merge` — atomic merge up to a chosen layer, respecting merge queues
- Navigation: `gh stack top` / `bottom` / `up` / `down` / `switch` / `trunk` /
  `view`

### Worktree mapping: one worktree per stack

Use a single Twine worktree for the whole stack, not one per layer:

- `twine worktree --create <repo> <bottom-branch>`, then `gh stack init` from
  inside it.
- Default to the **top-of-stack checkout** for all work. Each layer branch is
  built on top of the one below it — normal git history, not an independent
  diff — so the top branch's working tree already contains every layer's
  changes combined. `gh stack add` leaves you on the new top layer
  automatically; run builds, tests, and the app against this checkout.
- To fix or review one specific lower layer: `gh stack down`/`switch` to it,
  commit the change, then `gh stack sync` (or `rebase`) to cascade it upward,
  then `gh stack top` to return to the default working checkout. Treat this as
  a targeted detour — `up`/`down`/`switch` are not general-purpose navigation,
  the top checkout is where work normally happens.
- Never create a separate Twine worktree per layer. That fragments gh-stack's
  local branch tracking across checkouts, so `sync`/`rebase` run in one
  worktree won't be reflected in the others.
- This is the one deliberate exception to "the worktree directory name matches
  the branch name": a stack's worktree is keyed off the bottom branch (or a
  stack-level name), and layer branches are checked out inside it via
  `gh stack`, not via separate `twine worktree` calls.

All the usual conventions still apply — branch naming (`type/description`),
conventional commit/PR titles, draft PRs assigned to `pean`, no
Co-Authored-By/AI footers. A stack is just multiple PRs instead of one.