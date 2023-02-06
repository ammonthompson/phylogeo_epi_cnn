#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = T)

intree = args[1] # NEXUS tree with branches in units of years
outtree = args[2]
scale_factor = as.numeric(args[3])

jitter = 0
if(args[4] == "TRUE" || args[4] == "T"){
	jitter = 1
	print("jittering\n")
}

if( grepl('nexus', basename(intree))){
	tree = ape::read.nexus(intree)
}else if(grepl('newick', basename(intree))){
	tree = ape::read.tree(intree)
}else if(grepl('nwk', basename(intree))){
	tree = ape::read.tree(intree)
}else{
	cat('unsuported tree file\n')
	q()
}

tree$edge.length <- tree$edge.length * scale_factor + jitter * runif(length(tree$edge.length), 0.000001, 0.0001)

ape::write.tree(tree, outtree)
