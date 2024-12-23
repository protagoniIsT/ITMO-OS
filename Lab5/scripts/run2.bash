#!/bin/bash

last_number=$(tail -n 1 "$HOME/experiment-protagoniIsT/logs/report.log")
N=$((last_number / 10))

k=30

dmesg_marker=$(dmesg | wc -l)

for ((i=1; i<=$k; i++))
do
    bash "newmem.bash" $N
    if [[ $? -ne 0 ]]; then
        echo "Error in newmem.bash"
        exit 1
    fi
    sleep 1
done

if dmesg | tail -n +$((dmesg_marker + 1)) | grep -q -i "oom"; then
    echo "OOM Kill detected in dmesg. Failing run2."
    exit 1
fi

exit 0

