#!/usr/bin/env Rscript
library(phytools)



ref_tree = read.nexus(args[1])

trans_tree = read.nexus(args[2])

extant_time = as.numeric(args[3])

extant_tips = ref_tree$tip.label[which(
