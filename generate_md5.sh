#!/bin/bash

date="20130117 20130118 20130119 20130120 20130121 20130122 20130123"
files="lbs_user_fact_7days lbs_user_fact_30days"
wrong=("lbs_user_7day_fact" "lbs_user_30day_fact")
path="/home/work"
for d in $date;
do
    count=0
    for f in $files;
    do
        full="$path/$d/$f/${wrong[$count]}"
        if [ -f "$full" ]; then
            rm $full
        else echo "not exists $full"
        fi     
        ((count++))
        ls -l --time-style '+%Y-%m-%d %H:%M' "$path/$d/$f" | awk '{if(match($0,/[d-].*/)) printf("%s\t%s\t%s\t%s\n", $6, $7, $5
, $NF)}' | grep -v '@' > "$path/$d/$f"/@manifest
        md5sum "$path/$d/$f/@manifest" > "$path/$d/$f/@manifest.md5"
    done   
done


