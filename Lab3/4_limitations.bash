#!/bin/bash
 
inf_mult() {
	while true; do
        result=$((20 * 20)) 
    done
}

pids=()
for i in {1..3}; do
	inf_mult &
	pids+=($!)
done

echo "${pids[0]}"
echo "${pids[1]}"
echo "${pids[2]}"

cpulimit --limit=10 --pid ${pids[0]} &

sleep 10 

kill ${pids[2]}

wait
