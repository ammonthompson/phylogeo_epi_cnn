#!/bin/bash

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

