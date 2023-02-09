#!/bin/bash

for i in alignment_files/*;do 
	iqtree --fast -s $i --date time_files/$(basename $i |cut -d '.' -f 1)_rep0_metadata.subsample.tsv.times --prefix $(basename $i |cut -d '.' -f 1) -m "JC" 
done
