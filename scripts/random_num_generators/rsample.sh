#!/bin/bash
num_sample=$1
set_array=($(echo $2 |sed 's/,/ /g'))

declare -a sample_array
for i in $(seq 1 $num_sample);do
	rand_idx=$(( RANDOM % $((${#set_array[@]} )) ))
	sample_array+=($(echo ${set_array[$rand_idx]}))
done
echo ${sample_array[@]}
