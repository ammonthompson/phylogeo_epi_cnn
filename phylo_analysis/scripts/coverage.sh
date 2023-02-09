#!/bin/bash
# assumes both input files have column and row labels
ci_file=$1 # output file of get_CI.r with row 1 is lower interval bound and row 2 higher bound
true_values=($(tail -n +2 $2 |cut -f 2)) # column 1 is the label, col 2 is the true value
num_values=${#true_values[@]}
count=0
for i in $( seq 2 $((num_values + 1)) );do 
	low=$(cut -f $i $ci_file|sed -n '2p')
	high=$(cut -f $i $ci_file|sed -n '3p')
	true_value=${true_values[$((i-2))]}
       #echo $low $high $true_value

#if [[ $true_value < $( echo "$low * 1" |bc -l) ]];then
#	 echo too low: $(cut -f $i $ci_file|sed -n '1p') $low $high $true_value $'\n'
#fi
#if [[ $true_value > $( echo "$high * 1" |bc -l) ]];then
#	echo too high: $(cut -f $i $ci_file|sed -n '1p') $low $high $true_value $'\n'
#fi

	if [[ ($true_value > $( echo "$low * 1" |bc -l)) && ($true_value < $( echo "$high * 1" |bc -l)) ]];then
		count=$((count + 1))
#		echo COVERED: $low $high $true_value $'\n'
	fi
done
echo 'scale=4;'$count' / '$num_values |bc -l

#echo $num_values
