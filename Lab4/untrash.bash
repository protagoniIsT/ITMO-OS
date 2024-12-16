#!/bin/bash

filename=$1

policy=${2:--i}

case $policy in
    -i|--ignore) policy="ignore" ;;
    -u|--unique) policy="unique" ;;
    -o|--overwrite) policy="overwrite" ;;
    *) echo "Invalid policy: $policy"; exit 1 ;;
esac

trash_log_file="temp_log.lst"
> "$trash_log_file"
grep "${filename}" "$HOME/.trash.log" >> "$trash_log_file"

if [[ ! -s "$trash_log_file" ]]; then
    echo "No matching entries for ${filename} found to restore."
    rm -f "$trash_log_file"
    exit 1
fi

while read -r line; do
    path=$(echo "$line" | awk -F '[: ]' '{print $2}')
    hard_link=$(echo "$line" | awk -F '[: ]' '{print $4}')
    
    read -p "Do you want to restore file $path? (y/n): " response </dev/tty
    
    case $response in
        [Yy])
            echo "Trying to restore file $path..."
            dir=$(dirname $path)
            
            if [[ ! -d $dir ]]; then
                echo "Specified directory $dir does not exist. Restoring to $HOME"
                path="$HOME/$(basename "$path")"
            fi
            
            if [[ -f "$path" ]]; then
                case $policy in
                    "ignore")
                        echo "Unable to restore file $path"
                        continue
                        ;;
                    "unique")
                        basename=$(basename $path)
                        cnt=1
                        
                        name="${basename%.*}"
                        ext="${basename##*.}"
                        
                        while [[ -f "$dir/${name}(${cnt}).${ext}" ]]; do
                            ((cnt++))
                        done
                        
                        path="$dir/${name}(${cnt}).${ext}"
                        ;;
                    "overwrite")
                        echo "Overwriting file $path."
                        rm -f "$path"
                        ;;
                esac
            fi
            
            if ln "$HOME/.trash/$hard_link" "$path"; then
                echo "File $path was successfully restored."
                sed -i "\|$line|d" "$HOME/.trash.log"
            else
                echo "Failed to restore $path."
            fi
            ;;
        
        [Nn])
            echo "Skipping file $path..."
            ;;
        
        *)
            echo "Invalid response. Skipping."
            ;;
    esac

done < "$trash_log_file"

rm -f "$trash_log_file"
