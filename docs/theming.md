# Theme System

A unified Catppuccin theme system for the entire dotfiles setup supporting all
four flavors. All colors live in a single palette file; a generator script
produces tool-specific theme files, and a fish function switches flavors at once.

| Flavor | Style | macOS appearance |
|--------|-------|-----------------|
| `mocha` | Darkest | Dark |
| `macchiato` | Dark | Dark |
| `frappe` | Medium | Dark |
| `latte` | Light | Light |

## Quick reference

```bash
# Toggle between current flavor and latte (or back to mocha)
theme-toggle

# Switch to a specific flavor
theme-toggle mocha
theme-toggle macchiato
theme-toggle frappe
theme-toggle latte

# Re-apply current flavor and regenerate all theme files
theme-toggle --force

# Only flip macOS appearance (Ghostty follows; other tools untouched)
theme-toggle --macos

# Skip macOS appearance flip (toggle terminal tools only)
theme-toggle --terminal

# Edit colors, then regenerate all theme files
vim ~/.dotfiles/theme-palette.conf
./scripts/generate-themes.sh
```

## Architecture

```
theme-palette.conf          <- single source of truth (4 flavor sections)
        |
  generate-themes.sh        <- reads palette, writes 4 files per tool
        |
  +-----+-----+-- ... tool-specific theme files (per flavor)
  |     |     |
ghostty tmux  fish  (and more)

~/.config/theme             <- state file (flavor name: mocha/macchiato/frappe/latte)
        |
  theme-toggle.fish         <- swaps symlinks + env vars, reloads apps
```

### Why symlinks, not sed

RCM manages dotfiles as symlinks (`~/.config/foo` -> `~/.dotfiles/config/foo`).
BSD `sed -i` refuses to edit through symlinks, and file-content toggling creates
noisy git diffs. Instead, each tool's config imports a `current-theme.*` symlink
that the toggle function swaps between dark and light variants.

## Palette file

`theme-palette.conf` at the repository root. Format:

```
[mocha]
base=#1e1e2e
text=#cdd6f4

[latte]
base=#eff1f5
text=#4c4f69
```

Rules:

- Lines starting with `#` are comments
- Values use `#` prefix so Neovim color-preview plugins can highlight them
- The generator strips the `#` before use
- Inline comments require a preceding space (`value #comment`)
- File must end with a newline (parser requirement)

### Palette keys (per flavor)

Colors follow the [Catppuccin style guide](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md)
semantic roles. All four flavors share the same key names.

| Key | Mocha | Macchiato | Frappé | Latte | Role |
|-----|-------|-----------|--------|-------|------|
| `base` | #1e1e2e | #24273a | #303446 | #eff1f5 | Main background |
| `mantle` | #181825 | #1e2030 | #292c3c | #e6e9ef | Secondary background |
| `crust` | #11111b | #181926 | #232634 | #dce0e8 | Deepest background |
| `surface0` | #313244 | #363a4f | #414559 | #ccd0da | Surface / selection |
| `surface1` | #45475a | #494d64 | #51576d | #bcc0cc | Surface raised |
| `surface2` | #585b70 | #5b6078 | #626880 | #acb0be | Surface raised (2) |
| `overlay0` | #6c7086 | #6e738d | #737994 | #9ca0b0 | Muted UI / comments |
| `overlay1` | #7f849c | #8087a2 | #838ba7 | #8c8fa1 | Overlay text |
| `overlay2` | #9399b2 | #939ab7 | #949cbb | #7c7f93 | Overlay text bright |
| `subtext0` | #a6adc8 | #a5adcb | #a5adce | #6c6f85 | Dim foreground |
| `subtext1` | #bac2de | #b8c0e0 | #b5bfe2 | #5c5f77 | Secondary foreground |
| `text` | #cdd6f4 | #cad3f5 | #c6d0f5 | #4c4f69 | Main foreground |
| `rosewater` | #f5e0dc | #f4dbd6 | #f2d5cf | #dc8a78 | Cursor |
| `flamingo` | #f2cdcd | #f0c6c6 | #eebebe | #dd7878 | — |
| `pink` | #f5c2e7 | #f5bde6 | #f4b8e4 | #ea76cb | Escape chars, redirections |
| `mauve` | #cba6f7 | #c6a0f6 | #ca9ee6 | #8839ef | Keywords |
| `red` | #f38ba8 | #ed8796 | #e78284 | #d20f39 | Errors, deletions |
| `maroon` | #eba0ac | #ee99a0 | #ea999c | #e64553 | — |
| `peach` | #fab387 | #f5a97f | #ef9f76 | #fe640b | — |
| `yellow` | #f9e2af | #eed49f | #e5c890 | #df8e1d | Warnings, search |
| `green` | #a6e3a1 | #a6da95 | #a6d189 | #40a02b | Strings, additions |
| `teal` | #94e2d5 | #8bd5ca | #81c8be | #179299 | Options, secondary accents |
| `sky` | #89dceb | #91d7e3 | #99d1db | #04a5e5 | Operators |
| `sapphire` | #74c7ec | #7dc4e4 | #85c1dc | #209fb5 | CWD in prompt |
| `blue` | #89b4fa | #8aadf4 | #8caaee | #1e66f5 | Commands, UI accents |
| `lavender` | #b4befe | #b7bdf8 | #babbf1 | #7287fd | Active border |

## Generator

```bash
./scripts/generate-themes.sh
```

The script requires Homebrew bash (`#!/opt/homebrew/bin/bash`) for associative
array support — macOS ships bash 3.2 which lacks `declare -A`.

Produces these files (4 flavors × 3 tools + 1 Neovim palette = 13 files):

| Files | Tool |
|-------|------|
| `config/ghostty/themes/catppuccin-{flavor}` | Ghostty (×4) |
| `tmux-{flavor}.conf` | tmux (×4) |
| `config/fish/themes/catppuccin-{flavor}.theme` | Fish (×4) |
| `config/nvim/lua/palette.lua` | Neovim (all 4 in one table) |

For Starship, the generator only replaces the `[palettes.*]` section at the
bottom of each file; everything above it is preserved. `starship.toml` is the
mocha (default) config; the others only exist as `STARSHIP_CONFIG` overrides.

## Toggle function

`theme-toggle` (fish function) switches all tools at once:

| Tool | Mechanism |
|------|-----------|
| tmux | Symlink `~/.tmux-theme.conf` → `tmux-{flavor}.conf` + `tmux source-file` |
| Neovim | Remote-send `set background=dark/light` to all running instances via sockets |
| Fish | `fish_config theme choose catppuccin-{flavor}` with inline fallback via `set -g` |
| Ghostty | macOS appearance toggle via `osascript` (Ghostty auto-follows via `theme = dark:catppuccin-mocha,light:catppuccin-latte`) |

State is persisted to `~/.config/theme` as the flavor name.

**macOS appearance mapping:** only `latte` triggers macOS light mode; all other
flavors trigger dark mode. Ghostty's `theme = dark:...,light:...` config means
it always shows mocha or latte regardless of which dark flavor is active in
other tools.

## Neovim specifics

- Theme plugin: `catppuccin/nvim`
- Flavor is resolved from `vim.o.background`: `dark` → mocha, `light` → latte
  (Neovim only has two background modes; use `theme-toggle` for intermediate flavors)
- `init.lua` reads `~/.config/theme` at startup and sets `vim.o.background`
- `plugins/theme.lua` registers an `OptionSet background` autocommand that
  calls `catppuccin.setup({ flavour = ... })` and reloads the colorscheme
  whenever `background` changes — no restart needed
- `theme-toggle` triggers live updates by remote-sending `set background=<dark|light>`
  to all running Neovim instances via their Unix sockets
- `config/nvim/lua/palette.lua` is a generated Lua table with all 4 flavors,
  loaded via `dofile()` (not `require()` — Lazy.nvim's cache loader doesn't find it)
- lualine uses `theme = "catppuccin"` (built-in integration)

## Ghostty specifics

- Config: `theme = dark:catppuccin-mocha,light:catppuccin-latte`
- Ghostty only supports one dark and one light theme via `NSAppearance` — it
  always shows mocha (dark) or latte (light) regardless of which flavor other
  tools are using
- `theme-toggle` flips macOS dark mode as a side effect when switching to/from latte
- Use `--terminal` flag to skip the macOS flip (e.g. when running headless)

## Adding a new tool

1. Add a `generate_<tool>()` function to `scripts/generate-themes.sh`
   that reads from the `dark` / `light` associative arrays and writes
   the tool's theme file(s).

2. Call the new function from the `# --- Main ---` section at the bottom.

3. Add toggle logic to `config/fish/functions/theme-toggle.fish`
   (symlink swap, env var, or reload command).

4. If the tool needs initialization on shell startup, add it to
   `config/fish/config.fish`.

5. Run `./scripts/generate-themes.sh` and test with `theme-toggle`.
