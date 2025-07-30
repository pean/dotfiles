# Agent Guidelines for Dotfiles Repository

## Build/Test Commands
- No traditional build system - this is a dotfiles repository
- Update all tools: `fish updateeverything.fish`
- Install packages: `brew bundle` (from Brewfile)
- Single script test: `fish <script-name>.fish`

## Code Style Guidelines

### Fish Shell Scripts
- Use lowercase with underscores for function names
- 2-space indentation (matches nvim config)
- Set variables with `set -x` for exports, `set -g` for global
- Use descriptive variable names
- No trailing whitespace (nvim shows with listchars)

### Bash Scripts
- Use `#!/usr/bin/env bash` or `#!/opt/homebrew/bin/fish` shebang
- Follow existing variable naming in bash_it themes
- Use `${variable}` syntax for expansions
- 2-space indentation

### Configuration Files
- YAML/TOML: 2-space indentation
- Use lowercase with hyphens for keys where possible
- Follow existing patterns in alacritty.toml, starship.toml
- Comment configuration sections clearly