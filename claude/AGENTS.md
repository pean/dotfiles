If there is no CLAUDE.md in the directory you are looking for it, look for AGENTS.md instead. Treat those files as equivalents.

# Git and Code Management

- Always remember to branch off work from main or master branch
- I want lines to break att 88 chars
- Keep PR descriptions very brief and do not just state the obvious, but rather explain the "why" behind the changes
- Never credit yourself in PR or commits.
- Never leave trailing whitespace nor empty line at the end of the file
- Only commit code when I ask for it
- Only push code to remote when I ask for it
- Respect changes made by me in files being worked on and do not overwrite without at least asking
- Respect styles rules from rubocop, eslint etc
- Some repositories have pull request template, use it when available, located in `.github/pull_request_template.md`
- When creating pull requests, always create as draft and assign me
- When referring to other pulls requests in pr description, try to add the PR url in a list item
- do not leave empty rows behind when removing code
- use conventional commit messages and pull request titles
- Do not use name or username in branch names
- When creating branches, use the format `type/description` (e.g., `feature/login`, `bugfix/payment`, `chore/update-deps`)
- If there is linear or jira reference, put reference in branch name (e.g., `feature/login-LIN-123/`, `bugfix/payment-JIRA-456`)
- Use worktree pattern when starting up new work

## Git Worktrees Pattern

I use a dual repository pattern for projects where I want to work on multiple branches simultaneously:

**Repository Structure:**
- `~/src/getdreams/repo-name/` - Main repository, always kept on main/master branch
- `~/src/getdreams/repo-name.git/` - Bare repository with worktrees for feature branches

**Worktree Organization:**
- The `.git` suffix indicates a bare repository containing worktrees
- Each worktree is a subdirectory directly in the root (no `wt/` nesting)
- Example structure:
  ```
  ~/src/getdreams/repo-name.git/
  ├── HEAD, config, objects/, refs/  # bare repo metadata
  ├── main/                          # main branch worktree
  ├── feature-login/                 # feature branch worktree
  └── bugfix-payment/                # bugfix branch worktree
  ```

**When to Use Worktrees:**
- **ALWAYS ASK** before setting up worktrees unless I explicitly request it
- Use worktrees when working on multiple branches simultaneously
- Use regular repo (without `.git` suffix) for single-branch workflow
- The `tw` fish function handles tmux sessions for worktrees

**Setting Up Worktrees:**
```bash
# Convert existing repo to bare + worktrees pattern
cd ~/src/getdreams/repo-name
git clone --bare . ../repo-name.git
cd ../repo-name.git
git worktree add main main
git worktree add feature-name feature-name
```

**Working with Worktrees:**
- Use `tw repo-name` to interactively select and switch to a worktree tmux session
- Use `tw repo-name branch-name` to directly switch to a specific worktree
- Each worktree gets its own tmux session named `repo-name/branch-name`

# Personal Information

- GitHub username: pean
