function theme-toggle --description "Switch Catppuccin flavor: mocha, macchiato, frappe, latte"
    set -l state_file ~/.config/theme
    set -l current "mocha"
    set -l force 0
    set -l macos_only 0
    set -l skip_macos 0

    if test -f $state_file
        set current (cat $state_file)
    end

    # Parse args: optional flavor name, optional flags
    set -l target ""
    for arg in $argv
        switch $arg
            case --force --refresh
                set force 1
            case --macos
                set macos_only 1
            case --terminal
                set skip_macos 1
            case mocha macchiato frappe latte
                set target $arg
        end
    end

    # No flavor given: cycle dark flavors or toggle to latte
    if test -z "$target"
        switch "$current"
            case latte
                set target mocha
            case '*'
                set target latte
        end
    end

    # --macos: only flip macOS appearance, leave terminal/tools untouched
    if test "$macos_only" = "1"
        if test "$target" = "latte"
            osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false' 2>/dev/null
        else
            osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null
        end
        echo "macOS appearance set to "(test "$target" = "latte"; and echo "light"; or echo "dark")
        return
    end

    if test "$target" = "$current" -a "$force" = "0"
        echo "Already using $current"
        return
    end

    if test "$force" = "1"
        echo "Regenerating theme files..."
        ~/.dotfiles/scripts/generate-themes.sh
    end

    echo $target > $state_file
    echo "Switching to $target..."

    set -l dotfiles ~/.dotfiles
    # latte is the only light flavor; all others are dark
    set -l is_light (test "$target" = "latte"; and echo 1; or echo 0)

    # --- tmux (symlink swap) ---
    ln -sf $dotfiles/tmux-$target.conf ~/.tmux-theme.conf
    if set -q TMUX
        tmux source-file ~/.tmux.conf 2>/dev/null
    end

    # --- Neovim (all running instances via nvim sockets) ---
    set -l nvim_socks
    for sock in /tmp/nvim.*/0
        test -S "$sock"; and set -a nvim_socks $sock
    end
    test -S /tmp/nvimsocket; and set -a nvim_socks /tmp/nvimsocket
    for sock in /tmp/nvim-*
        test -S "$sock"; and set -a nvim_socks $sock
    end
    set -l bg (test "$is_light" = "1"; and echo "light"; or echo "dark")
    for sock in $nvim_socks
        nvim --server "$sock" --remote-send "<Cmd>set background=$bg<CR>" 2>/dev/null
    end

    # --- Fish shell colors ---
    fish_config theme choose "catppuccin-$target" 2>/dev/null
    or _theme_apply_fish_$target

    # --- Ghostty (macOS appearance toggle) ---
    if test "$skip_macos" = "0"
        if test "$is_light" = "1"
            osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false' 2>/dev/null
        else
            osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null
        end
    end

    echo "Switched to $target"
end

function _theme_apply_fish_mocha
    # Catppuccin Mocha
    set -g fish_color_normal cdd6f4
    set -g fish_color_autosuggestion 6c7086
    set -g fish_color_cancel --reverse
    set -g fish_color_command 89b4fa
    set -g fish_color_comment 7f849c --italics
    set -g fish_color_cwd 74c7ec
    set -g fish_color_cwd_root f38ba8
    set -g fish_color_end 94e2d5
    set -g fish_color_error f38ba8
    set -g fish_color_escape f5c2e7
    set -g fish_color_history_current cdd6f4 --bold
    set -g fish_color_host a6e3a1
    set -g fish_color_host_remote f9e2af
    set -g fish_color_keyword cba6f7
    set -g fish_color_operator 89dceb
    set -g fish_color_option 94e2d5
    set -g fish_color_param cdd6f4
    set -g fish_color_quote a6e3a1
    set -g fish_color_redirection f5c2e7 --bold
    set -g fish_color_search_match --background=45475a --bold
    set -g fish_color_selection cdd6f4 --background=45475a --bold
    set -g fish_color_status f38ba8
    set -g fish_color_user a6e3a1
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_completion cdd6f4
    set -g fish_pager_color_description f9e2af --italics
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress 1e1e2e --background=cba6f7 --bold
    set -g fish_pager_color_selected_background --background=45475a
end

function _theme_apply_fish_macchiato
    # Catppuccin Macchiato
    set -g fish_color_normal cad3f5
    set -g fish_color_autosuggestion 6e738d
    set -g fish_color_cancel --reverse
    set -g fish_color_command 8aadf4
    set -g fish_color_comment 8087a2 --italics
    set -g fish_color_cwd 7dc4e4
    set -g fish_color_cwd_root ed8796
    set -g fish_color_end 8bd5ca
    set -g fish_color_error ed8796
    set -g fish_color_escape f5bde6
    set -g fish_color_history_current cad3f5 --bold
    set -g fish_color_host a6da95
    set -g fish_color_host_remote eed49f
    set -g fish_color_keyword c6a0f6
    set -g fish_color_operator 91d7e3
    set -g fish_color_option 8bd5ca
    set -g fish_color_param cad3f5
    set -g fish_color_quote a6da95
    set -g fish_color_redirection f5bde6 --bold
    set -g fish_color_search_match --background=494d64 --bold
    set -g fish_color_selection cad3f5 --background=494d64 --bold
    set -g fish_color_status ed8796
    set -g fish_color_user a6da95
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_completion cad3f5
    set -g fish_pager_color_description eed49f --italics
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress 24273a --background=c6a0f6 --bold
    set -g fish_pager_color_selected_background --background=494d64
end

function _theme_apply_fish_frappe
    # Catppuccin Frappe
    set -g fish_color_normal c6d0f5
    set -g fish_color_autosuggestion 737994
    set -g fish_color_cancel --reverse
    set -g fish_color_command 8caaee
    set -g fish_color_comment 838ba7 --italics
    set -g fish_color_cwd 85c1dc
    set -g fish_color_cwd_root e78284
    set -g fish_color_end 81c8be
    set -g fish_color_error e78284
    set -g fish_color_escape f4b8e4
    set -g fish_color_history_current c6d0f5 --bold
    set -g fish_color_host a6d189
    set -g fish_color_host_remote e5c890
    set -g fish_color_keyword ca9ee6
    set -g fish_color_operator 99d1db
    set -g fish_color_option 81c8be
    set -g fish_color_param c6d0f5
    set -g fish_color_quote a6d189
    set -g fish_color_redirection f4b8e4 --bold
    set -g fish_color_search_match --background=51576d --bold
    set -g fish_color_selection c6d0f5 --background=51576d --bold
    set -g fish_color_status e78284
    set -g fish_color_user a6d189
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_completion c6d0f5
    set -g fish_pager_color_description e5c890 --italics
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress 303446 --background=ca9ee6 --bold
    set -g fish_pager_color_selected_background --background=51576d
end

function _theme_apply_fish_latte
    # Catppuccin Latte
    set -g fish_color_normal 4c4f69
    set -g fish_color_autosuggestion 9ca0b0
    set -g fish_color_cancel --reverse
    set -g fish_color_command 1e66f5
    set -g fish_color_comment 8c8fa1 --italics
    set -g fish_color_cwd 209fb5
    set -g fish_color_cwd_root d20f39
    set -g fish_color_end 179299
    set -g fish_color_error d20f39
    set -g fish_color_escape ea76cb
    set -g fish_color_history_current 4c4f69 --bold
    set -g fish_color_host 40a02b
    set -g fish_color_host_remote df8e1d
    set -g fish_color_keyword 8839ef
    set -g fish_color_operator 04a5e5
    set -g fish_color_option 179299
    set -g fish_color_param 4c4f69
    set -g fish_color_quote 40a02b
    set -g fish_color_redirection ea76cb --bold
    set -g fish_color_search_match --background=bcc0cc --bold
    set -g fish_color_selection 4c4f69 --background=bcc0cc --bold
    set -g fish_color_status d20f39
    set -g fish_color_user 40a02b
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_completion 4c4f69
    set -g fish_pager_color_description df8e1d --italics
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress eff1f5 --background=8839ef --bold
    set -g fish_pager_color_selected_background --background=bcc0cc
end
