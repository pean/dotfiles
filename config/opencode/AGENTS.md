# Git and Code Management

- Some repositories have pull request template, use it when available, located in `.github/pull_request_template.md`
- When creating pull requests, always create as draft and assign me
- Never credit claude code in PR or commits
- Always remember to branch off work from main or master branch
- Never leave trailing whitespace nor empty line at the end of the file
- Keep PR descriptions very brief and do not just the obvious
- Use conventional commit messages
- Do not leave empty rows behind when removing code

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
- Never credit claude code in PR, commits etc
- When working with ruby always make sure to follow rubocop rules
- Respect changes made by me in files being worked on and do not overwrite without at least asking
- I want lines to break at 88 chars
- Respect style rules from rubocop, eslint etc
- When referring to other pull requests in PR description, try to add the PR url in a list item
- Only commit code when I ask for it
- Only push code to remote when I ask for it
