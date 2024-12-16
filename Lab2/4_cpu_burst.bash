#!/bin/bash
> task4.lst
for process in /proc/[0-9]*; do
    pid=$(basename "$process")
    ppid=$(grep "^PPid:" "$process/status" | awk '{print $2}')
    p_sum_exec_rt=$(grep "^se.sum_exec_runtime" "$process/sched" | awk '{print $3}')
    p_nr_sw=$(grep "^nr_switches" "$process/sched" | awk '{print $3}')
    if [ "$p_nr_sw" -ne 0 ]; then
        ART=$(echo "scale=6; $p_sum_exec_rt / $p_nr_sw" | bc)
    else
        ART=0
    fi
    printf "ProcessID="$pid" : Parent_ProcessID="$ppid" : Average_Running_Time="$ART"\n" >> task4.lst
done

sort -t '=' -k 3,3n task4.lst -o task4.lst
