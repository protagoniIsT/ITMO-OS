#!/bin/bash

echo $$ > .handler_pid

result=1
mode=""

mult2() {
	mode="mult"
}

add2() {
	mode="add"
}

terminate() {
	echo "Terminated by external process signal"
	exit 0
}

trap 'add2' USR1
trap 'mult2' USR2
trap 'terminate' SIGTERM

while true; do
    case $mode in
        "add")
            result=$((result + 2))
            echo "Result after addition: $result"
            ;;
        "mult")
            result=$((result * 2))
            echo "Result after multiplication: $result"
            ;;
        *)
            echo "Current result: $result"
            ;;
    esac
    mode=""
	sleep 1
done
