#!/bin/bash
# cd into direcotry containing 2 subdirectories: alignment_files/ and time_files/
# time files should have no header and 2 columns:  species and sample times

for i in alignment_files/*;do 
	iqtree --fast -s $i --date time_files/$(basename $i |cut -d '.' -f 1)_rep0_metadata.tsv.times --prefix $(basename $i |cut -d '.' -f 1) -m "JC" 
done
