#!/bin/bash

# This script converts a Newick tree and its associated metadata into a Nexus
# format file with embedded location data.
#
# Inputs:
# 1. NEWICK_TREE: The path to the Newick tree to be converted.
# 2. METADATA_FILE: The path to the metadata file associated with the tree.
# 3. NUM_LOCATIONS: The number of unique locations referenced in the metadata.
# 4. TREE_LABEL: A label identifier for the tree within the Nexus file.
# 5. OUTPUT_PREFIX: The prefix for the output Nexus file.
#
# Outputs:
# - A Nexus file with the tree and its associated location data. The output file is named: <OUTPUT_PREFIX>.location_tree.nexus.
#
# Auxiliary Scripts:
# None.
#
# Usage:
# ./make_location_nexus_file.sh <NEWICK_TREE> <METADATA_FILE> <NUM_LOCATIONS> <TREE_LABEL> <OUTPUT_PREFIX>
#
# Notes:
# - Assumes the metadata file's first line is a header.
# - The script is designed to handle location data, which should be present in the third column of the metadata.
# - Ensure consistent and matching IDs between the NEWICK_TREE and METADATA_FILE.


NEWICK_TREE=$1
METADATA_FILE=$2
NUM_LOCATIONS=$3
TREE_LABEL=$4
OUTPUT_PREFIX=$5


ntax=$(tail -n +2 $METADATA_FILE|wc -l)
echo '#NEXUS'$'\n'$'\n''Begin DATA;'$'\n'$'\t''Dimensions NTAX='${ntax} 'NCHAR=1;'$'\n'$'\t''Format MISSING=? GAP=- DATATYPE=STANDARD SYMBOLS="'$(echo $(seq 0 $(($NUM_LOCATIONS - 1))))'";'$'\n'$'\t''Matrix'$'\n' > ${OUTPUT_PREFIX}.location_tree.nexus

tail -n +2 $METADATA_FILE |cut -f 1,3 >> ${OUTPUT_PREFIX}.location_tree.nexus

echo $'\t'';'$'\n'$'\n''END;' >> ${OUTPUT_PREFIX}.location_tree.nexus

echo Begin trees\;$'\n' >> ${OUTPUT_PREFIX}.location_tree.nexus
echo tree $TREE_LABEL \= $(cat $NEWICK_TREE) >> ${OUTPUT_PREFIX}.location_tree.nexus
echo $'\n''END;' >> ${OUTPUT_PREFIX}.location_tree.nexus


