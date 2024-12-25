#!/bin/bash

bash "7_handler.bash" &
handler_pid=$!
bash "7_producer.bash"
wait $handler_pid
