#!/usr/bin/env python3
import sys
from Bio.Phylo.TreeConstruction import DistanceCalculator
from Bio import AlignIO
from Bio.Phylo.TreeConstruction import DistanceTreeConstructor
from Bio import Phylo


nexus_alignment_file = sys.argv[1]
outfile = sys.argv[2]



aln = AlignIO.read(nexus_alignment_file, 'nexus')

calculator = DistanceCalculator('identity')
dm = calculator.get_distance(aln)

constructor = DistanceTreeConstructor(calculator, 'nj')
tree = constructor.build_tree(aln)
tree.root_at_midpoint()
Phylo.write(tree, outfile, "newick")
