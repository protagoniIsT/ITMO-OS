#!/bin/bash
N=3700000

left=$N
right=$((N * 20)) 

run_script() {
    "$HOME/experiment-protagoniIsT/scripts/run2.bash"
    return $?
}

result=-1

while [[ $left -le $right ]]; do
    mid=$(( (left + right) / 2 ))

    echo "N=$mid"

    if run_script "$mid"; then
        result=$mid
        left=$((mid + 1))
    else
        right=$((mid - 1))
    fi
done

if [[ $result -eq -1 ]]; then
    echo "N not found."
else
    echo "Max N: $result"
fi
