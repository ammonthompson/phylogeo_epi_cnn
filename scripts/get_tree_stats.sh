#!/bin/bash

nexus_tree=$1
num_locations=$2
pop_sizes=($(echo $3 |sed 's/,/ /g'))

# get basic tree statistics
num_tips=$(grep TREE $nexus_tree | grep -Eo '[(,][0-9]+' |wc -l)
num_migrations=$(grep TREE $nexus_tree |grep -o 'Migration'|wc -l)


# compute numbers of migrations from and to each location
migration_array=($(grep TREE $nexus_tree |grep -Eo '\[[^[]+\]'|grep -B 1 'Migration' |sed '/--/d'))
migration_idx=($(grep TREE $nexus_tree |grep -Eo '\[[^[]+\]'  |grep -B 1 'Migration'|sed '/--/d'|grep -n Migration|cut -d ':' -f 1))

# have to use a loop because of possible successive migrations
declare -a from_to
for i in ${migration_idx[@]};do

	nn=$(( i - 1 ))
	nn_minus_1=$(( nn - 1 ))

	from_to+=($(echo $(echo ${migration_array[@]:$nn:1}|grep -Eo 'time=[0-9\.]+'|sed 's/time=//'):\
	$(echo ${migration_array[@]:$nn:1} |grep -Eo 'location="[0-9]+"'),\
	$(echo ${migration_array[@]:$nn_minus_1:1}|grep -Eo 'location="[0-9]+"')|\
	sed 's/location=//g'|sed 's/"//g'|sed 's/ //g'))
done

# parse the from_to array
declare -a from_array
declare -a to_array
declare -a source_of_first_importation
for location in $(seq 0 $(( num_locations - 1)) );do

		time_and_source_of_first_importation=$(echo ${from_to[@]} |grep -Eo '[0-9:\.]+,'${location} |sed 's/,'${location}'://g'|\
		sed 's/ /\n/g' |sort -h |head -n 1)

		if [[ -n $time_and_source_of_first_importation ]];then
			time_of_first_importation+=($(echo $time_and_source_of_first_importation |cut -d ':' -f 1))
			source_of_first_importation+=($(echo $time_and_source_of_first_importation |cut -d ':' -f 2|cut -d ',' -f 1))
		else
			time_of_first_importation+=($(echo -1))
			source_of_first_importation+=($(echo -1))
		fi

		num_from=$(echo ' '${from_to[@]}' '|sed -r 's/[^ ]+://g' |grep -o '[^0-9]'${location}','|wc -l)
		from_array+=($num_from)
		to_array+=($(echo ' '${from_to[@]}' '|sed -r 's/[^ ]+://g' |grep -o ','${location}'[^0-9]'|wc -l))
done

# output stats to stdout
echo $num_tips$'\t'$num_migrations$'\t'$(echo ${from_array[@]}|sed 's/ /,/g')\
$'\t'$(echo ${to_array[@]}|sed 's/ /,/g')$'\t'$(echo ${source_of_first_importation[@]} |sed 's/ /,/g')\
$'\t'$(echo ${time_of_first_importation[@]} |sed 's/ /,/g')
