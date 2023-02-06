#!/usr/bin/env Rscript

# script for making the MASTER sim approximation of a mass-sampling event exact

# $1 rooted newick  $2 trunc time $3 outfile
# note: this assumes no internal nodes have heights > trunctime

library(phytools, quietly = T, verbose = F)
args = commandArgs(trailingOnly = T)
tree = read.tree(args[1])
trunctime = as.numeric(args[2])
outfile = args[3]

trunc_idx = which(tree$root.edge + nodeHeights(tree)[,2] > trunctime)
if(length(trunc_idx) > 0){
	tree$edge.length[trunc_idx] = tree$edge.length[trunc_idx] - (tree$root.edge + nodeHeights(tree)[trunc_idx,2] - trunctime)
}
write.tree(tree, file = outfile)
