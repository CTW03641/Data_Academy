#!/usr/bin/env bash

#for i in *.sh
#do
#    echo "file: $i"
#done

echo "While of $1"

declare -i test=$1
declare -i n=1

while (( n <= test ))
do
    echo "$n of $test"
    (( n++ ))
done