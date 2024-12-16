#!/bin/bash

a=$1
b=$2

sum=0

for i in $(seq $a $b)
do
    sum=$((sum + i))
    echo "$sum"
done

