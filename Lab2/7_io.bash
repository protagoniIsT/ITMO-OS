#!/bin/bash

tmp_file="bytes_read_before.lst"


> "$tmp_file"
for pid in $(ps -eo pid=); do
    if [[ -r "/proc/$pid/io" ]]; then
        bytes_read=$(grep "read_bytes" "/proc/$pid/io" | awk '{print $2}')
        echo "$pid $bytes_read" >> "$tmp_file"
    fi
done

sleep 60

declare -A read_diff

while read -r pid initial_bytes_read; do
    if [[ -r "/proc/$pid/io" ]]; then
        bytes_read_after=$(grep "read_bytes" "/proc/$pid/io" | awk '{print $2}')
        if [[ -n $bytes_read_after && -n $initial_bytes_read ]]; then
            read_diff[$pid]=$((bytes_read_after - initial_bytes_read))
        fi
    fi
done < "$tmp_file"

for pid in "${!read_diff[@]}"; do
    echo "$pid ${read_diff[$pid]}"
done | sort -k2 -nr | head -n 3 | while read pid bytes_read; do
    if [[ -r "/proc/$pid/cmdline" ]]; then
        cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
        echo "PID=${pid} : Bytes_Read=$bytes_read : Command_Line=$cmdline"
    else
        echo "PID=${pid} : Bytes_Read=$bytes_read : Command_Line=NULL"
    fi
done

rm "$tmp_file"

