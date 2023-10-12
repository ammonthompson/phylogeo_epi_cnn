#!/bin/bash

# This script processes a given tree, alongside tip state information, to generate 
# a structured output in cblv format. It leverages two auxiliary scripts, 
# 'vectorize_tree.py' and 'add_metadata_to_cblv.r', for tree vectorization and 
# metadata incorporation respectively.
#
# Inputs:
# 1. TREE_FILE: The path to the tree file.
# 2. TIP_STATE_FILE: The path to the file containing tip states.
# 3. OUTPUT_PREFIX: The prefix for the output files.
# 4. RECOVERY_RATE: Recovery rate used for tree vectorization.
# 5. SUBSAMPLE_PROPORTION: Proportion of data to be subsampled.
# 6. MAX_NUM_LOCS: Maximum number of locations.
#
# Outputs:
# - A cblv formatted file named: <OUTPUT_PREFIX>.cblv.
# - Temporary files are generated during processing, but are cleaned up after execution.
#
# Auxiliary Scripts (located in cblv_scripts dir):
# 1. vectorize_tree.py: Processes the input tree and returns it in a vectorized format.
# 2. add_metadata_to_cblv.r: Incorporates metadata into the vectorized tree representation.
#
# Usage:
# ./tree_locations_to_cblv.sh <TREE_FILE> <TIP_STATE_FILE> <OUTPUT_PREFIX> <RECOVERY_RATE> <SUBSAMPLE_PROPORTION> <MAX_NUM_LOCS>
#
# Notes:
# - It is imperative that the tree file and tip state file have consistent and matching IDs.
# - Ensure that both auxiliary scripts are available in the 'cblv_scripts' directory relative to this script.



TREE_FILE=$1
TIP_STATE_FILE=$2
OUTPUT_PREFIX=$3
RECOVERY_RATE=$4
SUBSAMPLE_PROPORTION=$5
MAX_NUM_LOCS=$6

THIS_DIR=$(dirname $0)
SUPPORT_SCRIPT_PATH=$(realpath $THIS_DIR/cblv_scripts)

$SUPPORT_SCRIPT_PATH/vectorize_tree.py $TREE_FILE $RECOVERY_RATE $OUTPUT_PREFIX |sed 's/\[//g'|sed 's/,//g'|sed "s/'//g" |sed 's/\]//g'  > $OUTPUT_PREFIX.cblv.1

$SUPPORT_SCRIPT_PATH/add_metadata_to_cblv.r $TIP_STATE_FILE ${OUTPUT_PREFIX}_tip_order_in_output.temp \
${OUTPUT_PREFIX}.cblv.1 $SUBSAMPLE_PROPORTION $OUTPUT_PREFIX $MAX_NUM_LOCS

rm ${OUTPUT_PREFIX}_tip_order_in_output.temp $OUTPUT_PREFIX.cblv.1

#sed -i 's/\r//g' $OUTPUT_PREFIX.cblv

