#!/bin/bash
infile=$1
mv $infile ${infile}.temp1
nrow=$(wc -l ${infile}.temp1 |cut -d ' ' -f 1)
echo $nrow
paste <(echo row_names $(seq 1 $(( nrow - 1))) |sed -r "s/[ \t]+/\n/g") ${infile}.temp1 > $infile
rm $infile.temp1
