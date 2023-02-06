#!/usr/bin/env Rscript
library(rjson)

args <- commandArgs(trailingOnly=T)
defaultW <- getOption("warn")
options(warn=-1)
options(warn=defaultW)
dfsir=fromJSON(file = args[1])
num_tips_sampled_per_sim <- as.numeric(strsplit(args[2], split = ",")[[1]])

time_points=0
if(length(args) == 3) time_points = as.numeric(strsplit(args[3], split = ",")[[1]])



# get stats from each location in each simulation
#time_step_size <- diff(dfsir[[1]][[1]]$t[1:2])
for(sim_num in seq(length(num_tips_sampled_per_sim))){
	infection_events_per_susceptable <- c()
	imports_per_capita <- c()
	time_of_first_infection <- c()
	var_names <- names(dfsir[[1]][[sim_num]])
	sim_runtime <- max(dfsir[[1]][[sim_num]]$t)
	num_I_at_time_points = rep(0, length(time_points))

	proportion_tips_subsampled <- num_tips_sampled_per_sim[sim_num] / rev(dfsir[[1]][[sim_num]]$D)[1]
	if(proportion_tips_subsampled > 1) proportion_tips_subsampled <- 1
	for(loc in (seq(dfsir[[1]][[sim_num]]$I))){

		# count up I at each time point of interest across all locations
		loc_I_t = sapply(seq(length(num_I_at_time_points)), 
				 function(time) dfsir[[1]][[sim_num]]$I[[loc]][which.min(abs(dfsir[[1]][[sim_num]]$t - time_points[time]))])

		num_I_at_time_points = num_I_at_time_points + loc_I_t	

		# for per capita calculations
		S0 <- dfsir[[1]][[sim_num]]$S[[loc]][1]
		
		# infections per capita
		num_infection_events <- S0 - dfsir[[1]][[sim_num]]$S[[loc]][length(dfsir[[1]][[sim_num]]$S[[loc]])]
		infection_events_per_susceptable[loc] <- num_infection_events / dfsir[[1]][[sim_num]]$S[[loc]][1]	

		# importations etc, per capita
		location_migration_var_idx <- which(var_names == paste0("M_into_", loc-1))

		imports_per_capita <- c(imports_per_capita, paste0(round(unlist(lapply(dfsir[[1]][[sim_num]][[location_migration_var_idx]],
                                                function(x) rev(x)[1] / S0)), digits = 5), collapse = ","))

		# timing of first infection
		infected_present_idx <- which(dfsir[[1]][[sim_num]]$I[[loc]] > 0)
		time_of_first_infection[loc] <- dfsir[[1]][[sim_num]]$t[infected_present_idx][1] #- 0.5 * time_step_size

		if(is.na(time_of_first_infection[loc])){
			time_of_first_infection[loc] <- -1
		}

	}
	cat(paste0(imports_per_capita, collapse = ":"), "\t")
	cat(paste0(round(infection_events_per_susceptable, digits = 8), collapse = ","), "\t")
	cat(paste0(round(time_of_first_infection, digits = 8), collapse = ","), "\t")
	cat(round(proportion_tips_subsampled, digits = 6), "\t")
	cat(paste0(time_points, collapse=","), "\t")
	cat(round(sim_runtime, digits = 8), "\t")
	cat(paste0(num_I_at_time_points, collapse=","),"\n")
}

