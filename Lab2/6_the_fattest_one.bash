#!/bin/bash

proc_max_mem_consumption=0

for pid in /proc/[0-9]*; do
    proc_mem_consumption=$(grep "^VmRSS" "$pid/status" | awk '{print $2}')
    if [[ $proc_max_mem_consumption -le $proc_mem_consumption ]]; then
        proc_max_mem_consumption=$proc_mem_consumption
        res_proc_pid=$(basename "$pid")
    fi
done

echo $res_proc_pid
