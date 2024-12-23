#!/bin/bash

pid1=$1
pid2=$2

output_file1="$HOME/experiment-protagoniIsT/logs/top-output-mem.log"
output_file2="$HOME/experiment-protagoniIsT/logs/top-output-mem2.log"

> "$output_file1"
> "$output_file2"

while ps -p "$pid1" -p "$pid2" > /dev/null 2>&1; do
    top -b -n 1 | awk '/MiB Mem|MiB Swap/' >> "$output_file1"
    top -b -n 1 -p "$pid1" | tail -n +8 >> $output_file1
    top -b -n 1 | head -n 12 | tail -n 5 >> $output_file1
    echo "------" >> $output_file1

    top -b -n 1 | awk '/MiB Mem|MiB Swap/' >> "$output_file2"
    top -b -n 1 -p "$pid2" | tail -n +8 >> $output_file2
    top -b -n 1 | head -n 12 | tail -n 5 >> $output_file2
    echo "------" >> $output_file2
done

