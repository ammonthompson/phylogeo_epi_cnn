#!/usr/bin/env Rscript
options(scipen = 100)
args = commandArgs(trailingOnly = TRUE)

num_sample = as.numeric(args[1])
set = unlist(strsplit(args[2], split = ','))

cat(sample(set, num_sample, replace = TRUE, rep(1, length(set))))
cat('\n')
