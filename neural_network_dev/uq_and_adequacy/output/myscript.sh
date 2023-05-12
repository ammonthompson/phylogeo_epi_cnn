#!/bin/bash
rownames=$1
preds=$2
uq=$3

for i in 1 2 3;do 
	paste $rownames <(cut -f $i $preds) <(cut -f $((i*2 - 1)),$((i*2)) $uq ) > cnn_95_$(head -n 1 $uq |cut -f $((i*2)) |sed 's/\t/_/g'|sed 's/_lq//g')_$preds
 done
