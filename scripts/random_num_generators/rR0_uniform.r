#!/usr/bin/env Rscript
options(scipen = 100)
args = commandArgs(trailingOnly = TRUE)

num_sample = as.numeric(args[1])

range = as.double(unlist(strsplit(args[2], split = ',')))

max_dif = as.numeric(args[3])

midpoint = runif(1, range[1] + max_dif/2, range[2] - max_dif/2)

subrange = c(max(range[1], midpoint - max_dif/2), min(range[2], midpoint + max_dif/2))

cat(round(runif(num_sample, subrange[1], subrange[2]), digits=12))
cat('\n')
