#!/bin/bash

arr=()
seq=(1 2 3 4 5 6 7 8 9 10)
iteration=0

report_log="../logs/report.log"
> "$report_log"

while true
do
    arr+=("${seq[@]}")
    ((iteration++))
    
    if [[ $((iteration % 100000)) -eq 0 ]]; then
        echo "${#arr[@]}" >> "$report_log"
    fi
done

