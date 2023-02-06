#!/bin/bash
num_sample=$1

lower=$(echo $2 |cut -d ',' -f 1)
upper=$(echo $2 |cut -d ',' -f 2)

declare -a array
for i in $(seq 1 $num_sample);do
#	array+=($(echo  $lower' + '$( echo $(( RANDOM % 1000 ))' * ('$upper' - '$lower') / 1000' |bc -l) |bc -l))
	array+=($(echo "scale=5; $lower + $RANDOM / 32767 * ( $upper - $lower )" |bc -l)) 
done
echo ${array[@]}


