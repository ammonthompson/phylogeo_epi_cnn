#bin/bash

num_locs=$1
range=($(echo $2 |sed 's/,/ /g'))
max_dif=$3
half_max_dif=$(echo "scale=5;$max_dif / 2" |bc -l)

midpt_lower=$(echo ${range[0]} + $half_max_dif |bc -l)
midpt_upper=$(echo ${range[1]} - $half_max_dif |bc -l)

midpoint=$(echo "scale=5; $midpt_lower + $RANDOM / 32767 * ( $midpt_upper - $midpt_lower ) " |bc -l)

subrange_low=$(echo " $midpoint - $half_max_dif" | bc -l )

declare -a array
for i in $(seq 1 $num_locs);do
        array+=($(echo "scale=5; $subrange_low + $RANDOM / 32767 * $max_dif" |bc -l))
done
echo ${array[@]}
