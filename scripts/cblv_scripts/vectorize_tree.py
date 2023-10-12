#!/usr/bin/env python3

# This script reads a phylogenetic tree and processes it to generate a vectorized
# representation using encoding. Specifically, it utilizes the tree utilities
# and encoding functions from the 'ammon_tree_utilities' and 'ammon_encoding'
# modules to convert the tree structure into a vector representation. This 
# vectorized representation captures various aspects of the tree, like the
# structure and relationships between the tree's tips.
#
# The script also maintains and outputs the order of tip labels in the encoded
# tree. This information can be useful in subsequent processes where alignment 
# between the original and encoded tree is necessary.
#
# Input:
# 1. Tree file: Path to the file containing the tree structure.
# 2. Sampling probability: The probability of sampling (can influence the
#    encoding process).
# 3. Output filename prefix: Prefix for the temporary file that will store the 
#    ordered list of tip labels.
#
# Output:
# The script outputs the vectorized representation of the tree to the standard 
# output. Additionally, it writes the ordered list of tip labels from the encoded
# tree to a temporary file named "{output_filename_prefix}_tip_order_in_output.temp".
#
# Dependencies:
# - Numpy: Library for numerical operations in Python.
# - ammon_tree_utilities and ammon_encoding: Custom modules derived from 
#	Phylodeep (Voznica et al. 2022) for tree operations and encoding.


import sys
#from phylodeep import tree_utilities as tu
import ammon_tree_utilities as tu
#from phylodeep import encoding as en
import ammon_encoding as en
import numpy as np

tree = tu.read_tree_file(sys.argv[1])
#print(tree)
ordered_tip_names = []
for i in tree.get_leaves():
	ordered_tip_names.append(i.name)

vv = en.encode_into_most_recent(tree, sampling_proba = sys.argv[2])

otn = np.asarray(ordered_tip_names) # ordered list of the input tip labels
vv2 = np.asarray(vv[2]) # ordered list of the new tip labels

new_order = [vv[3][i] for i in vv2]

filename = sys.argv[3] + "_tip_order_in_output.temp"
with open(filename, 'w') as f:
	f.writelines("%s\n" % tip_label for tip_label in new_order)

vvlist = vv[0].values.tolist()
print(*vvlist)
