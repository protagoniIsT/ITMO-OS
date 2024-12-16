#!/bin/bash

declare -A initial_vmsize
declare -A was_running

end_time=$((SECONDS + 300))

while [ $SECONDS -lt $end_time ]; do
    for pid in $(ps -eo pid=); do
        if [[ -r "/proc/$pid/status" ]]; then
            state=$(awk '/^State:/ {print $2}' "/proc/$pid/status")
            if [[ "$state" == "R" ]]; then
                was_running[$pid]=1
                if [[ -z "${initial_vmsize[$pid]}" ]]; then
                    vmsize=$(awk '/^VmSize:/ {print $2}' "/proc/$pid/status")
                    initial_vmsize[$pid]=$vmsize
                fi
            fi
        fi
    done
    sleep 1
done

declare -A vm_diff

for pid in "${!was_running[@]}"; do
    if [[ -r "/proc/$pid/status" ]]; then
        state=$(awk '/^State:/ {print $2}' "/proc/$pid/status")
        if [[ "$state" == "S" ]]; then
            curr_vmsize=$(awk '/^VmSize:/ {print $2}' "/proc/$pid/status")
            initial_vmsize_value=${initial_vmsize[$pid]}
            if [[ -n $curr_vmsize && -n $initial_vmsize_value && $initial_vmsize_value -ne 0 ]]; then
                diff=$(echo "scale=2; (($curr_vmsize - $initial_vmsize_value) / $initial_vmsize_value) * 100" | bc)
                vm_diff[$pid]=$diff
            fi
        fi
    fi
done

count=0
for pid in "${!vm_diff[@]}"; do
    if [[ $count -ge 5 ]]; then
        break
    fi
    if [[ -r "/proc/$pid/status" ]]; then
        euid=$(awk '/^Uid:/ {print $3}' "/proc/$pid/status")
        if [[ -r "/proc/$pid/cmdline" ]]; then
            cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
            if [[ -z "$cmdline" ]]; then
                cmdline=$(awk '/^Name:/ {print $2}' "/proc/$pid/status")
            fi
        else
            cmdline="NULL"
        fi
        echo -e "$pid\t$euid\t$cmdline\t${vm_diff[$pid]}"
        count=$((count+1))
    fi
done

