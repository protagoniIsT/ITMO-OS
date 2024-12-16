#!/bin/bash

ps -u "$USER" -o pid,cmd --no-headers | awk '
BEGIN { count=0 }
{
    count++

    lines[count] = $0
}
END {

    print count > "task1.lst"

    for (i = 1; i <= count; i++) {
        split(lines[i], fields, " ")

        printf "%s:", fields[1] >> "task1.lst"

        for (j = 2; j <= length(fields); j++)
            printf "%s%s", fields[j], (j < length(fields) ? " " : "") >> "task1.lst"
            
        print "" >> "task1.lst"
    }
}'

