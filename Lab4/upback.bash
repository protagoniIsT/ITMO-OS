#!/bin/bash

set -f

base_dir="$HOME"

max_date=$(find "$base_dir" -maxdepth 1 -type d -regextype posix-extended -regex '.*/Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}' \
    -exec basename {} \; | sed 's/Backup-//' | sort -r | head -n 1)
    
backup_dir="$HOME/Backup-$max_date"
    
if [[ -n "$max_date" ]]; then
	mkdir -p "$base_dir/restore"
	find "$backup_dir" -type f | while IFS= read -r file; do
		name=$(basename "$file")
		if [[ ! "$name" =~ \.[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
			cp "$file" "$base_dir/restore"
		fi
	done
fi

set +f
