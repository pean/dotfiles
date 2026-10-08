#!/usr/bin/env fish
# Installs (or reloads) the launchd agent that serves the running-ports list.
# Pass `uninstall` to remove it.

set -l label se.wa.pean.startpage-ports
set -l source (path dirname (status filename))/$label.plist
set -l target ~/Library/LaunchAgents/$label.plist
set -l domain gui/(id -u)

# bootout returns before the old instance is gone, so wait for it.
if launchctl bootout $domain/$label 2>/dev/null
    while launchctl print $domain/$label >/dev/null 2>&1
        sleep 0.2
    end
end
if test "$argv[1]" = uninstall
    rm -f $target
    echo "removed $label"
    exit 0
end

cp $source $target
launchctl bootstrap $domain $target
and echo "loaded $label"
