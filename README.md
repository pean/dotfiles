# RCM Style Dotfiles

Dotfiles are managed by [RCM](https://github.com/thoughtbot/rcm) for macOS.

Clone to `~/.dotfiles`

## Essential Commands

### Installing/Managing Dotfiles
- `rcup` - Install/update dotfiles using RCM (reads rcrc configuration)
- `lsrc` - List what files would be linked by RCM
- `rcdn` - Remove symlinks created by RCM

Run `rcup` after adding or removing files; not needed for edits to existing files.

### System Updates
- `./updateeverything.fish` - Comprehensive update script that:
  - Updates Neovim plugins via Lazy.nvim
  - Updates Homebrew packages
  - Updates fish shell plugins via fisher
  - Updates tmux plugins
  - Updates mise-managed tools
  - Updates Python packages and pipx tools
  - Updates Mac App Store apps
  - Installs macOS system updates

### Development Environment
- `mise install` - Install language runtimes defined in config/mise/config.toml
- `fisher install` - Install fish shell plugins
- `~/.tmux/plugins/tpm/bin/install_plugins` - Install tmux plugins

## Repository Structure

### Core Configuration Files
- `vimrc` - Legacy Vim configuration (still used alongside Neovim)
- `tmux.conf` - tmux configuration with plugins and custom keybindings
- `gitconfig` - Git configuration with aliases and conditional includes
- `rcrc` - RCM configuration specifying exclusions

### Modern Configuration (config/)
- `config/nvim/` - Neovim configuration using Lazy.nvim plugin manager
  - `init.lua` - Main configuration entry point
  - `lua/plugins/lsp.lua` - LSP configuration with Mason for language servers
  - `lua/plugins/` - Individual plugin configurations
- `config/fish/` - Fish shell configuration and functions
- `config/mise/config.toml` - Runtime version management (Ruby 3.3.6, latest Rust/Python/Yarn)
- `config/starship.toml` - Shell prompt configuration
- `config/alacritty/`, `config/kitty/`, `config/ghostty/` - Terminal emulator configs

### Scripts
- `scripts/ruby-lsp-wrapper.sh` - Wrapper for Ruby LSP that handles different Ruby versions
  via mise
  - First tries `bundle exec ruby-lsp` if ruby-lsp is in Gemfile.lock
  - Falls back to `mise exec -- ruby-lsp` for project-specific Ruby versions
  - Auto-installs ruby-lsp gem if missing from the project's Ruby version
- `config/fish/functions/` - Fish shell custom functions (muxdev, t, vim, etc.)

## Development Tools Setup

### Language Servers (Neovim)
The LSP configuration automatically installs and configures:
- TypeScript/JavaScript (ts_ls)
- Ruby (ruby_lsp with custom wrapper)
- Lua (lua_ls)
- Rust (rust_analyzer)
- Web languages (CSS, HTML, JSON, YAML)

### Key Neovim Bindings
- Leader key: `,`
- `<leader>f` - Find files with fzf
- `<leader>g` - Ripgrep search
- `<leader>d` - Toggle NERDTree
- `gd` - Go to definition (LSP)
- `<space>ca` - Code actions (LSP)
- `<space>rn` - Rename symbol (LSP)

### tmux Configuration
- Uses catppuccin theme
- Plugin manager: TPM
- Key bindings for vim-tmux-navigator
- Custom session switching with fzf (`f` binding)

## Version Management

Uses `mise` (formerly rtx) for managing language versions:
- Ruby 3.3.6 (with idiomatic version file support)
- Latest versions of Rust, Python, Yarn

## Git Configuration

Features conditional includes for different work contexts:
- `~/.gitconfig-wa` - Personal/dotfiles projects
- `~/.gitconfig-hemnet` - Hemnet-specific config
- `~/.gitconfig-dreams` - Dreams-specific config
- `~/.gitconfig-snowfall` - Snowfall-specific config

SSH signing with 1Password integration is configured by default.

## Git Worktrees Pattern

Dual repository pattern for working on multiple branches simultaneously:

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

## Architecture Notes

- RCM manages dotfile symlinks from ~/.dotfiles to home directory
- Modern tools use XDG config directory structure (config/)
- Legacy tools still use dotfiles in home directory root
- Fish shell is the primary shell with custom functions and completions
- Neovim uses Lazy.nvim for modern plugin management
- Ruby LSP requires special wrapper script for mise compatibility
