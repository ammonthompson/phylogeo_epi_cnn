#!/usr/bin/env Rscript
options(scipen = 100)

args = commandArgs(trailingOnly = T)

onehot=as.numeric(strsplit(args[1], split = ",")[[1]])

num = which(onehot == 1)

cat(num)
cat('\n')
