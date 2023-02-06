library(phytools)
tree = read.tree("sim1.collapsedSingletons.newick")
tree$edge.length
tree$tip.label
tree$edge
ls
for(i in 1:135){
tree$edge.length[which(tree$edge[,2] == i)] = i/2
}
cbind(tree$edge, tree$edge.length)
tree$edge.length[which(tree$edge[,2] == i)] = (135 - i)/2
cbind(tree$edge, tree$edge.length)
tree$edge.length[which(tree$edge[,2] == i)] = (136 - i)/2
cbind(tree$edge, tree$edge.length)
for(i in 1:135){
tree$edge.length[which(tree$edge[,2] == i)] = (136 - i)/2
}
cbind(tree$edge, tree$edge.length)
write.tree(tree, file = "sim1_testree_ascending_blengths.newick")
q()
