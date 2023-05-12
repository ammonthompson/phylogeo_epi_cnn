#!/usr/bin/env Rscript
library(coda)
args=commandArgs(trailingOnly = TRUE)

# 1 is the data file
# 2 is the inner quantile e.g. 0.5 for 50%, 0.95 for 95%

dat = read.table(args[1], header = TRUE, row.names = 1)
alpha = as.numeric(args[2])

#ci = sapply(seq(ncol(dat)), function(x){quantile(dat[,x], prob=c(0.5 - alpha/2, 0.5 + alpha/2)) })
ci = sapply(seq(ncol(dat)), function(x){HPDinterval(mcmc(dat[,x]), prob = alpha)[1:2] })

colnames(ci) = colnames(dat)

write.table(ci, file = paste0(args[1],"_",args[2], ".ci"), col.names=NA, row.names = c("lower", "upper"), sep = "\t", quote=FALSE)

cat("Wrote file to ", paste0(args[1],"_",args[2],  ".ci"), "\n")
