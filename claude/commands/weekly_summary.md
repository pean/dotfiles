Generate a summary of my git commits from the past week across all repositories in this directory.

## Search Strategy

1. Find all git repositories in the current directory structure:
   - Regular repos: directories with `.git` subdirectory
   - Bare repos with worktrees: directories ending in `.git/` containing worktree subdirectories
   - For bare repos: search commits in each worktree subdirectory (e.g., `repo.git/main/`, `repo.git/feature-branch/`)

2. Find commits by author `peter.andersson@getdreams.com` from the last 7 days
   - Use `git log --all --author="peter.andersson@getdreams.com" --since="7 days ago"`
   - Include both regular repos and all worktree directories

3. Group by common themes (not by repository or branch)
4. Write brief narrative summaries with emoji headlines

Keep it concise — 2-3 sentences per theme.

