#!/bin/bash

if [[ ! -p pipe ]]; then
    mkfifo pipe
fi

producer_pid=$(cat .producer_pid)

result=1
mode="+"

while true; do
    read -r line < pipe
    case $line in
    	"+")
        	mode="+"
            echo "Mode changed to '+'"
            ;;
        "*")
            mode="*"
            echo "Mode changed to '*'"
            ;;
        -[0-9]* | [0-9]*)
            if [[ $mode == "+" ]]; then
                result=$((result + line))
            else
                result=$((result * line))
            fi    
            echo "Current result: $result"
            ;;
         "QUIT")
            echo "Stopped externally."
            kill "$producer_pid"
            exit 0
            ;;
         *)
            echo "Invalid input: $line"
            kill "$producer_pid"
            exit 1
            ;;
    esac
done

