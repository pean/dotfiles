If there is no CLAUDE.md in the directory you are looking for it, look for AGENTS.md instead. Treat those files as equivalents.

# Available Tools

You get access to a wide array of MCP tools to help you working with code. Notable ones that you should use often are:

- `Serena` - A powerful coding agent toolkit providing semantic retrieval and editing capabilities. Helps you navigate, understand and modify code
- `Context7` - pulls up-to-date, version-specific documentation and code examples straight from the source
- `Memory` - Knowledge graph-based persistent memory system
- `Sequential Thinking` - Dynamic and reflective problem-solving through a structured thinking process

Use those tools to structure the way you work with codebase

# Knowledge Graph System

A comprehensive knowledge graph has been established to track all projects, their relationships, and architectural patterns across the `/Users/peter/src` directory. This creates a persistent understanding of the entire development ecosystem, including work projects, personal projects, and high-level infrastructure patterns.

## Using the Knowledge Graph

### When to Query

- **Before starting work** on any Dreams service (check dependencies)
- **Planning integrations** between services (understand existing patterns)
- **Debugging issues** (check service relationships and data flow)
- **Understanding system architecture** when working across multiple services

# Git and Code Management

- Some repositories have pull request template, use it when available, located in `.github/pull_request_template.md`
- When creating pull requests, always create as draft and assign me
- Never credit claude code in PR or commits.
- Always remember to branch off work from main or master branch
- Never leave trailing whitespace nor empty line at the end of the file
- Keep PR descriptions very brief and do not just the obvious.
- use conventional commit messages
- do not leave empty rows behind when removing code

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

# Lokalise Translation Management

When adding new translation keys to projects that use Lokalise:

1. **Create Upload Files**: Generate separate JSON files for each language containing only the new keys
   - Format: `lokalise-upload-{lang}.json` (e.g., `lokalise-upload-en.json`)
   - Include only the new translation keys that need to be uploaded
   - Use proper JSON format with key-value pairs
   - Empty strings for missing translations are acceptable

2. **File Structure**:
   ```json
   {
     "app.section.component.key": "Translation value",
     "app.section.component.anotherKey": "Another translation"
   }
   ```

3. **Supported Formats**: Lokalise supports JSON, XML, YAML, Excel for key-based projects
   - JSON is the standard format for web projects
   - Lokalise auto-detects language codes in filenames (e.g., `%LANG_ISO%.json`)

4. **Reference**: https://docs.lokalise.com/en/articles/1400492-uploading-translation-files

# Personal Information

- GitHub username: pean

- never credit claude code in pr, commits etc
- when working with ruby always make sure to follow rubocop rules
- Respect changes made by me in files being worked on and do not overwrite without at least asking
- anything you learn about working in repositories in /Users/pean/src/getdreams, store that in a shared CLAUDE.md in /Users/pean/src/getdreams so it can be used as reference when working in multiple repositories
- I want lines to break att 88 chars
- Respect styles rules from rubocop, eslint etc
- When referring to other pulls requests in pr description, tryo t add the PR url in a list item
- Only commit code when I ask for it
- Only push code to remove when I ask for it