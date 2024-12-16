#!/bin/bash

if [[ ! -p pipe ]]; then
    mkfifo pipe
fi

echo $$ > .producer_pid

while true; do
    read -r line
    echo "$line" > pipe
done


