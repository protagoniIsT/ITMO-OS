#!/bin/bash
> task5.lst

awk -F '[= :]' '
{
    pid = $2
    ppid = $6
    art = $10
    
    sum[ppid] += art
    count[ppid]++
    
    lines[ppid] = lines[ppid] ? lines[ppid] ORS $0 : $0
}
END {
    for (ppid in lines) {

        avg = sum[ppid] / count[ppid]
        
        printf "$"lines[ppid]" AND Average_Running_Children_of_ParentID=%s is %.6f\n", ppid, avg
    }
}' task4.lst > task5.lst

sort -t '=' -k3,3n task5.lst -o task5.lst

sed -i 's/ AND /\n/g' task5.lst


