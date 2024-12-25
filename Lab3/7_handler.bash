#!/bin/bash

echo $$ > .handler7_pid

if [[ -p stpipe ]]; then
    rm -f stpipe >/dev/null
fi

mkfifo stpipe

producer_pid=$(cat .producer7_pid)

stack=("" "" "" "" "")

st_capacity=${#stack[@]}
st_size=0

declare -A arity
arity[add]=2
arity[subtract]=2
arity[multiply]=2
arity[divide]=2
arity[gcd]=2
arity[log10]=1
arity[pow10]=1
arity[max2]=2

push() {
    local value=$1
    if ((st_size == st_capacity)); then
        shift_stack
        ((st_size--))
    fi
    stack[$st_size]=$value
    ((st_size++))
    st_size=$((st_size > st_capacity ? st_capacity : st_size))
}

# pop() {
#     local value=${stack[$((st_size-1))]}
#     stack[$((st_size-1))]=""  
#     ((st_size--))
#     echo "$value"
# }

shift_stack() {
    for ((i=0; i<st_capacity-1; i++)); do
        stack[$i]=${stack[$((i+1))]}
    done
    stack[$((st_capacity-1))]=""
}

add() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi
    
    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local res=$(echo "$a + $b" | bc -l)
    
    push $res
}

subtract() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))
    local res=$(echo "$a - $b" | bc -l)

    push $res
}

multiply() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local res=$(echo "$a * $b" | bc -l)

    push $res
}

divide() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi   

    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    if (( $(echo "$b == 0" | bc -l) )); then
        push "$b"
        push "$a"
        echo "Divisor should be != 0."
        return 1
    fi

    if [[ $a =~ ^-?[0-9]+$ && $b =~ ^-?[0-9]+$ && $((a % b)) -eq 0 ]]; then
        local res=$((a / b))
    else
        local res=$(echo "scale=10; $a / $b" | bc -l)
    fi

    push $res
}

gcd() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    if ! [[ $a =~ ^-?[0-9]+$ && $b =~ ^-?[0-9]+$ ]]; then
        echo "'$op' requires integer inputs. Got: a=$a, b=$b" >&2
        push $b
        push $a
        return 1
    fi

    while [[ $b -ne 0 ]]; do
        local temp=$b
        b=$((a % b))
        a=$temp
    done

    push $a
}

log10() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    local num=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    if (( $(echo "$num <= 0" | bc -l) )); then
        echo "log10 argument should be > 0."
        push $num
        return 1
    fi

    local res=$(echo "scale=5; l($num)/l(10)" | bc -l)
    push $res
}


pow10() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    local exp=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    if [[ $exp =~ ^-?[0-9]+$ ]]; then
        local res=1
        if ((exp > 0)); then
            for ((i=0; i<exp; i++)); do
                res=$((res * 10))
            done
        elif ((exp < 0)); then
            res=$(echo "scale=10; 1 / (10 ^ $(( -exp )))" | bc -l)
        fi
    else
        local res=$(echo "scale=10; e($exp * l(10))" | bc -l)
    fi
    
    push $res
}


max2() {
    op=${FUNCNAME[0]}
    ar=${arity[$op]}
    if ((st_size < ar)); then
        echo "Not enough elements to perform '$op': $st_size. Required: $ar."
        return 1
    fi

    # local a=$(pop)
    # local b=$(pop)
    local a=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    local b=${stack[$((st_size-1))]}
    stack[$((st_size-1))]=""  
    ((st_size--))

    if (( $(echo "$a > $b" | bc -l) )); then
        res=$a
    else
        res=$b
    fi
    push $res
}


(tail -f stpipe) | while read -r line; do
    case $line in
        -[0-9]*.[0-9]* | [0-9]*.[0-9]* | -[0-9]* | [0-9]*)
            push "$line"
            echo "$st_size; ${stack[@]}"
            ;;
        "+")
            add
            echo "$st_size; ${stack[@]}"
            ;;
        "-")
            subtract
            echo "$st_size; ${stack[@]}"            
            ;;
        "*")
            multiply
            echo "$st_size; ${stack[@]}"
            ;;
        "/")
            divide
            echo "$st_size; ${stack[@]}"
            ;;
        "gcd")
            gcd
            echo "$st_size; ${stack[@]}"
            ;;
        "log10")
            log10
            echo "$st_size; ${stack[@]}"
            ;;
        "pow10")
            pow10
            echo "$st_size; ${stack[@]}"
            ;;
        "max2")
            max2
            echo "$st_size; ${stack[@]}"
            ;;
        # "pop")
        #     pop
        #     echo "$st_size; ${stack[@]}"
        #     ;;
        "quit")
            echo "Stopping..."
            killall tail
            kill $producer_pid
            exit 0
            ;;
        *)
            echo "Unknown operation: $line."
            ;;
    esac
done

