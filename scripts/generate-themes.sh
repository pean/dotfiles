#!/opt/homebrew/bin/bash
# Generate all theme files from the shared palette (theme-palette.conf).
# Run this after editing theme-palette.conf to propagate color changes.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
PALETTE="$DOTFILES/theme-palette.conf"

if [[ ! -f "$PALETTE" ]]; then
  echo "Error: $PALETTE not found" >&2
  exit 1
fi

# --- Parse palette into associative arrays (one per flavor) ---
declare -A mocha macchiato frappe latte
current_section=""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Strip full-line comments (lines starting with #)
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  # Strip inline comments (space followed by #)
  line="${line%%[[:space:]]#*}"
  line="${line##*( )}"      # trim leading
  line="${line%%*( )}"      # trim trailing
  [[ -z "$line" ]] && continue

  case "$line" in
    "[mocha]")     current_section="mocha";     continue ;;
    "[macchiato]") current_section="macchiato"; continue ;;
    "[frappe]")    current_section="frappe";    continue ;;
    "[latte]")     current_section="latte";     continue ;;
  esac

  if [[ "$line" == *=* && -n "$current_section" ]]; then
    key="${line%%=*}"
    val="${line#*=}"
    val="${val#\#}"
    case "$current_section" in
      mocha)     mocha[$key]="$val" ;;
      macchiato) macchiato[$key]="$val" ;;
      frappe)    frappe[$key]="$val" ;;
      latte)     latte[$key]="$val" ;;
    esac
  fi
done < "$PALETTE"

# Flavor display names
flavor_label() {
  case "$1" in
    mocha)     echo "Mocha" ;;
    macchiato) echo "Macchiato" ;;
    frappe)    echo "Frappe" ;;
    latte)     echo "Latte" ;;
  esac
}

# --- Ghostty ---
# Style guide: cursor=Rosewater, cursor_text=Crust, active_border=Lavender,
# inactive_border=Overlay0, ANSI mapping per style guide
generate_ghostty() {
  local flavor=$1
  declare -n c=$flavor
  local label file
  label=$(flavor_label "$flavor")
  file="$DOTFILES/config/ghostty/themes/catppuccin-$flavor"

  # ANSI per Catppuccin style guide:
  # color0=Surface1  color1=Red    color2=Green  color3=Yellow
  # color4=Blue      color5=Pink   color6=Teal   color7=Subtext0
  # color8=Surface2  color9=Red    color10=Green color11=Yellow
  # color12=Blue     color13=Pink  color14=Teal  color15=Subtext1
  cat > "$file" <<EOF
palette = 0=#${c[surface1]}
palette = 1=#${c[red]}
palette = 2=#${c[green]}
palette = 3=#${c[yellow]}
palette = 4=#${c[blue]}
palette = 5=#${c[pink]}
palette = 6=#${c[teal]}
palette = 7=#${c[subtext0]}
palette = 8=#${c[surface2]}
palette = 9=#${c[red]}
palette = 10=#${c[green]}
palette = 11=#${c[yellow]}
palette = 12=#${c[blue]}
palette = 13=#${c[pink]}
palette = 14=#${c[teal]}
palette = 15=#${c[subtext1]}
background = #${c[base]}
foreground = #${c[text]}
cursor-color = #${c[rosewater]}
cursor-text = #${c[crust]}
selection-background = #${c[surface2]}
selection-foreground = #${c[text]}
EOF
  echo "  ghostty/themes/catppuccin-$flavor"
}

# --- tmux ---
# tmux files are named by macOS mode since tmux config imports one file.
# dark flavors: mocha, macchiato, frappe -> tmux-{flavor}.conf
# light flavor: latte                    -> tmux-latte.conf
generate_tmux() {
  local flavor=$1
  declare -n c=$flavor
  local label file
  label=$(flavor_label "$flavor")
  file="$DOTFILES/tmux-$flavor.conf"

  local win_fmt win_cur_fmt status_style status_right
  win_fmt="#[fg=#${c[overlay1]},bg=#${c[surface0]}] #I #[fg=#${c[text]},bg=#${c[surface0]}] #W "
  win_cur_fmt="#[fg=#${c[base]},bg=#${c[mauve]}] #I #[fg=#${c[text]},bg=#${c[base]}] #W "
  status_style="bg=#${c[surface0]},fg=#${c[text]}"
  status_right="#[fg=#${c[mauve]},bg=#${c[surface0]}]#(~/.dotfiles/scripts/tmux-git-worktree.sh #{pane_current_path}) #[fg=#${c[text]},bg=#${c[surface0]}]#(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD 2>/dev/null) #[fg=#${c[green]},bg=#${c[surface0]}]+#(cd #{pane_current_path}; git diff --numstat 2>/dev/null | awk \"{add+=\\\$1; del+=\\\$2} END {print add}\") #[fg=#${c[red]},bg=#${c[surface0]}]-#(cd #{pane_current_path}; git diff --numstat 2>/dev/null | awk \"{add+=\\\$1; del+=\\\$2} END {print del}\") #[fg=#${c[base]},bg=#${c[mauve]}] #S "

  cat > "$file" <<EOF
# Catppuccin $label for tmux (generated from theme-palette.conf)

set -g pane-border-style "fg=#${c[surface0]}"
set -g pane-active-border-style "fg=#${c[lavender]}"

set -g window-status-format "${win_fmt}"
set -g window-status-current-format "${win_cur_fmt}"
set -g window-status-separator ""
set -g window-status-activity-style "bg=#${c[yellow]},fg=#${c[base]}"
set -g window-status-bell-style "bg=#${c[yellow]},fg=#${c[base]}"

set -g status-style "${status_style}"
set -g status-left ""
set -g status-right '${status_right}'
set -g status-right-length 100

set -g @tmux-fzf-options '-p -w 62% -h 38% --color=bg+:#${c[surface1]},bg:#${c[base]},spinner:#${c[mauve]},hl:#${c[lavender]},fg:#${c[text]},header:#${c[lavender]},info:#${c[mauve]},pointer:#${c[mauve]},marker:#${c[mauve]},fg+:#${c[text]},prompt:#${c[mauve]},hl+:#${c[lavender]} --bind=ctrl-x:execute-silent(echo {} | sed "s/:.*$//" | xargs tmux kill-session -t)+reload(tmux list-sessions)'
EOF
  echo "  tmux-$flavor.conf"
}

# --- Fish theme file ---
generate_fish() {
  local flavor=$1
  declare -n c=$flavor
  local label file
  label=$(flavor_label "$flavor")
  file="$DOTFILES/config/fish/themes/catppuccin-$flavor.theme"

  cat > "$file" <<EOF
# Catppuccin $label for Fish (generated from theme-palette.conf)
fish_color_normal ${c[text]}
fish_color_autosuggestion ${c[overlay0]}
fish_color_cancel --reverse
fish_color_command ${c[blue]}
fish_color_comment ${c[overlay1]} --italics
fish_color_cwd ${c[sapphire]}
fish_color_cwd_root ${c[red]}
fish_color_end ${c[teal]}
fish_color_error ${c[red]}
fish_color_escape ${c[pink]}
fish_color_history_current ${c[text]} --bold
fish_color_host ${c[green]}
fish_color_host_remote ${c[yellow]}
fish_color_keyword ${c[mauve]}
fish_color_operator ${c[sky]}
fish_color_option ${c[teal]}
fish_color_param ${c[text]}
fish_color_quote ${c[green]}
fish_color_redirection ${c[pink]} --bold
fish_color_search_match --background=${c[surface1]} --bold
fish_color_selection ${c[text]} --background=${c[surface1]} --bold
fish_color_status ${c[red]}
fish_color_user ${c[green]}
fish_color_valid_path --underline
fish_pager_color_completion ${c[text]}
fish_pager_color_description ${c[yellow]} --italics
fish_pager_color_prefix normal --bold --underline
fish_pager_color_progress ${c[base]} --background=${c[mauve]} --bold
fish_pager_color_selected_background --background=${c[surface1]}
EOF
  echo "  fish/themes/catppuccin-$flavor.theme"
}

# --- Neovim palette (lua table with all 4 flavors) ---
generate_nvim_palette() {
  local file="$DOTFILES/config/nvim/lua/palette.lua"

  emit_flavor() {
    local flavor=$1
    declare -n c=$flavor
    cat <<EOF
  $flavor = {
    base = "#${c[base]}",
    mantle = "#${c[mantle]}",
    crust = "#${c[crust]}",
    surface0 = "#${c[surface0]}",
    surface1 = "#${c[surface1]}",
    surface2 = "#${c[surface2]}",
    overlay0 = "#${c[overlay0]}",
    overlay1 = "#${c[overlay1]}",
    overlay2 = "#${c[overlay2]}",
    subtext0 = "#${c[subtext0]}",
    subtext1 = "#${c[subtext1]}",
    text = "#${c[text]}",
    rosewater = "#${c[rosewater]}",
    flamingo = "#${c[flamingo]}",
    pink = "#${c[pink]}",
    mauve = "#${c[mauve]}",
    red = "#${c[red]}",
    maroon = "#${c[maroon]}",
    peach = "#${c[peach]}",
    yellow = "#${c[yellow]}",
    green = "#${c[green]}",
    teal = "#${c[teal]}",
    sky = "#${c[sky]}",
    sapphire = "#${c[sapphire]}",
    blue = "#${c[blue]}",
    lavender = "#${c[lavender]}",
  },
EOF
  }

  {
    echo "-- Generated from theme-palette.conf — do not edit manually"
    echo "return {"
    emit_flavor mocha
    emit_flavor macchiato
    emit_flavor frappe
    emit_flavor latte
    echo "}"
  } > "$file"

  echo "  nvim/lua/palette.lua"
}

# --- Main ---
echo "Generating theme files from $PALETTE..."
echo ""

for flavor in mocha macchiato frappe latte; do
  generate_ghostty "$flavor"
  generate_tmux "$flavor"
  generate_fish "$flavor"
done
generate_nvim_palette

echo ""
echo "Done. Restart apps or run theme-toggle to apply."
