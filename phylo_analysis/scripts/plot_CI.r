#!/usr/bin/env Rscript

# $1 = ci
# $2 = rownames (T/F)
# $3 = true values
# $4 = rownames (T/F)
# $5 = outfile prefix

args = commandArgs(trailingOnly = T)

if(args[2] == "T"){
	ci = read.table(args[1], header = T, row.names = 1)
}else{
	ci = read.table(args[1], header = T, row.names = NULL)
}

if(args[4] == "T"){
	true_values = read.table(args[3], header = T, row.names = 1)
}else{
	true_values = read.table(args[3], header = T, row.names = NULL)
}
outfile_prefix = args[5]

centered_ci = ci[,1:2] - true_values[,1] 


pdf(file = paste0(outfile_prefix, ".pdf"))
plot(NULL, main = "", xlab = "true value", ylab = "Interval", xlim = c(min(true_values[,1]), max(true_values[,1])), ylim = c(min(centered_ci), max(centered_ci)))
for(i in seq(nrow(ci))){
        interval_color = ifelse(centered_ci[i,1] > 0 | centered_ci[i,2] < 0, "red", "black")
        arrows(x0 = true_values[i,1], y0 = centered_ci[i,1], y1 = centered_ci[i,2], length = 0, lwd = 2, col = interval_color)
}
abline(h=0, col = "red", lwd = 2)

dev.off()


