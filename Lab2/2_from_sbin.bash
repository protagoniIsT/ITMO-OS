#!/bin/bash

ps -eo pid,cmd --no-headers | grep '/sbin/' | awk '{print $1}' > task2.lst

