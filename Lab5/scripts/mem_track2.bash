#!/bin/bash


bash mem.bash &
pid1=$!
bash mem2.bash &
pid2=$!

bash top_track2.bash $pid1 $pid2 &