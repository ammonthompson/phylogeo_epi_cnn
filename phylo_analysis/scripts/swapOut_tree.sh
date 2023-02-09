#!/bin/bash
tree_location_file=$1
new_tree_newick_file=$2
cat  <(sed -n '/NEXUS/,/trees/p' $tree_location_file) <(echo TREE tree_0 \= $(grep '^(' $new_tree_newick_file))\
	<(echo END\;)
