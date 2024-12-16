#!/bin/bash

mkdir -p "$HOME/test"

start_date=$(date +"%Y-%m-%d")
start_time=$(date +"%H-%M-%S")
timestamp="${start_date}_${start_time}"

touch "$HOME/test/$timestamp"

echo "<$start_date:$start_time> test was created successfully" >> "$HOME/report"

files_to_compress=$(find "$HOME/test" -maxdepth 1 -type f | grep -v "${start_date}")

if [[ -n $files_to_compress ]]; then
	first_file=$(echo "$files_to_compress" | head -n 1)
    	filename=$(basename "$first_file")
    	prev_date=$(echo "$filename" | awk -F'_' '{print $1}')
	mkdir -p "$HOME/test/archived"
	tar -cf "$HOME/test/archived/${prev_date}.tar" $files_to_compress
	gzip "$HOME/test/archived/${prev_date}.tar"
	rm $files_to_compress
fi

