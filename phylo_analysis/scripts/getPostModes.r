#!/usr/bin/env Rscript
library(modeest)
args = commandArgs(trailingOnly = T)

dat = read.table(args[1], header = T, row.names =1, fill = T)
out_file = args[2]

modes = apply(dat, 2, function(x) asselin(x))

write.table(cbind(colnames(dat), modes), file = out_file, quote = F, sep = "\t", row.names = F, col.names = c("file", "mode"))
#cat(cbind(colnames(dat), modes))

