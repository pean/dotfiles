#!/usr/bin/env fish

# build-claude-settings.fish
# Composes claude/settings.json and claude-dreams/settings.json from:
#   - claude-shared/permissions-deny.json (shared permissions.deny block)
#   - claude/settings.template.json / claude-dreams/settings.template.json
#     (everything identity-specific: model, theme, plugins, mcp servers,
#     permissions.allow)
# Run this after editing a template or the shared deny list, then commit
# the regenerated settings.json files.

set -l root (cd (dirname (status --current-filename))/.. && pwd)
set -l deny "$root/claude-shared/permissions-deny.json"

for identity in claude claude-dreams
    set -l template "$root/$identity/settings.template.json"
    set -l out "$root/$identity/settings.json"

    if not test -f $template
        echo "⚠️  Skipping $identity: no settings.template.json found"
        continue
    end

    jq --slurpfile deny $deny '.permissions.deny = $deny[0]' $template > $out.tmp
    and mv $out.tmp $out
    and echo "✅ Wrote $out"
end
