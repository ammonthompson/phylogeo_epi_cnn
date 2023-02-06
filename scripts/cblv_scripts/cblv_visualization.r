#!/usr/bin/env Rscript
## visualize cblv files
args <- commandArgs(trailingOnly = T)
cblv_file <- args[1]
out_file <- args[2]
num_locations <- 5

if(length(args) == 3) num_locations <- args[3]

if(grepl('pdf', out_file)) out_file <- gsub(".pdf", "", out_file)

treefile = as.matrix(read.csv(cblv_file, header = F))
num_tips <- 1/(2+num_locations) * ncol(treefile)

row1_idx <- c(seq(num_tips-1) * (2 + num_locations) - (2 + num_locations)) + 1
row2_idx <- c(seq(num_tips-1) * (2 + num_locations) - (2 + num_locations)) + 2
pdf(paste0(out_file, ".pdf"))
for(i in seq(nrow(treefile))){
	# fold into N X 2 matrix
	cblv <- rbind(treefile[i,row1_idx], treefile[i,row2_idx])
	max_internal_cblv = max(cblv[1,])
	tree_num_columns = which(colSums(cblv) == 0)[1] - 1

	# plot tip values in blue, top row and internal nodes in red bottom row
#	pdf(paste0(out_file, "_line_", i, ".pdf"))

	plot(NULL, xlim =c(1,tree_num_columns), ylim = c(0,max_internal_cblv + max(cblv[2,])),	
	main = paste0("line num: ", i))
	for(i in 1:tree_num_columns){
  
	  	# plot tips (row 2)
  		arrows(i,max_internal_cblv, i, max_internal_cblv + cblv[2,i], col = "blue", length = 0)
  
  		# plot internal nodes (row 1)
  		arrows(i, 0, i, cblv[1,i], col = "red", length = 0)
	}
}
dev.off()
#plot(t(cblv))
