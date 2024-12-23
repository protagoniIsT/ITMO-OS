#!/bin/bash

N=$1

arr=()
seq=(1 2 3 4 5 6 7 8 9 10)
iteration=0

while true
do
    arr+=("${seq[@]}")
    ((iteration++))
    
    if [[ ${#arr[@]} -gt $N ]]; then
        echo "Array size limit exceeded. Exiting." 
        exit 1
    fi
done


