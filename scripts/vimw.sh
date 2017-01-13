#!/usr/bin/env bash

PWD=$(pwd)
FILE="$PWD/$1"

osascript << EOF
  tell application "iTerm2"
    create window with default profile command "vim ${FILE}"
  end tell
EOF
