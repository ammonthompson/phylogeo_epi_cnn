#!/bin/bash
# input the ancStates files in sim number order
# check if first input is an integer, if it is assume it is number of locations
isint='^[0-9]+$'
if [[ $1 =~ $isint ]];then
	num_locs=$1
	shift
else
	num_locs=5
fi

# loop through each input ancStates file and print root location posterior probability
while [[ -n $1 ]];do
	anc_states_file=$1
	num_sample=$(tail -n +2 $anc_states_file |wc -l)
	colnum=$(($(head -n 1 $anc_states_file |sed 's/\t/\n/g'|wc -l) - 1))
	declare -a post_loc_counts
	for i in $(seq 0 $(( num_locs - 1 )));do
		count=$(cut -f $colnum $anc_states_file |grep -c '^'${i}'$')
		post_loc_counts+=($(echo 'scale=3;' $count '/' $num_sample |bc -l))
	done	
	echo $(basename $anc_states_file)$'\t'${post_loc_counts[@]} |sed -r 's/[ \t]+/\t/g'
	unset post_loc_counts
	shift
done


