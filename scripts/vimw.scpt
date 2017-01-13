on run argv
  tell application "iTerm2"
    create window with default profile command "vim " & item 1 of argv
  end tell
end run
