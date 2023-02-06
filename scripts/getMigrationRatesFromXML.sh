#!/bin/bash
#output one row with column names, ,-delimited and to stdout

xmlfile=$1
num_locs=$(grep PopulationType $xmlfile |grep S |egrep -o [0-9]+)
k=$num_locs

function ij_2_z {
	idx_string=$1
	idx_i=$(echo $idx_string |cut -d '_' -f 1)
	idx_j=$(echo $idx_string |cut -d '_' -f 2)
	z=$(( idx_i * k + idx_j ))
	echo m_${idx_string}_z_$z
}


rates=$(egrep -B 1 'I\[[0-9]+\] -> I\[[0-9]+\]' $xmlfile |grep Migration |grep -Eo '[0-9\.]+')
ij_loc_idx=$(egrep 'I\[[0-9]+\] -> I\[[0-9]+\]' $xmlfile |sed -r 's/[^0-9]+/_/g'|sed 's/_$//g'|sed 's/^_//g')

declare -a loc_idx
for i in $(echo $ij_loc_idx);do
	loc_idx+=($(ij_2_z $i))
done	


echo ${loc_idx[@]}| sed 's/ /,/g'
echo $rates | sed 's/ /,/g'
