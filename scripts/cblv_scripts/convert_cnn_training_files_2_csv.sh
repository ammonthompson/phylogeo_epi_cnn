#!/bin/bash
cblv_file=$1
param_label_file=$2
sed 's/ /,/g' $cblv_file > $cblv_file.csv
paste <(cut -f 2 $param_label_file) <(cut -f 3,7,9,10 $param_label_file|sed -r 's/,[^\t]+//g')|sed 's/\t/,/g' > $param_label_file.csv
