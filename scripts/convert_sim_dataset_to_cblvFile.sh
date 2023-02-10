#!/bin/bash

SIM_DIR=$1 # directory where the sim param values, tree files and metadata files are located
SIM_PREFIX=$2 # this is the prefix used by the randomParams_Simulation.sh script
OUT_CBLV_PREFIX=$3
NUM_LOCS=$4
THIS_SCRIPT_PATH=$(dirname $0)
for sim_num in $(cut -f 1 $SIM_DIR/${SIM_PREFIX}_param_values.txt |sed 's/sim_*//g'|tail -n +2);do

	RECOVERY_RATE=$(grep -m 1 sim_\*$sim_num$'\t' $SIM_DIR/${SIM_PREFIX}_param_values.txt |cut -f 6)
	SUBSAMPLE_PROP=$(grep -m 1 sim_\*$sim_num$'\t' $SIM_DIR/${SIM_PREFIX}_param_values.txt |cut -f 16)

	echo $($THIS_SCRIPT_PATH/tree_locations_to_cblv.sh $SIM_DIR/${SIM_PREFIX}_sim${sim_num}_rep0*.newick \
		$SIM_DIR/${SIM_PREFIX}_sim${sim_num}_rep0_metadata*.tsv $OUT_CBLV_PREFIX \
		$RECOVERY_RATE $SUBSAMPLE_PROP $NUM_LOCS) |sed 's/ /,/g'
	
done
