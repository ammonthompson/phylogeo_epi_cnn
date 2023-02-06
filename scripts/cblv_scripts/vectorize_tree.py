#!/usr/bin/env python3
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
