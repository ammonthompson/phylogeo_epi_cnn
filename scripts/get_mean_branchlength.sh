#!/bin/bash
newick_tree=$1

branch_lengths=($(grep -Eo ':[0-9\.]+' $newick_tree |sed 's/://g'))
num_branches=${#branch_lengths[@]}
sum_bl=$(echo ${branch_lengths[@]} |sed 's/ /+/g'|sed 's/+$//g' | bc -l)

mean_bl=$(echo "scale=8; $sum_bl / $num_branches" |bc -l)

echo $mean_bl
