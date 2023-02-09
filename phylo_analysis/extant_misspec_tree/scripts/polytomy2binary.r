#!/usr/bin/env Rscript
library(phytools)
args = commandArgs(trailingOnly = T)
in_tree = args[1] # NEXUS
ref_tree = args[2]
tree_out = args[3]

tree_out = sub(".nexus", "", tree_out)
tree_out = sub(".newick", "", tree_out)
tree_out = sub(".nxs", "", tree_out)
tree_out = sub(".nwk", "", tree_out)

in_tree = read.nexus(in_tree)
ref_tree = read.nexus(ref_tree)

# get tip labels that are extant from ref_tree
ref_height=round(nodeHeights(ref_tree), digits = 4)
extant_time = max(ref_height)
extant_tips_edge_number = ref_tree$edge[,2][which(ref_height[,2] == extant_time)]
extant_tips = ref_tree$tip.label[extant_tips_edge_number]

#resolv polytomeies
fixtree = multi2di(in_tree, random = FALSE)
bl0_idx = which(fixtree$edge.length == 0)
fixtree$edge.length[bl0_idx] <- runif(length(bl0_idx), 0.01, 0.02)
fix_extant_time = max(nodeHeights(fixtree))


if(length(extant_tips) > 0){
	for(extant_tip_name in extant_tips){
		extant_tip_node_num = which(fixtree$tip.label == extant_tip_name)
		extant_edge_matrix_idx = which(fixtree$edge[,2] == extant_tip_node_num)
	 	fixtree$edge.length[extant_edge_matrix_idx] <- fixtree$edge.length[extant_edge_matrix_idx] -
			(nodeheight(fixtree, extant_tip_node_num) - fix_extant_time)
	
	}
}


# write new tree files
write.tree(fixtree, file = paste0(tree_out, ".newick"))
ape::write.nexus(fixtree, file = paste0(tree_out, ".nexus"), translate = F)

