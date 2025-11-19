#!/usr/bin/env fish

# sync-agents-claude.fish
# Ensures AGENTS.md is the real file and CLAUDE.md is a symlink pointing to it
# Handles both migration (CLAUDE.md → AGENTS.md) and linking (AGENTS.md + symlink)
# Usage: ./sync-agents-claude.fish [--dry-run]

# Directories to search for CLAUDE.md and AGENTS.md files
set -l search_dirs \
    ~/.claude \
    ~/.dotfiles \
    ~/src

set -l dry_run false

# Parse arguments
for arg in $argv
    if test "$arg" = "--dry-run"
        set dry_run true
    end
end

# Print header
echo "=================================="
echo "AGENTS.md ↔ CLAUDE.md Sync"
echo "=================================="
if test $dry_run = true
    echo "🔍 DRY RUN MODE - No changes will be made"
else
    echo "⚠️  LIVE MODE - Changes will be applied"
end
echo ""

# Find all directories containing either CLAUDE.md or AGENTS.md
echo "🔍 Searching for CLAUDE.md and AGENTS.md files..."
echo "   Searching in: $search_dirs"

# Get unique directories that contain either file
set -l all_dirs (find $search_dirs \( -name "CLAUDE.md" -o -name "AGENTS.md" \) -exec dirname {} \; 2>/dev/null | sort -u)

if test (count $all_dirs) -eq 0
    echo "✅ No CLAUDE.md or AGENTS.md files found in search directories"
    exit 0
end

echo "📁 Found "(count $all_dirs)" director(ies) with CLAUDE.md or AGENTS.md"
echo ""

set -l migrated 0
set -l linked 0
set -l warnings 0
set -l skipped 0

for dir in $all_dirs
    set -l claude_path "$dir/CLAUDE.md"
    set -l agents_path "$dir/AGENTS.md"

    echo "---"
    echo "📂 Directory: $dir"

    # Check what exists
    set -l has_claude false
    set -l has_agents false
    set -l claude_is_symlink false
    set -l agents_is_symlink false
    set -l claude_target ""

    if test -e $claude_path
        set has_claude true
        if test -L $claude_path
            set claude_is_symlink true
            set claude_target (readlink $claude_path)
        end
    end

    if test -e $agents_path
        set has_agents true
        if test -L $agents_path
            set agents_is_symlink true
        end
    end

    # Display status
    if test $has_claude = true
        if test $claude_is_symlink = true
            echo "   CLAUDE.md: EXISTS (symlink -> $claude_target)"
        else
            echo "   CLAUDE.md: EXISTS (regular file)"
        end
    else
        echo "   CLAUDE.md: does not exist"
    end

    if test $has_agents = true
        if test $agents_is_symlink = true
            echo "   AGENTS.md: EXISTS (symlink -> "(readlink $agents_path)")"
        else
            echo "   AGENTS.md: EXISTS (regular file)"
        end
    else
        echo "   AGENTS.md: does not exist"
    end

    # Decide action based on what exists
    # CASE 1: Both exist as regular files
    if test $has_claude = true -a $has_agents = true -a $claude_is_symlink = false -a $agents_is_symlink = false
        echo "   ⚠️  WARNING: Both CLAUDE.md and AGENTS.md exist as regular files!"
        echo "   → Manual intervention required"
        echo "   → Compare files and choose which to keep"
        set warnings (math $warnings + 1)

    # CASE 2: AGENTS.md exists, CLAUDE.md is correctly symlinked to it
    else if test $has_agents = true -a $agents_is_symlink = false -a $claude_is_symlink = true -a "$claude_target" = "AGENTS.md"
        echo "   ✅ Already correctly configured"
        set skipped (math $skipped + 1)

    # CASE 3: AGENTS.md is a symlink (unusual)
    else if test $has_agents = true -a $agents_is_symlink = true
        echo "   ⚠️  WARNING: AGENTS.md is a symlink (expected to be regular file)"
        echo "   → Manual intervention required"
        set warnings (math $warnings + 1)

    # CASE 4: Only CLAUDE.md exists (regular file) - needs migration
    else if test $has_claude = true -a $claude_is_symlink = false -a $has_agents = false
        if test $dry_run = true
            echo "   🔄 [DRY RUN] Would migrate:"
            echo "      1. Rename CLAUDE.md → AGENTS.md"
            echo "      2. Create symlink CLAUDE.md → AGENTS.md"
        else
            echo "   🔄 Migrating CLAUDE.md → AGENTS.md"
            if mv $claude_path $agents_path
                echo "   ✅ Renamed successfully"
                echo "   🔗 Creating symlink: CLAUDE.md → AGENTS.md"
                cd $dir
                if ln -s AGENTS.md CLAUDE.md
                    echo "   ✅ Symlink created successfully"
                    set migrated (math $migrated + 1)
                else
                    echo "   ❌ Failed to create symlink"
                    set warnings (math $warnings + 1)
                end
            else
                echo "   ❌ Failed to rename file"
                set warnings (math $warnings + 1)
            end
        end

    # CASE 5: Only AGENTS.md exists - needs symlink
    else if test $has_agents = true -a $agents_is_symlink = false -a $has_claude = false
        if test $dry_run = true
            echo "   🔗 [DRY RUN] Would create symlink: CLAUDE.md → AGENTS.md"
        else
            echo "   🔗 Creating symlink: CLAUDE.md → AGENTS.md"
            cd $dir
            if ln -s AGENTS.md CLAUDE.md
                echo "   ✅ Symlink created successfully"
                set linked (math $linked + 1)
            else
                echo "   ❌ Failed to create symlink"
                set warnings (math $warnings + 1)
            end
        end

    # CASE 6: CLAUDE.md is symlink but points to wrong target
    else if test $claude_is_symlink = true -a "$claude_target" != "AGENTS.md"
        echo "   ⚠️  WARNING: CLAUDE.md symlinks to unexpected target: $claude_target"
        echo "   → Manual intervention required"
        set warnings (math $warnings + 1)

    # CASE 7: Unexpected state
    else
        echo "   ⚠️  WARNING: Unexpected file state"
        echo "   → Manual intervention required"
        set warnings (math $warnings + 1)
    end

    echo ""
end

# Print summary
echo "=================================="
echo "Summary"
echo "=================================="
if test $dry_run = true
    echo "Dry run completed - no changes made"
else
    echo "🔄 Migrated (CLAUDE.md → AGENTS.md): $migrated"
    echo "🔗 Linked (created CLAUDE.md symlink): $linked"
    echo "⏭️  Skipped (already correct): $skipped"
    echo "⚠️  Warnings/Manual intervention: $warnings"
end
echo ""

if test $warnings -gt 0
    echo "⚠️  Some files require manual attention - review warnings above"
    exit 1
end

exit 0
