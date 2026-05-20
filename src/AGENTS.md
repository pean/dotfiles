# Git and Code Management

- Always remember to branch off work from main or master branch
- I want lines to break att 88 chars
- Keep PR descriptions very brief and do not just state the obvious, but rather explain
  the "why" behind the changes
- Never credit yourself in PR or commits.
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