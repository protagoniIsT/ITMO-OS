#!/bin/bash

echo $$ > .producer_pid

while true; do
    read -r line
    case $line in
    	"+")
    		kill -USR1 $(cat .handler_pid)
    		;;
    	"*")
    		kill -USR2 $(cat .handler_pid)
    		;;
    	"TERM")
    		echo "Terminating..."
    		kill $(cat .handler_pid)
    		exit 0
    		;;
    	*)
    		;;
    esac		
done


