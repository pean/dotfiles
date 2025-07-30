# Agent Configuration Notes

## System Information
- **Shell**: Fish shell
- **Ruby Version Manager**: mise
- **Operating System**: macOS (darwin 15.6) on arm64

## LSP Configuration Issues & Solutions

### Ruby LSP with Mise Multi-Version Setup

**Problem**: Ruby LSP crashes with `Bundler::GemNotFound` errors when using mise to manage multiple Ruby versions. Native extensions (`rbs`, `prism`) fail to load properly across different Ruby versions.

**Root Cause**: 
- Ruby LSP tries to create custom bundles that conflict with mise
- Native extensions need recompilation for each Ruby version
- Bundler lockfile conflicts between Ruby versions

**Solution Applied**:

1. **Disabled Ruby LSP Custom Bundle**: Modified `/Users/peter/.dotfiles/config/nvim/lua/plugins/lsp.lua` to set `customBundleGemfile = ""` in `init_options`

2. **Created Fish Shell Wrapper**: `/Users/peter/.dotfiles/scripts/ruby-lsp-wrapper.sh`
   ```fish
   #!/usr/bin/env fish
   # Ruby LSP wrapper for mise compatibility with fish shell
   
   set -x PATH $HOME/.local/bin $PATH
   mise activate fish | source
   exec ruby-lsp $argv
   ```

3. **Updated LSP Command**: Changed `cmd` in Ruby LSP config to use wrapper script

**Required Manual Steps for Each Ruby Version**:
```fish
# Install native extensions for each Ruby version
mise use ruby@3.4.5
gem install rbs prism ruby-lsp --force

mise use ruby@3.3.4  
gem install rbs prism ruby-lsp --force
```

**Testing Commands**:
```fish
cd /Users/peter/src/getdreams/dreams-registry
mise install
mise current
nvim some_file.rb
```

## Development Environment

### Frequently Used Commands
- **LSP Logs**: Check `/Users/peter/.local/state/nvim/lsp.log` for crashes
- **Mason Management**: `:Mason` in Neovim to manage LSP servers
- **Ruby Version Check**: `mise current` or `ruby --version`

### File Locations
- **Neovim Config**: `/Users/peter/.dotfiles/config/nvim/`
- **LSP Config**: `/Users/peter/.dotfiles/config/nvim/lua/plugins/lsp.lua`
- **Ruby LSP Wrapper**: `/Users/peter/.dotfiles/scripts/ruby-lsp-wrapper.sh`

## User Preferences
- **Minimal plugins**: Prefers built-in Neovim features over heavy plugins
- **Multi-language support**: Ruby, TypeScript/JavaScript, Rust, CSS, HTML, JSON, YAML
- **Auto-formatting**: Especially for TypeScript/JavaScript and React/Next.js projects
- **Modern tooling**: Uses Mason for LSP management, conform.nvim for formatting

## Known Issues
- Ruby LSP requires native extensions to be installed for each Ruby version managed by mise
- Copilot.vim can cause memory leak warnings (MaxListenersExceeded) but doesn't affect core LSP functionality
