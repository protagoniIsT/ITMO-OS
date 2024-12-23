#!/bin/bash

set -f

base_dir="$HOME"

max_date=$(find "$base_dir" -maxdepth 1 -type d -regextype posix-extended -regex '.*/Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}' \
    -exec basename {} \; | sed 's/Backup-//' | sort -r | head -n 1)

backup_dir="$HOME/Backup-$max_date"
restore_dir="$base_dir/restore"

if [[ -n "$max_date" ]]; then
    mkdir -p "$restore_dir"
    find "$backup_dir" -type f | while IFS= read -r file; do
        relative_path="${file#$backup_dir/}"
        if [[ ! "$relative_path" =~ \.[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            mkdir -p "$restore_dir/$(dirname "$relative_path")"
            cp "$file" "$restore_dir/$relative_path"
        fi
    done
fi

set +f
