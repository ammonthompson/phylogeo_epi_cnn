#!/bin/bash

# A wrapper script for the Seq-Gen program V1.3.2 that simulates the evolution of DNA sequences
# along phylogenetic trees. This script takes Newick tree files produced by MASTER
# simulations, splits them, and simulates sequence alignments for each tree.
#
# Models and Assumptions:
# - Assumes a HKY (Hasegawa-Kishino-Yano) model of nucleotide substitution.
# - Four gamma rate categories.
# - Transitions/transversions ratio of 2.0.
# - Equally frequent nucleotide frequencies (0.25 for each A, T, C, G).
#
# Parameters:
# $1 - Input Newick tree file produced by MASTER simulations.
# $2 - Output file prefix.
#
# Output:
# - Produces simulated sequence alignments for each input tree, saved as Nexus files.
# - Generates a log file capturing any errors or messages from Seq-Gen.
#
# Dependencies:
# - Requires Seq-Gen V1.3.2.
#
# Usage:
# ./seqgen.sh <newick_tree_file> <output_prefix>
#
# Notes:
# - This script uses specific naming conventions for intermediate files, which are 
#   cleaned up at the end. Ensure that no other files with the same naming patterns 
#   exist in the working directory to avoid unintended deletions.
#


# output tree files from MASTER sims
newick_tree_file=$1
output_prefix=$2

scale=0.001
seq_length=200

# split newick tree file
split -l 1 -d $newick_tree_file ${output_prefix}_33temp_tree_342423425532aa.

# simulate alignment
for sim_num in $(ls ${output_prefix}_33temp_tree_342423425532aa* |sed 's:'${output_prefix}_33temp_tree_342423425532aa.'::g');do
	seq-gen -s$scale -a2 -g4 -mHKY -t2.0 -f0.25,0.25,0.25,0.25 -l$seq_length -n1 -on < ${output_prefix}_33temp_tree_342423425532aa.$sim_num > \
		$output_prefix.sim${sim_num}.alignment.nexus 2>> $output_prefix.log
done

rm ${output_prefix}_33temp_tree_342423425532aa.* #${output_prefix}_44temp_tree_2937402938756984xx.*
