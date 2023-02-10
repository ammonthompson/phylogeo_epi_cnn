#!/usr/bin/env Rscript
options(scipen = 100)

args = commandArgs(trailingOnly = T)

number=as.numeric(args[1])
maxnumber=as.numeric(args[2])

onehot = c(rep(0, number-1), 1, rep(0, maxnumber-number))

cat(onehot)
cat('\n')
