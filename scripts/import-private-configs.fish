#!/usr/bin/env fish
# Import private config files into dotfiles repo
# These files are gitignored but managed by RCM for symlinking
#
# RCM convention: Files in dotfiles repo are stored without leading dot
# and are symlinked to home directory with a dot prefix
#
# Files to import are read from .gitignore between:
# --- BEGIN RCM MANAGED --- and --- END RCM MANAGED ---

set -l dotfiles_dir ~/.dotfiles
set -l gitignore_path $dotfiles_dir/.gitignore

# Parse .gitignore to extract RCM-managed files
set -l in_section 0
set -l files_to_import

for line in (cat $gitignore_path)
    if string match -q "*BEGIN RCM MANAGED*" $line
        set in_section 1
        continue
    end

    if string match -q "*END RCM MANAGED*" $line
        set in_section 0
        continue
    end

    if test $in_section -eq 1
        # Skip empty lines and comments
        set -l trimmed (string trim $line)
        if test -n "$trimmed"; and not string match -q "#*" $trimmed
            set -a files_to_import $trimmed
        end
    end
end

if test (count $files_to_import) -eq 0
    echo "No files configured in .gitignore RCM MANAGED section"
    exit 0
end

echo "Importing private config files into dotfiles..."

for filename in $files_to_import
    # Add leading dot for home directory path
    set -l file .$filename
    set -l source_path ~/$file
    set -l dest_path $dotfiles_dir/$filename

    if not test -e $source_path
        echo "⊗ Skipping $file (not found at $source_path)"
        continue
    end

    if test -L $source_path
        echo "⊗ Skipping $file (already a symlink)"
        continue
    end

    if test -e $dest_path
        echo "⊗ Skipping $filename (already exists in dotfiles)"
        continue
    end

    # Move file to dotfiles repo (without leading dot)
    mv $source_path $dest_path
    echo "✓ Moved $file → $filename in dotfiles"
end

echo ""
echo "Run 'rcup' to create symlinks for these files"
