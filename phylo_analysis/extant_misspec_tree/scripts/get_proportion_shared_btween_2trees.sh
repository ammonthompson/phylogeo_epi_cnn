#!/bin/bash
tree1=$1
tree2=$2
output=($(gotree compare trees -i $tree1 -c $tree2 |tail -n 1))
proportion=$(echo "${output[2]}/(${output[1]} + ${output[2]} +${output[3]} )" |bc -l)
echo ${proportion:0:5}
