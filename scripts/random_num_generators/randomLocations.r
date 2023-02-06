#!/usr/bin/env Rscript
options(scipen = 100)

# $1 is the number of locations
# followed by the x ranges and y ranges respectively

args = commandArgs(trailingOnly = T)

num_locs = as.numeric(args[1])

x_low = as.numeric(args[2])
x_high = as.numeric(args[3])
y_low = as.numeric(args[4])
y_high = as.numeric(args[5])

max_over_min <- 1 
while(max_over_min < (num_locs)){
	x_coords <- round(runif(num_locs, x_low, x_high), digits = 3)
	y_coords <- round(runif(num_locs, y_low, y_high), digits = 3)
	d <- dist(cbind(x_coords, y_coords))
	max_over_min <-  max(d) / min(d)
}

cat(paste(x_coords, collapse = ","))
cat("\n")
cat(paste(y_coords, collapse = ","))
cat("\n")
cat("\n")
cat(min(d))
