#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = T)

library(phytools, quietly = T)

tree = read.tree(args[1])

cat(max(nodeHeights(tree)), "\t", mean(tree$edge.length), "\n")
