#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 filename old_word new_word new_filename"
    exit 1
fi

filename=$1
old_word=$2
new_word=$3

echo $filename


# Use sed to replace the word in a case-sensitive manner
sed -i "s/$old_word/$new_word/g" "$filename"