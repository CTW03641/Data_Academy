#!/usr/bin/env bash

declare -i a=$1
if [[ $a -gt 4 ]]; then
    echo "$a is greater than 4!"
else
    echo "$a is equal to or less than 4!"
fi