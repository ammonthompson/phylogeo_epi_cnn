#!/bin/bash
location_tree_file=$1

while read line;do 
	loc=$(echo $line|sed -r 's/[ \t]+/\t/g'|cut -f 2); 
	sp=$(echo $line|cut -d ' ' -f 1);  \
	sed -r -i 's/([\(,])'$sp':/\1'${sp}'[\&loc='$loc']:/g' $location_tree_file 
done < <(grep '^[0-9]' $location_tree_file)
