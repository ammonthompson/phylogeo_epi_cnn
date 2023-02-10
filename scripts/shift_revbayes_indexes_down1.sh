#!/bin/bash

logfile=$1
header=($(head -n 1 $logfile))
declare -a newheader
for i in ${header[@]};do
	number=$(echo $i |grep -Eo '\[[0-9]+\]' |sed 's/\[//'|sed 's/\]//')
	newnumber=$((number-1))
	newheader+=($(echo $i |sed 's/\['$number'\]/\['$newnumber'\]/'))
done
echo ${newheader[@]}

sed -i  $(echo "1s/.*/"$(echo ${newheader[@]} |sed 's/ /\\t/g')"/g") $logfile

