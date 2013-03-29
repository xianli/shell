#!/bin/bash


full_path=""

while read table_name keep_days 
do
first_day=`date -d "-${keep_days} days" +%Y%m%d`
is_lbs=`echo $table_name | grep '^lbs_*' | wc -l`
if [ $is_lbs = '1' ]; then 
    full_path="/log/${table_name}/"
else 
    full_path="/log/${table_name}/event_action=lbs/"
fi
all_path=`hadoop fs -ls $full_path | awk '{print $8}'`
for path in $all_path;
do
    #get date in the path
    date=`echo $path | awk -F"=" '{print $NF}'`
    if [ $date -lt $first_day ]; then
#to_delete=`hadoop fs -ls $path` 
        echo $path
    fi
done
done < trashfiles
