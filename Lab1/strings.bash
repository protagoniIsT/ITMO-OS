#!/bin/bash

read -r str

while [[ "$str" != "q" ]]
do
    echo ${#str}
    if [[ "$str" =~ ^[[:alpha:].\\\*]+$ ]]; then
        echo "true"
    else
        echo "false"
    fi

    read -r str
done
