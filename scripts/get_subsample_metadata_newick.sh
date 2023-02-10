#!/bin/bash
TREE_FILE=$1
METADATA_FILE=$2
NUM_TIPS_SAMPLE=$3
OUT_PREFIX=$4
SCRIPT_DIR=$(dirname $0)

$SCRIPT_DIR/gotree prune -i $TREE_FILE -r --random $NUM_TIPS_SAMPLE > ${OUT_PREFIX}.subsample.newick
head -n 1 $METADATA_FILE > ${OUT_PREFIX}_metadata.subsample.tsv
sed -n "$(grep -Eo '[(,][0-9]+:' ${OUT_PREFIX}.subsample.newick |sed 's/[(:,]//g' |tr '\n' \;p |sed 's/\;/p\;/g')" <(tail -n +2 $METADATA_FILE) >> ${OUT_PREFIX}_metadata.subsample.tsv

