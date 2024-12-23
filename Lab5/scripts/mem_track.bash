#!/bin/bash


bash mem.bash &
pid=$!
bash top_track.bash $pid &