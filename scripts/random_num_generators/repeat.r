#!/usr/bin/env Rscript
options(scipen = 100)
args = commandArgs(trailingOnly = TRUE)

value = as.numeric(args[1])

num_sample = as.numeric(args[2])

cat(round(rep(value, num_sample), digits=5))
cat('\n')
