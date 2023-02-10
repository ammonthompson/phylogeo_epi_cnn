#!/usr/bin/env Rscript
library(rjson)
args <- commandArgs(trailingOnly=T)
defaultW <- getOption("warn")
options(warn=-1)
control_file <- read.table(args[1], row.names = 1)
options(warn=defaultW)
dfsir=fromJSON(file = args[2])
out_prefix <- args[3]
num_locs = as.numeric(control_file[row.names(control_file) == "NUMBER_LOCATIONS", 1])
legend_text = paste0("loc. ", seq(num_locs)-1)
mycolors = rainbow(num_locs)

#  make population relative distance plot
if("GEO_POSITION_X" %in% row.names(control_file)){
	geox_string <- control_file[row.names(control_file) == "GEO_POSITION_X", 1]
	geoy_string <- control_file[row.names(control_file) == "GEO_POSITION_Y", 1]
	geox <- as.numeric(strsplit(geox_string, split = ",")[[1]])
	geoy <- as.numeric(strsplit(geoy_string, split = ",")[[1]])
	# make population relative distance plot
	pdf(file = paste0(out_prefix, "_locations.pdf"))
	#layout(matrix(seq(2), ncol = 1))
	for(sim_num in seq(length(dfsir[[1]]))){
   		plot(geox, geoy, col = mycolors, pch = 16, cex = 2, axes = F)
	}
	text(geox, geoy, legend_text, pos = 1, cex = 0.75)
	dev.off()
}

# num infected thru time
pdf(file = paste0(out_prefix, "_I_population_plots.pdf"))

for(sim_num in seq(length(dfsir[[1]]))){
   plot(dfsir[[1]][[sim_num]]$t, dfsir[[1]][[sim_num]]$I[[1]],
     ylim = c(0, max(unlist(dfsir[[1]][[sim_num]]$I))),
     main = paste0("sim ", sim_num-1), type = "l", col = mycolors[1],xlab = "time", ylab = "number infected")

   for(loc in (seq(dfsir[[1]][[sim_num]]$I)[-1])){
      lines(dfsir[[1]][[sim_num]]$t, dfsir[[1]][[sim_num]]$I[[loc]],
            col= mycolors[loc])

   }
legend(x = 0, y = max(unlist(dfsir[[1]][[sim_num]]$I)), legend = legend_text, col = mycolors[1:num_locs], lty=1, lwd = 2, cex = 0.75)
}
dev.off()

# make susceptable through time plot
pdf(file = paste0(out_prefix, "_S_population_plots.pdf"))

for(sim_num in seq(length(dfsir[[1]]))){
   plot(dfsir[[1]][[sim_num]]$t, dfsir[[1]][[sim_num]]$S[[1]],
     ylim = c(0, max(unlist(dfsir[[1]][[sim_num]]$S))),
     main = paste0("sim ", sim_num-1), type = "l", col = "red", xlab = "time", ylab = "number susceptable")


   for(loc in seq(dfsir[[1]][[sim_num]]$S)[-1]){
     lines(dfsir[[1]][[sim_num]]$t, dfsir[[1]][[sim_num]]$S[[loc]],
            col= mycolors[loc])

   }
legend(x = 0, y = max(unlist(dfsir[[1]][[sim_num]]$S)), legend = legend_text, col = mycolors[1:num_locs], lty=1, lwd = 2, cex = 0.75)
}
dev.off()
