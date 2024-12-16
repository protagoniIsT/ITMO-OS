#!/bin/bash

bash "6_handler.bash" &
handler_pid=$!
bash "6_producer.bash"
wait $handler_pid


