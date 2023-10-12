#!/bin/bash

# This script subsamples a Newick-formatted phylogenetic tree and the corresponding
# metadata, retaining a random set of tree tips/leaves and their associated metadata.
#
# Inputs:
# 1. TREE_FILE: The path to the Newick tree file to be subsampled.
# 2. METADATA_FILE: The path to the metadata file associated with the tree.
# 3. NUM_TIPS_SAMPLE: The number of tree tips/leaves to retain in the subsampling.
# 4. OUT_PREFIX: The prefix for the output files.
#
# Outputs:
# - A subsampled Newick tree file with the name: <OUT_PREFIX>.subsample.newick.
# - A subsampled metadata file with the name: <OUT_PREFIX>_metadata.subsample.tsv.
#
# Dependencies:
# - Requires the gotree tool for processing phylogenetic trees.
# - Assumes the first line of the metadata file is the header.
#
# Usage:
# ./get_subsample_metadata_newick.sh <TREE_FILE> <METADATA_FILE> <NUM_TIPS_SAMPLE> <OUT_PREFIX>
#
# Notes:
# - The script relies on matching tree tip IDs between the Newick tree and the metadata.
# - Ensure that the TREE_FILE and METADATA_FILE have consistent and matching IDs.


TREE_FILE=$1
METADATA_FILE=$2
NUM_TIPS_SAMPLE=$3
OUT_PREFIX=$4
SCRIPT_DIR=$(dirname $0)

$SCRIPT_DIR/gotree prune -i $TREE_FILE -r --random $NUM_TIPS_SAMPLE > ${OUT_PREFIX}.subsample.newick
head -n 1 $METADATA_FILE > ${OUT_PREFIX}_metadata.subsample.tsv
sed -n "$(grep -Eo '[(,][0-9]+:' ${OUT_PREFIX}.subsample.newick |sed 's/[(:,]//g' |tr '\n' \;p |sed 's/\;/p\;/g')" <(tail -n +2 $METADATA_FILE) >> ${OUT_PREFIX}_metadata.subsample.tsv

