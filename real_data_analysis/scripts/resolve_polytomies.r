#!/usr/bin/env Rscript
library(phytools)
args = commandArgs(trailingOnly = T)
tree_in = args[1] # NEXUS
tree_out = args[2]

tree_out = sub(".nexus", "", tree_out)
tree_out = sub(".newick", "", tree_out)
tree_out = sub(".nxs", "", tree_out)
tree_out = sub(".nwk", "", tree_out)

tree = read.nexus(tree_in)

fixtree = multi2di(tree, random = FALSE)
bl0_idx = which(fixtree$edge.length == 0)
fixtree$edge.length[bl0_idx] <- runif(length(bl0_idx), 0.0001, 0.0002)
write.tree(fixtree, file = paste0(tree_out, ".newick"))
ape::write.nexus(fixtree, file = paste0(tree_out, ".nexus"), translate = F)
