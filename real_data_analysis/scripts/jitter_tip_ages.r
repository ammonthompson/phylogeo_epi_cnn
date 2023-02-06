#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = T)

tree = ape::read.nexus(args[1])

tree_height = max(phytools::nodeHeights(tree))

node_depth = phytools::nodedepth.edgelength(tree)

# find nodes with identical node depths

node_idx_duplicate_depths = which(table(node_depth) > 1)

branch_idx_duplicate_depths = which(tree$edges[,2] %in% node_idx_duplicate_depths)

# jitter duplicates (small scale change to branch length subtending node)
tree$edge.lengths[branch_idx_duplicate_depths] <- tree$edge.lengths[branch_idx_duplicate_depths] * 
runif(length(branch_idx_duplicate_depths), 0.00001 * tree_height, 0.0001 * tree_height)

# write tree file
ape::write.nexus(tree, file = args[2], translate = T)



