#!/bin/bash

cat /etc/passwd | awk -F: '{print $3, $1}' | sort -n -k 1
