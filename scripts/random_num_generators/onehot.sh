#!/bin/bash
number=$1
maxnumber=$2

declare -a onehot_array

count=1
for i in $(seq 1 $maxnumber);do
	if [[ $count == $number ]];then
		onehot_array+=(1)
	else
		onehot_array+=(0)
	fi
	count=$((count + 1))
done
echo ${onehot_array[@]}
