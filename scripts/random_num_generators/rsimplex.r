#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = T)

alpha = as.numeric(strsplit(args[1], split = "," )[[1]])

mygamma <- rgamma(length(alpha), shape = alpha, rate = 1)

cat(mygamma/sum(mygamma), '\n')
