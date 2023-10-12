#!/bin/bash

# This script processes input tree files in Newick and Nexus formats,
# splitting trees into separate files, extracting metadata, and 
# performing optional operations such as truncation and subsampling.
# The output includes individual tree files, metadata tables, and 
# location-specific Nexus tree files.
#
# Parameters:
# $1 - Input Nexus trees file.
# $2 - Input Newick trees file.
# $3 - Control file (for extracting number of locations).
# $4 - Output file prefix.
# $5 - Truncation time (0 for no truncation).
# $6 (optional) - Number of trees to subsample, or "all" to use all trees.
#
# Dependencies:
# - Assumes specific structures in the input tree files.
# - Calls external scripts: 
#	1. truncate_to_extant_time.r, 
#   	2. get_subsample_metadata_newick.sh, 
#	3. and make_location_nexus_file.sh.
#   Ensure these scripts are located in the same directory.
#
# Usage:
# ./create_final_treeFiles_and_tables.sh <nexus_trees_file> <newick_trees_file> 
#    <control_file> <out_file_prefix> <trunc_time> [num_subsample]




nexus_trees_file=$1
shift
newick_trees_file=$1
shift
control_file=$1
shift
out_file=$1
shift
trunc_time=$1
shift

num_subsample="all"
if [[ -n $1 ]];then
	num_subsample=$1
fi

SCRIPTS_DIR=$(dirname $0)


# separate newick tree list
counter=0
while read newick;do
	echo $newick > ${out_file}_rep${counter}.newick
	counter=$((counter+1))
done < $newick_trees_file

# separate nexus tree list and extract metadata tables
counter=0
while read tt;do

        tree_num=$(echo $tt |grep -Eo 'TREE_'[0-9]+)
        echo species$'\t'type$'\t'location$'\t'rxn$'\t'time > ${out_file}_rep${counter}_metadata.tsv
        echo $tt | grep -Eo '[0-9]+\[[^]]+\]' |sed -r 's/[a-z]+=//g' |\
		sed 's/"//g'|sed 's/,/\t/g'|sed 's/\[&/\t/g'|sed 's/[]]//g' |\
		sed -r 's/([0-9]\.[0-9]{8})[0-9]+/\1/g' >> ${out_file}_rep${counter}_metadata.tsv

	# if approximate extant sampling (truncation time) then truncate tips that extend past (only slightly)
	if [[ ! $trunc_time == 0 ]];then
                mv ${out_file}_rep${counter}.newick ${out_file}_rep${counter}.newick.temp
                $SCRIPTS_DIR/truncate_to_extant_time.r ${out_file}_rep${counter}.newick.temp\
        	        $trunc_time ${out_file}_rep${counter}.newick
	        rm ${out_file}_rep${counter}.newick.temp
        fi


	# if subsampling, then subsample the newick tree and metadata
	# then create location_nexus file
	if [[ ! $num_subsample == "all" ]];then
		
		if [[ $trunc_time -gt 0 ]];then
			mv ${out_file}_rep${counter}.newick ${out_file}_rep${counter}.newick.temp
			$SCRIPTS_DIR/truncate_to_extant_time.r ${out_file}_rep${counter}.newick.temp\
				$trunc_time ${out_file}_rep${counter}.newick
			rm ${out_file}_rep${counter}.newick.temp
		fi

		# subsample newick and metadata file
        	$SCRIPTS_DIR/get_subsample_metadata_newick.sh ${out_file}_rep${counter}.newick \
			${out_file}_rep${counter}_metadata.tsv $num_subsample ${out_file}_rep${counter}
        	$SCRIPTS_DIR/make_location_nexus_file.sh ${out_file}_rep${counter}.subsample.newick \
			${out_file}_rep${counter}_metadata.subsample.tsv  \
			$(grep NUMBER_LOCATIONS $control_file | cut -f 2) $tree_num ${out_file}_rep${counter}
	else
	
                $SCRIPTS_DIR/make_location_nexus_file.sh ${out_file}_rep${counter}.newick \
			${out_file}_rep${counter}_metadata.tsv  \
			$(grep NUMBER_LOCATIONS $control_file | cut -f 2) $tree_num ${out_file}_rep${counter}

	fi		

	counter=$((counter+1))

done < <(grep TREE_ $nexus_trees_file)



