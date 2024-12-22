#!/bin/bash

filename="$1"

trash_dir="$HOME/.trash"

if [[ ! -d "$trash_dir" ]]; then
	mkdir "$trash_dir"
fi

curr_number=$(find "$trash_dir" -type f -name "[0-9]*" | awk -F'/' '{print $NF}' | sort -nr | head -n 1)

if [[ -z "$curr_number" ]]; then
	curr_number=1
else
	curr_number=$((curr_number + 1))
fi

if ln "$filename" "$trash_dir/$curr_number"; then
    echo "ABS_PATH:$(realpath "$filename");HARD_LINK:${curr_number}" >> "$HOME/.trash.log"
    rm "$filename"
    echo "File '$filename' moved to trash as '$curr_number'."
else
    echo "Error: Failed to create hard link for '$filename'."
    exit 1
fi
