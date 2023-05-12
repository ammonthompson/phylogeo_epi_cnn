#!/bin/bash
#takes in a list of location tree files
while [[ -n $1 ]];do
	infile=$1 
	if [[ ! -n $(egrep '^sp[0-9]+'$'\t' $infile ) ]];then
		sed -i -r 's/(^[0-9]+)\t/sp\1\t/g' $infile
		sed -i -r 's/([0-9]+:)/sp\1/g' $infile
		sed -i -r 's/(^[0-9]+[ ]+[ACTG])/sp\1/g' $infile
		sed -i -r 's/^[\t ]+([0-9]+)/sp\1/g' $infile
	fi
	shift
done
