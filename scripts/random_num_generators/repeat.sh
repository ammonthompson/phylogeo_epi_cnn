#!/bin/bash

value_to_repeat=$1
num_sample=$2
declare -a out_string
for i in $(seq 1 $num_sample);do
	out_string+=($(echo $value_to_repeat))
done
echo ${out_string[@]}
