#!/bin/bash
tp_script=$1
sim_param_file=$2
tree_file_prefix=$3  # assumes tree file ends in: _rep0.location_tree.nexus. Don't inclue 'sim' in prefix
outfile_prefix=$4

# I need this option for backwards compatability
downsample_colnum=16
if [[ -n $5 ]];then
	downsample_colnum=$5
fi


this_script_dir=$(dirname $0)

for sim_num in $(cut -f 1 $sim_param_file|sed 's/sim_*//');do

	cp $tp_script sim${sim_num}_$(basename $tp_script)
	sim_tp_script=$(echo sim${sim_num}_$(basename $tp_script))

	tree_file=$(echo ${tree_file_prefix}*[^0-9]${sim_num}_rep0.location_tree*nexus)
	if [[ ! -f $tree_file ]];then
		echo no tree file
		exit 1
	fi
	out_file=${outfile_prefix}_sim${sim_num}.log

	$this_script_dir/fix_spnames_subsample_data_file.sh $tree_file
	sed -i -r 's:data_file = \"[^\"]*\":data_file = \"'${tree_file}'\":g' $sim_tp_script
	sed -i -r 's:out_file = \"[^\"]*\":out_file = \"'${out_file}'\":g' $sim_tp_script
	$this_script_dir/setTrueValues_InTpScript.sh $sim_param_file $sim_tp_script $sim_num $downsample_colnum

	tp $sim_tp_script > ${out_file}.printscreen

	$this_script_dir/getESS.r ${out_file} ${out_file}.ess

	rm $sim_tp_script
done

