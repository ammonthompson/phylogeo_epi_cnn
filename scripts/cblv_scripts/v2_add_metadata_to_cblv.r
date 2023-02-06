#!/usr/bin/env Rscript


MAX_NUM_LOCATIONS = 5
ARGS = commandArgs(trailingOnly = T)


TIP_STATES_FILE = ARGS[1]
NEW_ORDER_FILE = ARGS[2]
CBLV_FILE = ARGS[3]
PROP_NTIPS_TREELEN_MEANBL = as.numeric(strsplit(ARGS[4], ",")[[1]])
#PROPORTION_SUBSAMPLED=ARGS[4]
OUT_FILE_PREFIX = ARGS[5]
MAX_NUM_LOCATIONS = as.numeric(ARGS[6])

num_prior_stats = length(PROP_NTIPS_TREELEN_MEANBL)

# read in cblv file and make into matrix
cblv = read.table(CBLV_FILE, header = F, sep = " ")
cblv = matrix((cblv), ncol=2, byrow=F)
cblv <- rbind(cblv, matrix(rep(0, 2 * num_prior_stats), ncol = 2))
MAX_SIZE = nrow(cblv)

# read in tip data and new order file
tip_states = read.table(TIP_STATES_FILE, header = TRUE, row.names = 1)
new_order = read.csv(NEW_ORDER_FILE, header = FALSE)

#reorder_tip_data
new_tip_states = c()
for(i in seq(new_order[,1])){
	new_tip_states = append(new_tip_states, tip_states$location[which(row.names(tip_states) == new_order[i,1])])
}
new_tip_states = new_tip_states + 1

# one hot the tip data; row 1 is location 0, row 2 location 1 etc...
onehot_ordered_data = matrix(0, nrow = MAX_NUM_LOCATIONS, ncol = MAX_SIZE)

invisible(sapply(seq(new_tip_states), function(idx) onehot_ordered_data[new_tip_states[idx],idx] <<- 1))

# add PROPORTION_SUBASMPLED to cblv vector
cblv[(MAX_SIZE - num_prior_stats):MAX_SIZE, c(1,2)] = cbind(PROP_NTIPS_TREELEN_MEANBL, PROP_NTIPS_TREELEN_MEANBL)

#cblv[MAX_SIZE, 1:2] <- c(rep(PROPORTION_SUBSAMPLED, 2))

# add cblv to onehot matrix
combined_onehot_cblv_matrix = cbind(cblv, t(onehot_ordered_data))
flattened_combined_onehot_cblv_matrix = as.vector(t(combined_onehot_cblv_matrix))

# write files
cat(paste(flattened_combined_onehot_cblv_matrix, collapse=","))
#write.table(matrix(flattened_combined_onehot_cblv_matrix, nrow =1), file = paste0(OUT_FILE_PREFIX, ".cblv"), col.names = F, row.names = F, quote = F, append = T)
