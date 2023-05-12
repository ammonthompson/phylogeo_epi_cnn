#!/usr/bin/env Rscript

#input mcmc log file. Outputs args[2]

library(coda)

args = commandArgs(trailingOnly = TRUE)

posterior_file = read.table(args[1], header = T, row.names = 1)

ess = as.numeric(apply(posterior_file, 2, function(x)  effectiveSize(as.mcmc(x))))


#if(min(ess) == 0 ) cat("parameter: ", colnames(posterior_file)[which(ess == 0)], " variance = 0, removing from further analysis\n\n")


outmatrix = cbind(colnames(posterior_file), round(ess, digits = 1))
outmatrix = rbind(c("gene", "ESS"), outmatrix)



write.table(outmatrix, file = args[2], row.names = F, col.names = F, quote = F, sep = "\t")
