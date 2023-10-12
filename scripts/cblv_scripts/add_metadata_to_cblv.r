#!/usr/bin/env Rscript

# This R script processes and combines a given encoded tree's vectorized 
# representation (CBLV) with associated metadata (tip states) to generate a 
# matrix with one-hot encoded tip data and certain subsample proportion 
# information. The combined matrix is then flattened and printed.
#
# The purpose of this script is to enrich the CBLV representation with relevant 
# metadata, facilitating a deeper understanding and analysis of the tree and its 
# associated data.
#
# Input:
# 1. TIP_STATES_FILE: File containing tip state data.
# 2. NEW_ORDER_FILE: Temporary file containing ordered tip labels from the encoded tree.
# 3. CBLV_FILE: File containing the vectorized representation of the tree.
# 4. PROPORTION_SUBSAMPLED: Proportion of the data that has been subsampled.
# 5. OUT_FILE_PREFIX: Prefix for output files (currently unused, but available for extensions).
# 6. MAX_NUM_LOCATIONS: Maximum number of locations for one-hot encoding.
#
# Output:
# The script prints a comma-separated flattened matrix to standard output, 
# which combines the CBLV data with one-hot encoded metadata.
#
# Steps:
# 1. Read the CBLV data and transform it into a matrix.
# 2. Read and reorder the tip states based on the new order from the encoded tree.
# 3. One-hot encode the reordered tip state data.
# 4. Augment the CBLV matrix with the proportion subsampled and combine it 
#    with the one-hot encoded matrix.
# 5. Flatten the combined matrix and print.
#
# Dependencies:
# This script relies on R's standard libraries.
#
# Note:
# This script works best when the tip states file, CBLV file, and new order 
# file are well-aligned. Mismatches might lead to inaccurate encoding or data loss.


MAX_NUM_LOCATIONS = 5
ARGS = commandArgs(trailingOnly = T)


TIP_STATES_FILE = ARGS[1]
NEW_ORDER_FILE = ARGS[2]
CBLV_FILE = ARGS[3]
PROPORTION_SUBSAMPLED=ARGS[4]
OUT_FILE_PREFIX = ARGS[5]
MAX_NUM_LOCATIONS = as.numeric(ARGS[6])

# read in cblv file and make into matrix
cblv = read.table(CBLV_FILE, header = F, sep = " ")
cblv = matrix((cblv), ncol=2, byrow=F)
cblv <- rbind(cblv, c(0,0))
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
cblv[MAX_SIZE, 1:2] <- c(rep(PROPORTION_SUBSAMPLED, 2))

# add cblv to onehot matrix
combined_onehot_cblv_matrix = cbind(cblv, t(onehot_ordered_data))
flattened_combined_onehot_cblv_matrix = as.vector(t(combined_onehot_cblv_matrix))

# write files
cat(paste(flattened_combined_onehot_cblv_matrix, collapse=","))
#write.table(matrix(flattened_combined_onehot_cblv_matrix, nrow =1), file = paste0(OUT_FILE_PREFIX, ".cblv"), col.names = F, row.names = F, quote = F, append = T)
