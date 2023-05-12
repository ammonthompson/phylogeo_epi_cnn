#!/bin/bash
# $1 the desired num locations
# $2 is the param list file

num_locs=$1
param_file=$2

out_file_loc=$(dirname $param_file)

repo_root=$(echo $(realpath .) | grep -Eo '.*epi_geo_simulation')
random_num_dir=$(find $repo_root -type d -name 'random_num_generators')

# loop thru each line of the param list file
# randomly select which of the first $num_locs will have the remaining locs lumped with it
# update the location in the 3 files
while read line;do
	# set files
	sim=$(echo $line |cut -d ' ' -f 1)
	metadata_file=$(echo ${out_file_loc}/*_${sim}_rep0_metadata.tsv)
	tree_loc_file=$(echo ${out_file_loc}/*_${sim}_rep0.location_tree.nexus)

	# reverse one hot
	one_hot_root_loc=$(echo $line |cut -d ' ' -f 2)
	root_loc_num_preshift=$($random_num_dir/reverse_onehot.r $one_hot_root_loc)
	root_loc_num=$(( root_loc_num_preshift - 1))

	# if location is > than num_locs, lump a random location with the excess locations 
	# and set to the root location
	if [[ $root_loc_num -ge $num_locs ]];then
		root_loc_num=$($random_num_dir/rsample.r 1 $(echo $(seq 0 $(($num_locs - 1)))|sed 's/ /,/g')|sed 's/ /,/g')
	fi

	new_one_hot_root_loc=$($random_num_dir/onehot.r $((root_loc_num + 1)) $num_locs |sed 's/ /,/g')

	echo old root loc: $one_hot_root_loc new root loc num: $root_loc_num new root loc: $new_one_hot_root_loc
	# update files
	sed -i 's/'${sim}'\t'${one_hot_root_loc}'/'${sim}'\t'${new_one_hot_root_loc}'/g' $param_file
	awk -i inplace 'BEGIN{OFS="\t"} { if($3 >= '$num_locs' && $1 ~ "[^a-z]") $3='$root_loc_num';print}' $metadata_file	
	awk -i inplace 'BEGIN{OFS="\t"} { if($2 >= '$num_locs' && $1 ~ "^[0-9]") $2='$root_loc_num';print}' $tree_loc_file

done < <(tail -n +2 $param_file)




