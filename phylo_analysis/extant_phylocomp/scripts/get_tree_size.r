#!/usr/bin/env Rscript

library(phytools, quietly = T)
args = commandArgs(trailingOnly = T)
tree = read.nexus(args[1])
cat(sum(tree$edge.length), "\n")
