#!/bin/bash

bash "5_handler.bash" &
handler_pid=$!
bash "5_producer.bash"
wait $handler_pid

rm -f pipe
