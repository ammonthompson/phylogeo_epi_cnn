#!/usr/bin/env Rscript
library(phytools, verbose = F, quietly = T)

args = commandArgs(trailingOnly = T)
num_time_points = as.numeric(args[1])
max_time = as.numeric(args[2])

tree_nexus_files = args[3:length(args)]

get_num_lineages = function(time, ltt_plot){
	return(ltt_plot[max(which(ltt_plot[,1] < time)),2])
}

cat(seq(num_time_points) * max_time/num_time_points, "\n")

for(tree_nexus_file in tree_nexus_files){
	time_num_lin = c()
	tree = read.nexus(tree_nexus_file)
	tree_ltt = ltt(tree, plot = F, gamma = F)
	tree_ltt = cbind(tree_ltt$times, tree_ltt$ltt)

	for(i in seq(num_time_points)){

		time_pt = i * max_time/num_time_points
		time_num_lin = rbind(time_num_lin, get_num_lineages(time_pt, tree_ltt))

	}
#	cat(time_num_lin[,1], "\n")
	cat(tree_nexus_file, time_num_lin, "\n")

}
