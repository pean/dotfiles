#!/usr/bin/env bash
# Session list for the tmux session switcher, skipping $SWITCHER_CURRENT_SESSION.
# Newest first (fzf draws the first line nearest the input). Fixed-width
# "Day HH:MM " prefix (10 cols) so names line up.
tmux list-sessions -F '#{session_last_attached}	#{t/f/%a %R:session_last_attached} #S	#S' |
  sort -t$'\t' -k1,1nr | awk -F'\t' -v cur="$SWITCHER_CURRENT_SESSION" '$3 != cur { print $2 }'
