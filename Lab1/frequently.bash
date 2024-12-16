#!/bin/bash
man bash | tr -c -s '[:alnum:]' '\n' | awk 'length($0) >= 4' | sort | uniq -c | sort -n -r | awk '{print $2}' | head -n 3

