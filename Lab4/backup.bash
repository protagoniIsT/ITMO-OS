#!/bin/bash

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
	if [[  $timestamp_max -le $timestamp_past ]]; then
		mkdir "$base_dir/Backup-$start_date"
		backup_dir="$base_dir/Backup-$start_date"
		is_new_backup=true
	else 
		backup_dir="$base_dir/Backup-$max_date"
	fi
else
	mkdir "$base_dir/Backup-$start_date"
	backup_dir="$base_dir/Backup-$start_date"
	is_new_backup=true
fi

if [[ ! -d "$backup_dir" ]]; then
    echo "Error: directory $backup_dir was not created." >&2
    exit 1
fi

tmp_change_log="changelog.lst"
> $tmp_change_log

if [[ "$is_new_backup" == true ]]; then 
	find "$src_dir" -type f -exec cp {} "$backup_dir/" \;
	echo "NAME:$backup_dir;CREATION_DATE:$start_date;FILES:$(ls -1 "$backup_dir" | tr '\n' ' ')" >> "$HOME/backup-report"
else 
	find "$src_dir" -type f | while read -r file; do
		existing_file=$(find "$backup_dir" -type f -name "$(basename "$file")")
		if [[ -z $existing_file ]]; then
			cp "$file" "$backup_dir"
			echo "$(basename "$file")" >> "$tmp_change_log"
		else 
			existing_f_size=$(stat -c%s "$existing_file")
			src_f_size=$(stat -c%s "$file")
			if [[ $existing_f_size != $src_f_size ]]; then
				new_version="$existing_file.$start_date"
                mv "$existing_file" "$new_version"
                cp "$file" "$backup_dir"
                echo "$(basename "$existing_file") $(basename "$new_version") " >> "$tmp_change_log"
			fi
		fi
	done
	if [[ -s $tmp_change_log ]]; then
		echo "NAME:$backup_dir;CHANGE_DATE:$start_date;$(cat "$tmp_change_log" | tr '\n' ' ')" >> "$HOME/backup-report"
	fi
fi
