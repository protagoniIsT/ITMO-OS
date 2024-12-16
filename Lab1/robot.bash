#!/bin/bash


n=$1
m=$2
#считаю, что нумерация координат поля идёт с нуля

x=$((m / 2))
y=$((n / 2))

key="M"

while [[ "$key" != "q" ]]
do

    echo -e "x=$x;y=$y"

    read -n 1 key

    case "$key" in
        [Ww])
            y=$((y + 1))
            ;;
        [Aa])
            x=$((x - 1))
            ;;
        [Ss])
            y=$((y - 1))
            ;;
        [Dd])
            x=$((x + 1))
            ;;
    esac

    if [[ $x -lt 0 || $x -ge $m || $y -lt 0 || $y -ge $n ]]; then
        exit 1
    fi
done
