#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 filename pascal-word camel-word new-filename package"
    exit 1
fi

filename=$1
pascal_word=$2
camelCase_word=$3
new_fileName=$4
package=$5

cp $filename $new_fileName

./replace-word.sh "$new_fileName" "$pascal_word"  "{{.CurrentTable.GetPascalCaseTableName}}" 


./replace-word.sh "$new_fileName" "$camelCase_word"  "{{.CurrentTable.GetCamelCaseTableName}}" 
./replace-word.sh "$new_fileName" "$package"  '{{getTag .Tags "PackageBase"}}' 