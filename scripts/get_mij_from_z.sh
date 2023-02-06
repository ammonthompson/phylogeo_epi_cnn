#!/bin/bash

# z = (i - 1) * k + j
# and j = z % k

zmidx=$1
k=$2
base=$3

if [[ $base == 0 ]];then
	j_idx=$(( zmidx % k ))
elif [[ $base == 1 ]];then
	j_idx=$(( (zmidx - 1) % k + 1  ))
else
	exit 1 'only base of 0 or 1 allowed'
fi
i_idx=$(( (zmidx - j_idx)/k + base))
echo ${i_idx},$j_idx

