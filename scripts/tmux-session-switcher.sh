#!/usr/bin/env bash
# Session switcher popup (prefix + f). Usage: tmux-session-switcher.sh <client_tty>
client="$1"
fzf_bin=~/.tmux/plugins/tmux-fzf/scripts/.fzf-tmux
export SWITCHER_CURRENT_SESSION="$(tmux display -p -c "$client" '#{client_session}')"
opts="$(tmux show -gv @tmux-fzf-options)"

choice=$("$(dirname "$0")/tmux-fzf-sessions.sh" | eval "$fzf_bin $opts --no-multi --header='ctrl-x: kill session'")
if [ -n "$choice" ]; then
  tmux switch-client -c "$client" -t "=$(cut -c11- <<<"$choice")"
fi
