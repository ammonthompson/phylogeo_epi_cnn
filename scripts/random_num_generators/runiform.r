#!/usr/bin/env Rscript
options(scipen = 100)
args = commandArgs(trailingOnly = TRUE)

num_sample = as.numeric(args[1])

range = as.double(unlist(strsplit(args[2], split = ',')))

cat(round(runif(num_sample, range[1], range[2]), digits=12))
cat('\n')
