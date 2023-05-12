#!/usr/bin/env Rscript
library(coda)
args = commandArgs(trailingOnly = TRUE)

#ci = read.table(args[1], header = T, row.names = 1)
mcmc_log_file1 = read.table(args[1], header = T, row.names = 1)
mcmc_log_file2 = read.table(args[2], header = T, row.names = 1)
true_values1 = read.table(args[3], header = T, row.names = 1)
true_values2 = read.table(args[4], header = T, row.names = 1)
alpha = as.numeric(args[5])
outfile_prefix = args[6]

num_reps = nrow(true_values1)

if(num_reps != ncol(mcmc_log_file1)){cat("files don't match"); q()}
if(num_reps != ncol(mcmc_log_file2)){cat("files don't match"); q()}
if(num_reps != nrow(true_values2)){cat("files don't match"); q()}

centered_ci1 = HPDinterval(mcmc(mcmc_log_file1), prob = alpha) - true_values1[,1]
coverage1 = round(sum(centered_ci1[,1] < 0 & centered_ci1[,2] > 0) / num_reps, digits = 4)
centered_ci2 = HPDinterval(mcmc(mcmc_log_file2), prob = alpha) - true_values2[,1]
coverage2 = round(sum(centered_ci2[,1] < 0 & centered_ci2[,2] > 0) / num_reps, digits = 4)

pdf(file = paste0(outfile_prefix, "_HPD_", alpha, "_coverage1_", coverage1, "_coverage2_", coverage2,".pdf"))
plot(NULL, main = "", xlab = args[1], ylab = args[2], 
     xlim = c(min(centered_ci1), max(centered_ci1)), ylim = c(min(centered_ci2), max(centered_ci2)))
abline(h=0, v=0, col = "blue", lwd = 2)
for(i in seq(num_reps)){
	mid_x = centered_ci1[i,1] + (centered_ci1[i,2] - centered_ci1[i,1])/2
	mid_y = centered_ci2[i,1] + (centered_ci2[i,2] - centered_ci2[i,1])/2
	interval_color = ifelse(centered_ci1[i,1] > 0 | centered_ci1[i,2] < 0, "red", "black")
	arrows(x0 = centered_ci1[i,1], x1 = centered_ci1[i,2],
	       y0 = mid_y, y1 = mid_y, length = 0, lwd = 1, col = interval_color)
	interval_color = ifelse(centered_ci2[i,1] > 0 | centered_ci2[i,2] < 0, "red", "black")
        arrows(x0 = mid_x, x1 = mid_x,
	       y0 = centered_ci2[i,1], y1 = centered_ci2[i,2], length = 0, lwd = 1, col = interval_color)

}

dev.off()

#print(centered_ci)
#write.table(centered_ci, file = paste0(outfile_prefix, "_alpha_", alpha, "_coverage_", coverage, ".tsv"), quote = F)
