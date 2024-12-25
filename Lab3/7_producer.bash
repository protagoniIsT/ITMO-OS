#!/bin/bash

echo $$ > .producer7_pid

while ps -p $(cat .handler7_pid) >/dev/null; do
    read -r line
    echo "$line" > stpipe
done
