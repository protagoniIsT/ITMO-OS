#!/bin/bash

if [[ -p stpipe ]]; then
    rm -f stpipe >/dev/null
fi

mkfifo stpipe

producer_pid=$(cat .producer_pid)

result=1
mode="+"

(tail -f pipe) | while read -r line; do
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
            killall tail
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

