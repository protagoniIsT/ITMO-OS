#!/bin/bash

set -f

base_dir="$HOME"
src_dir="$HOME/source"

start_date=$(date +"%Y-%m-%d")
past_date=$(date -d "$start_date -7 days" +"%Y-%m-%d")
timestamp_past=$(date -d "$past_date" +"%s")

max_date=$(find "$base_dir" -maxdepth 1 -type d -regextype posix-extended -regex '.*/Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}' \
    -exec basename {} \; | sed 's/Backup-//' | sort -r | head -n 1)

backup_dir="" 
is_new_backup=false

if [[ -n "$max_date" ]]; then
    timestamp_max=$(date -d "$max_date" +"%s")
    if [[ $timestamp_max -le $timestamp_past ]]; then
        mkdir -p "$base_dir/Backup-$start_date"
        backup_dir="$base_dir/Backup-$start_date"
        is_new_backup=true
    else
        backup_dir="$base_dir/Backup-$max_date"
    fi
else
    mkdir -p "$base_dir/Backup-$start_date"
    backup_dir="$base_dir/Backup-$start_date"
    is_new_backup=true
fi

if [[ ! -d "$backup_dir" ]]; then
    echo "Error: directory $backup_dir was not created." >&2
    exit 1
fi

tmp_change_log="changelog.lst"
> "$tmp_change_log"

if [[ "$is_new_backup" == true ]]; then 
    echo "NAME:$backup_dir;CREATION_DATE:$start_date" >> "$HOME/backup-report"
    find "$src_dir" -type f -print0 | while IFS= read -r -d '' file; do
        relative_path="${file#$src_dir/}"
        mkdir -p "$backup_dir/$(dirname "$relative_path")"
        cp -- "$file" "$backup_dir/$relative_path"
        echo "$relative_path" >> "$tmp_change_log"
    done
    echo "FILES:$(cat "$tmp_change_log")" >> "$HOME/backup-report"
    echo " " >> "$HOME/backup-report"
else 
    find "$src_dir" -type f -print0 | while IFS= read -r -d '' file; do
        relative_path="${file#$src_dir/}"
        target_file="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$target_file")"
        
        if [[ -f "$target_file" ]]; then 
            existing_f_size=$(stat -c%s -- "$target_file")
            src_f_size=$(stat -c%s -- "$file")
            if [[ "$existing_f_size" != "$src_f_size" ]]; then
                new_version="$target_file.$start_date"
                mv -- "$target_file" "$new_version"
                cp -- "$file" "$target_file"
                echo "$file $new_version" >> "$tmp_change_log"
            fi
        else
            cp -- "$file" "$target_file"
            echo "$relative_path" >> "$tmp_change_log"
        fi
    done
    if [[ -s "$tmp_change_log" ]]; then
        echo "NAME:$backup_dir;CHANGE_DATE:$start_date;$(cat "$tmp_change_log" | tr '\n' ' ')" >> "$HOME/backup-report"
        echo " " >> "$HOME/backup-report"
    fi
fi

set +f
