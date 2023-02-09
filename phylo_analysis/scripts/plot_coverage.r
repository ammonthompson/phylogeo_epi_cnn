#!/usr/bin/env Rscript

#library(modeest)
library(coda)
args = commandArgs(trailingOnly = TRUE)

#ci = read.table(args[1], header = T, row.names = 1)
mcmc_log_file = read.table(args[1], header = T, row.names = 1, fill = T)
true_values = read.table(args[2], header = T, row.names = 1)
alpha = round(as.numeric(args[3]), digits = 2)
outfile_prefix = args[4]

num_reps = nrow(true_values)

if(num_reps != ncol(mcmc_log_file)){cat("files don't match"); q()}

centered_ci = 100 * (t(apply(mcmc_log_file, 2, function(x) HPDinterval(mcmc(x), prob = alpha))) - true_values[,1]) / true_values[,1]

coverage = round(sum(centered_ci[,1] < 0 & centered_ci[,2] > 0) / num_reps, digits = 4)



pdf(file = paste0(outfile_prefix, "_HPD_", alpha, "_coverage_", coverage, ".pdf"))
plot(NULL, main = "", xlab = "true value", ylab = "percent error intervals", xlim = c(min(true_values[,1]), max(true_values[,1])), ylim = c(min(centered_ci), max(centered_ci)))
for(i in seq(num_reps)){
	interval_color = ifelse(centered_ci[i,1] > 0 | centered_ci[i,2] < 0, "red", "black")
	arrows(x0 = true_values[i,1], y0 = centered_ci[i,1], y1 = centered_ci[i,2], length = 0, lwd = 2, col = interval_color)
	points(true_values[i,1], 100 * (mean(mcmc_log_file[,i], na.rm = T) - true_values[i,1])/true_values[i,1], pch = 18, cex =1, col = "blue")
	#points(i, 100 * (asselin(mcmc_log_file[,i], na.rm = T) - true_values[i,1])/true_values[i,1], pch = 18, cex = 1, col = "green")
}
abline(h=0, col = "red", lwd = 2)

dev.off()

#print(centered_ci)
write.table(matrix(c("file_name", "true_minus_lower", "true_minus_upper", "true_values"), nrow = 1), file = paste0(outfile_prefix, "_HPD_", alpha, "_coverage_", coverage, ".tsv"), 
	    sep = "\t", col.names = F, row.names = F, quote = F)
write.table(cbind(centered_ci, true_values), file = paste0(outfile_prefix, "_HPD_", alpha, "_coverage_", coverage, ".tsv"), 
	    sep="\t",quote = F, append = T, col.names = F)
