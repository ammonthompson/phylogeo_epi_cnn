#!/bin/bash

control_file=$1
export out_file=$2

SCRIPTS_LOC=$(dirname $0)

export numLocs=$(grep ^NUMBER_LOCATIONS $control_file |cut -f 2)
export initialPopSize_S=$(grep ^INITIAL_POP_SIZE $control_file|cut -f 2)

export migration_rate_scale=$(grep ^MIGRATION_SCALE $control_file|cut -f 2)
export position_x=$(grep ^GEO_POSITION_X $control_file |cut -f 2)
export position_y=$(grep ^GEO_POSITION_Y $control_file |cut -f 2)
export no_migration_btwn=$(grep ^NO_MIGRATION_BETWEEN $control_file|cut -f 2)

I_rate=$(grep ^INFECTION_REL_RATE $control_file|cut -f 2)
A_rate=$(grep ^SAMPLE_REL_RATE $control_file|cut -f 2)
R_rate=$(grep ^RECOVERY_REL_RATE $control_file|cut -f 2)
export I2P_rate=$(grep ^SUPERSPREADER_RATE $control_file|cut -f 2)
export P2I_rate=$(grep ^UNSUPERSPREADER_RATE $control_file |cut -f 2)
export E2I_rate=$(grep ^PROGRESSION_RATE $control_file |cut -f 2)
superspread_rate=$(grep ^SUPERSPREAD_RXN_RATE $control_file |cut -f 2)

alpha=$(grep ^ALPHA $control_file|cut -f 2)
num_traj=$(grep ^NUM_SIMS $control_file|cut -f 2)

max_lineages=$(grep ^MAX_LINEAGES $control_file|cut -f 2)
max_tips=$(grep ^MAX_TIPS $control_file |cut -f 2)
min_tips=$(grep ^MIN_TIPS $control_file |cut -f 2)
target_tree_size=$(grep ^TARGET_TREE_SIZE $control_file |cut -f 2) # TO DO


sim_time=$(grep ^SIMULATION_TIME $control_file|cut -f 2)
seed_locations=$(grep ^SEED_ $control_file|cut -f 2)
sample_not_recovered=$(grep ^SAMPLE_NOT_RECOVERED $control_file|cut -f 2)
track_pop_size=$(grep ^TRACK_POPULATION_SIZE $control_file|cut -f 2)

#############
# utilities #
#############
round(){
	    printf "%.${2:-0}f" "$1"
}
export -f round

expand_rate_string(){
	rate=$1
	delimiter=$2
	if [[ ! -n $rate  || ! -n $delimiter ]];then
		return
	fi

	rate_array=($(echo $rate |sed 's/'$delimiter'/ /g'))
	num_rates=${#rate_array[@]}
	num_to_repeat=$((numLocs - num_rates))
	last_idx=$((num_rates - 1))
	if [[ $3 == 0 ]];then
		rate_to_repeat=0
	else
		rate_to_repeat=${rate_array[$last_idx]}
	fi
	for i in $(seq 1 $num_to_repeat);do
		rate_array+=($rate_to_repeat)
	done
	echo $(echo ${rate_array[@]}|sed 's/ /'$delimiter'/g')

}


#######################################
### processing control file strings ###
#######################################
initialPopSize_S=$(expand_rate_string $initialPopSize_S ',')
I_rate=$(expand_rate_string $I_rate '@')
A_rate=$(expand_rate_string $A_rate '@')
R_rate=$(expand_rate_string $R_rate ',')
I2P_rate=$(expand_rate_string $I2P_rate '@')
P2I_rate=$(expand_rate_string $P2I_rate ',')
E2I_rate=$(expand_rate_string $E2I_rate '@')
seed_locations=$(expand_rate_string $seed_locations ',' 0)

if [[ ! -n $E2I_rate ]];then
	echo "didn't specify exposure rates"
	exit 1
fi
if [[ $track_pop_size == true || $track_pop_size == t || $track_pop_size == True || $track_pop_size == TRUE || $track_pop_size == T ]];then
        track_pop_size=true
else
        track_pop_size=false
fi
if [[ $sample_not_recovered == t || $sample_not_recovered == True || $sample_not_recovered == TRUE || $sample_not_recovered == T ]];then
	sample_not_recovered=true
fi

if [[ $I2P_rate == '0' || $I2P_rate == '0.0' || ! -n $I2P_rate ]];then
	I2P_rate="FALSE"
fi

if [[ ! -n $min_tips ]];then
	min_tips=5
fi
#################
### Begin xml ###
#################
echo \<beast version=\'2.0\' namespace=\'master:master.model:master.steppers:master.conditions:master.postprocessors:master.outputs\'\> > $out_file 
echo $'\n'\<run spec=\'InheritanceEnsemble\'$'\n\t\t'verbosity\=\'1\'$'\n\t\t'nTraj\=\'${num_traj}\'$'\n'$'\t'$'\t'\
nSamples=\"10000\" samplePopulationSizes=\"true\" $'\n'$'\t'$'\t'simulationTime=\'${sim_time}\'$'\n'$'\t'$'\t'maxConditionRejects=\'1\'\> >> $out_file


echo $'\n'\<model spec=\'Model\'\> >> $out_file
echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'S\' id=\'S\' dim=\'$numLocs\'\/\>$'\n' \
     $'\t'\<populationType spec=\'PopulationType\' typeName=\'E\' id=\'E\' dim=\'$numLocs\'\/\>$'\n' \
     $'\t'\<populationType spec=\'PopulationType\' typeName=\'I\' id=\'I\' dim=\'$numLocs\'\/\> >> $out_file
if [[ ! $I2P_rate == FALSE ]];then
    echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'P\' id=\'P\' dim=\'$numLocs\'\/\> >> $out_file
fi
if [[ $sample_not_recovered = true ]];then
    echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'A\' id=\'A\' dim=\'$numLocs\'\/\> >> $out_file
fi
echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'D\' id=\'D\'\/\> >> $out_file  # counts sampling events
echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'R\' id=\'R\'\/\>$'\n' >> $out_file

for location_idx in $(seq 0 $((numLocs - 1)));do
        echo $'\t'\<populationType spec=\'PopulationType\' typeName=\'M_into_$location_idx\' \
                id=\'M_into_$location_idx\' dim=\'$numLocs\'\/\> >> $out_file # counts importation events
done


#####################
### infection rxn ###
#####################
echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Infection\'\> >> $out_file
popcount=0
for rate in $(echo $I_rate |sed 's/@/ /g');do
	echo ' '\<reaction spec=\'Reaction\' reactionName=\"Infection\" rate=\"$rate\"\> $'\n'\
	$'\t'S\[${popcount}\] \+ I\[${popcount}\]:1 -\> E\[${popcount}\]:1 + I\[${popcount}\]:1 $'\n' \
	\<\/reaction\> >> $out_file
	popcount=$((popcount + 1))
done
echo \<\/reactionGroup\> >> $out_file


#######################
### progression rxn ###
#######################
echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Progress\'\> >> $out_file
popcount=0
for rate in $(echo $E2I_rate |sed 's/@/ /g');do
        echo ' '\<reaction spec=\'Reaction\' reactionName=\"Progression\" rate=\"$rate\"\> $'\n'\
        $'\t'E\[${popcount}\]:1 -\> I\[${popcount}\]:1 $'\n' \
        \<\/reaction\> >> $out_file
        popcount=$((popcount + 1))
done
echo \<\/reactionGroup\> >> $out_file


##############################
### become a superspreader ###
##############################
if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then
	echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'I2P\'\> >> $out_file
	popcount=0
	for rate in $(echo $I2P_rate |sed 's/@/ /g');do
	    echo ' '\<reaction spec=\'Reaction\' reactionName=\"Become_superspreader\" rate=\"$rate\"\> $'\n'\
    	    $'\t'I\[${popcount}\]:1 -\> P\[${popcount}\]:1 $'\n' \
            \<\/reaction\> >> $out_file
            popcount=$((popcount + 1))
	done
	echo \<\/reactionGroup\> >> $out_file

        echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'P2I\'\> >> $out_file
        popcount=0
        for rate in $(echo $P2I_rate |sed 's/,/ /g');do
            echo ' '\<reaction spec=\'Reaction\' reactionName=\"Become_nonsuperspreader\" rate=\"$rate\"\> $'\n'\
            $'\t'P\[${popcount}\]:1 -\> I\[${popcount}\]:1 $'\n' \
            \<\/reaction\> >> $out_file
            popcount=$((popcount + 1))
        done
        echo \<\/reactionGroup\> >> $out_file

fi

#######################
### superspread rxn ###
#######################
if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then
	
	echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Superspread\'\> >> $out_file
	popcount=0
	for i in $(echo $initialPopSize_S |sed 's/,/ /g');do

		echo ' '\<reaction spec=\'Reaction\' reactionName=\"Superspreader\" rate=\"$superspread_rate\"\> $'\n'\
        	$'\t'S\[${popcount}\] \+ P\[${popcount}\]:1 -\> E\[${popcount}\]:1 \+ P\[${popcount}\]:1 $'\n' \
        	\<\/reaction\> >> $out_file

               	popcount=$((popcount + 1))
	done
	echo \<\/reactionGroup\> >> $out_file
fi

#####################
### migration rxn ###
#####################
# compute mean rate as a function of geographical distances.
# If all location coords not provided, then set all rates = to migration_rate_scale.
if [[ $position_x == NULL || $position_y == NULL || ! -n $position_x || ! -n $position_y ]];then
        $SCRIPTS_LOC/generate_xml_modules/equal_migration_xml.sh SEIR
else
        $SCRIPTS_LOC/generate_xml_modules/migration_xml.sh SEIR
fi

##################
### sample rxn ###
##################

popcount=0
if [[ $sample_not_recovered = true ]];then
	echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Sample\'\> >> $out_file
else
	echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Sample_recovery\'\> >> $out_file
fi

for rate in $(echo $A_rate |sed 's/@/ /g');do

	# sampling does NOT cause recovery
	if [[ $sample_not_recovered == true ]];then

		# sample infectious
		echo  \<reaction spec=\'Reaction\' reactionName=\"Sample\" rate=\"$rate\"\> $'\n' \
			$'\t'I\[$popcount\]:1 -\> A\[$popcount\]:1 \+ I\[$popcount\]:1 \+ D $'\n' \
			\<\/reaction\> >> $out_file

		# sample superspreader
		if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then
			
			echo  \<reaction spec=\'Reaction\' reactionName=\"Sample\" rate=\"$rate\"\> $'\n' \
                        $'\t'P\[$popcount\]:1 -\> A\[$popcount\]:1 \+ P\[$popcount\]:1 \+ D $'\n' \
                        \<\/reaction\> >> $out_file

		fi

	# sampling causes recovery	
	else 
		# sample infectious
		echo  \<reaction spec=\'Reaction\' reactionName=\"Sample_recovery\" rate=\"$rate\"\> $'\n' \
                        $'\t'I\[$popcount\] -\> R \+ D $'\n' \
                        \<\/reaction\> >> $out_file

                # sample superspreader
                if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then

                        echo  \<reaction spec=\'Reaction\' reactionName=\"Sample_recovery\" rate=\"$rate\"\> $'\n' \
                        $'\t'P\[$popcount\] -\> R \+ D $'\n' \
                        \<\/reaction\> >> $out_file

                fi

	fi
	popcount=$((popcount+1))

done
echo \<\/reactionGroup\> >> $out_file


####################
### recovery rxn ###
####################

echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Recovery\'\> >> $out_file
popcount=0
for rate in $(echo $R_rate | sed 's/,/ /g');do
	echo  \<reaction spec=\'Reaction\' reactionName=\"Recovery\" rate=\"$rate\"\> $'\n' \
	$'\t'I\[$popcount\] -\> R $'\n' \
	\<\/reaction\> >> $out_file
	popcount=$((popcount+1))
done
echo \<\/reactionGroup\> >> $out_file

if [[ $sample_not_recovered == true ]];then
echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Sample_recovery\'\> >> $out_file
	popcount=0
	for rate in $(echo $R_rate | sed 's/,/ /g');do
        	echo  \<reaction spec=\'Reaction\' reactionName=\"Sample_recovery\" rate=\"10000\"\> $'\n' \
		        $'\t'A\[$popcount\] -\> R $'\n' \
			        \<\/reaction\> >> $out_file
	        popcount=$((popcount+1))
	done

echo \<\/reactionGroup\>$'\n' >> $out_file
fi

echo \<\/model\> >> $out_file


######################
### Initialize pos ###
######################

echo $'\n'\<initialState spec=\'InitState\'\> >> $out_file
popcount=0
for loc in $(echo $initialPopSize_S |sed 's/,/ /g');do
	echo \<populationSize spec=\'PopulationSize\' size=\'${loc}\'\>  >> $out_file
		echo $'\t' \<population spec=\'Population\' type=\'@S\' location=\"${popcount}\"\/\> >> $out_file
	echo \<\/populationSize\> >> $out_file
	popcount=$((popcount+1))
done

count=0
for seed in $(echo $seed_locations |sed 's/,/ /g');do
	echo \<lineageSeedMultiple spec=\'MultipleIndividuals\' copies=\'${seed}\' \> >> $out_file
		echo $'\t'\<population spec=\'Population\' type=\'@I\' location=\'${count}\'\/\> >> $out_file
	echo \<\/lineageSeedMultiple\> >> $out_file
	count=$((count + 1))
done
echo \<\/initialState\> >> $out_file


######################
### End conditions ###
######################

echo $'\n'\<lineageEndCondition spec=\'LineageEndCondition\' $'\n' \
	nLineages=\"$max_lineages\" alsoGreaterThan=\"true\" isRejection=\"false\"\/\> >> $out_file

echo 	\<lineageEndCondition spec=\'LineageEndCondition\'$'\n'\
       	nLineages=\"0\"  alsoGreaterThan=\"false\" isRejection=\"false\"\> >> $out_file

for pop in $(seq 1 $numLocs);do
	echo $'\t'\<population spec=\'Population\' type=\'@I\' location=\"$((pop-1))\"\/\> >> $out_file
        echo $'\t'\<population spec=\'Population\' type=\'@E\' location=\"$((pop-1))\"\/\> >> $out_file
done
echo \<\/lineageEndCondition\> >> $out_file


#######################################
### trim tree to only sampled times ###
#######################################

echo $'\n'\<inheritancePostProcessor spec=\'LineageFilter\' $'\n' \
	reactionName=\"Sample_recovery\"  $'\n' \
	reverseTime=\"false\"  $'\n' \
	discard=\"false\"  $'\n' \
	leavesOnly=\"false\"  $'\n' \
	noClean=\"false\" \/\> >> $out_file


############################################################################################
### randomly sample num_tips from tree. Note: specify for individual locations in future ###
############################################################################################

if [[ ! $max_tips -eq "NULL" ]];then
	echo $'\n'\<inheritancePostProcessor spec=\'LineageSampler\' $'\n'\
	nSamples=\"${max_tips}\" \/\> >> $out_file
fi

###########################################################
### If number of tips is less than $min_tips, repeat simulation ###
###########################################################
if [[ ! $min_tips -eq "NULL" ]];then
echo $'\n'\<postSimCondition spec=\'LeafCountPostSimCondition\' $'\n'\
                      nLeaves=\"$min_tips\" $'\n'\
                      exact=\"false\" $'\n'\
                      exceedCondition=\"true\"\/\> >> $out_file
fi

#if [[ ! $max_tips -eq "NULL" ]];then
#        echo $'\n'\<postSimCondition spec=\'LeafCountPostSimCondition\' $'\n'\
#                      nLeaves=\"$max_tips\" $'\n'\
#                      exact=\"false\" $'\n'\
#                      exceedCondition=\"false\"\/\> >> $out_file
#fi
####################
### output files ###
####################

echo $'\n'\<output spec=\'NewickOutput\' collapseSingleChildNodes=\"true\" fileName=\"$(echo ${out_file}|sed 's/.xml//g').newick\" \/\> >> $out_file
echo \<output spec=\'NexusOutput\' fileName=\"$(echo ${out_file}|sed 's/.xml//g').nexus\" \/\> >> $out_file
if [[ $track_pop_size == true ]];then
        echo \<output spec=\'JsonOutput\' fileName=\"$(echo ${out_file}|sed 's/.xml//g').json\" \/\> >> $out_file
fi
echo \<\/run\> >> $out_file
echo \<\/beast\> >> $out_file

