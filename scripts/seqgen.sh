#!/bin/bash

# output tree files from MASTER sims
newick_tree_file=$1
output_prefix=$2

scale=0.001
seq_length=200

# split newick tree file
split -l 1 -d $newick_tree_file ${output_prefix}_33temp_tree_342423425532aa.

# simulate alignment
for sim_num in $(ls ${output_prefix}_33temp_tree_342423425532aa* |sed 's:'${output_prefix}_33temp_tree_342423425532aa.'::g');do
	seq-gen -s$scale -a2 -g4 -mHKY -t2.0 -f0.25,0.25,0.25,0.25 -l$seq_length -n1 -on < ${output_prefix}_33temp_tree_342423425532aa.$sim_num > \
		$output_prefix.sim${sim_num}.alignment.nexus 2>> $output_prefix.log
done

rm ${output_prefix}_33temp_tree_342423425532aa.* #${output_prefix}_44temp_tree_2937402938756984xx.*
