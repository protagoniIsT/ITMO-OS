#!/bin/bash

pid=$1

output_file="$HOME/experiment-protagoniIsT/logs/top-output.log"

> "$output_file"

while ps -p "$pid" > /dev/null 2>&1; do
    top -b -n 1 | awk '/MiB Mem|MiB Swap/' >> "$output_file"
    top -b -n 1 -p "$1" | tail -n +8 >> $output_file
    top -b -n 1 | head -n 12 | tail -n 5 >> $output_file
    echo "------" >> $output_file
done