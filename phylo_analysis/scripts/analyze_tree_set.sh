#!/bin/bash

# This script analyzes a set of tree files using a provided .Rev (tp) script.
# The trees are sourced from simulations, and the script modifies the tp 
# script with the appropriate tree and output file paths for each simulation 
# iteration. The script further calls auxiliary scripts to fix species names 
# and to set true parameter values within the Rev script before executing 
# the TreePL analysis. After Rev execution, the effective sample size (ESS) 
# of the analysis is computed and saved.
#
# Usage:
# ./analyze_tree_set.sh [tp_script] [sim_param_file] [tree_file_prefix] [outfile_prefix] [downsample_colnum]
#
# Arguments:
# tp_script: Path to the .Rev script that specifies the model and settings 
#            for tree analysis.
# sim_param_file: File containing simulation parameters with the simulation 
#                 number in the first column.
# tree_file_prefix: Prefix for the tree file names (excluding the 'sim' and 
#                   simulation number).
# outfile_prefix: Prefix for the output log files.
# downsample_colnum (optional): Column number to downsample, default is 16.
# -----------------------------------------------------------------------------



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

