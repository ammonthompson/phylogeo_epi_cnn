#!/bin/bash


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


