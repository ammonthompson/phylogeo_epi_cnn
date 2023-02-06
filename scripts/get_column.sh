#!/bin/bash
# returns the columns with heading that contains the pattern
column_name_pattern=$1
shift
infile=$1
shift

include_column_1=false
if [[ -n $1 ]];then
	include_column_1=$3
fi

declare -a colnums
if [[ $include_column_1 == "true" ]];then
	colnums+=(1)
fi
for pattern in $(echo $column_name_pattern |sed 's/,/ /g');do
count=1
for i in $(head -n 1 $infile);do
        if [[ $(echo $i |grep -c $pattern)  == 1 ]];then
		colnums+=($count)
	fi
	count=$((count + 1))
done
done
cut -f $(echo ${colnums[@]} |sed 's/ /,/g') $infile
