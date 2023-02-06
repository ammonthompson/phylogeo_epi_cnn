#!/bin/bash

TREE_FILE=$1
RECOVERY_RATE=$2
OUTPUT_PREFIX=$3

PROJ_ROOT=$(echo $PWD |sed -r 's/(.*epi_geo_simulation).*/\1/g')

if [[ -n $PROJ_ROOT ]];then
	SCRIPTS_DIR=$PROJ_ROOT/MASTER/scripts/cblv_scripts
	$SCRIPTS_DIR/vectorize_tree.py $TREE_FILE $RECOVERY_RATE $OUTPUT_PREFIX |sed 's/\[//g'|sed 's/,//g'|sed "s/'//g" |sed 's/\]//g'  > $OUTPUT_PREFIX.cblv
else
	$SCRIPTS_DIR/vectorize_tree.py $TREE_FILE $RECOVERY_RATE $OUTPUT_PREFIX |sed 's/\[//g'|sed 's/,//g'|sed "s/'//g" |sed 's/\]//g'  > $OUTPUT_PREFIX.cblv
fi
rm ${OUTPUT_PREFIX}*.temp
