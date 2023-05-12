#!/bin/bash

# cd into directory with .ess files to run
echo file_name$'\t'lowest_ESS > lowest_ess.txt
for i in $(ls *.ess|sort -V);do 
	echo $(basename $i)$'\t'$(cut -f 2 $i|grep -v '^0$' |sort -h|tail -n +2|head -n 1) >> lowest_ess.txt.temp
done
sort -k 2 -h lowest_ess.txt.temp >> lowest_ess.txt
rm lowest_ess.txt.temp
