#!/bin/bash

at now + 2 minutes <<< "bash 1_datetime.bash" #>/dev/null 2>&1

#timeout 120 tail -f "$HOME/report" || true
tail -f "$HOME/report" &


