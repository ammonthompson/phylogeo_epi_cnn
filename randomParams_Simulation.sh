#!/bin/bash

# Runs n simulations in the range of numbers $SIM_RANGE, 
# each iteration simulates random compartment model parameter values
# which replace the previous values in the control file
# which is then used to run a single simulation using
# the simulateTreeAndAlignment.sh script. 
# The parameter values are recorded and the output files
# are further edited for phylogenetic analysis or 
# to create .cblv files for CNN analysis.

#NOTE: MAX_TIPS will subsample within MASTER

CONTROL_FILE_IN=$1
NUM_LOCS=$2
SIM_RANGE=$3 #format first_index,last_index, e.g. 100,199
OUT_PREFIX=$(realpath $4)

this_dir=$(dirname $0)
random_num_dir=$(echo $this_dir'/scripts/random_num_generators')
scripts_dir=$this_dir/scripts

# copy control file
cp $CONTROL_FILE_IN ${OUT_PREFIX}_$(basename $CONTROL_FILE_IN )
CONTROL_FILE=${OUT_PREFIX}_$(basename $CONTROL_FILE_IN )

# function to extract param value ($1) from control file
get_value () {
	echo $(grep '^'$1$'\t' $CONTROL_FILE |cut -f 2)
}

##############################################
# Read simulation settings from control file #
##############################################
# basic simulation settings defaults
SAMPLE_RECOVER=true
MODEL=SIR
LOC_SPECIFIC_R0=false
LOC_SPECIFIC_SAMPLERATE=false
LOC_SPECIFIC_MIGRATIONRATE=false
SIMULATE_GENOME=false
NUM_TO_SUBSAMPLE=all #"all" if no subsampling post simulation
KEEP_NEXUS=true
TRACK_POP=true
MAKE_POPULATION_PLOTS=true
MAX_TIPS=499 # subsample within MASTER
TIME_UNITS="arbitrary" # [arbitrary, recovery_period]
EXTANT_SAMPLE_PROB=0
NUM_EXTANT_SAMPLED=1

# basic simulation settings if in control file
if [[ -n $(get_value SAMPLE_RECOVER) ]];then SAMPLE_RECOVER=$(get_value SAMPLE_RECOVER); fi
if [[ -n $(get_value MODEL) ]];then MODEL=$(get_value MODEL); fi
if [[ -n $(get_value LOC_SPECIFIC_R0) ]];then LOC_SPECIFIC_R0=$(get_value LOC_SPECIFIC_R0); fi
if [[ -n $(get_value LOC_SPECIFIC_SAMPLE_RATE) ]];then LOC_SPECIFIC_SAMPLERATE=$(get_value LOC_SPECIFIC_SAMPLE_RATE); fi
if [[ -n $(get_value LOC_SPECIFIC_MIGRATION_RATE) ]];then LOC_SPECIFIC_MIGRATIONRATE=$(get_value LOC_SPECIFIC_MIGRATION_RATE); fi
if [[ -n $(get_value SIMULATE_GENOME) ]];then SIMULATE_GENOME=$(get_value SIMULATE_GENOME); fi
if [[ -n $(get_value KEEP_NEXUS) ]];then KEEP_NEXUS=$(get_value KEEP_NEXUS); fi
if [[ -n $(get_value MAX_TIPS) ]];then MAX_TIPS=$(get_value MAX_TIPS); fi
if [[ -n $(get_value MAKE_POPULATION_PLOTS) ]];then MAKE_POPULATION_PLOTS=$(get_value MAKE_POPULATION_PLOTS); fi
if [[ -n $(get_value TIME_UNITS) ]];then TIME_UNITS=$(get_value TIME_UNITS); fi
if [[ -n $(get_value EXTANT_SAMPLE_PROB) ]];then EXTANT_SAMPLE_PROB=$(get_value EXTANT_SAMPLE_PROB); fi

# random param ranges defaults
coord_range='0,10'
m_scale_range='0.0001,0.005'
mu_range='0.01,0.05'
R0_range='2,8'  # variation in R0 among viruses is probably greater than variation of R0 among locations
sample_rate_range='0.0001,0.005'
sim_time_range='1,5' # in units of recovery period (1/mu)
pop_size_range='10000,100000'

# random param ranges from control file if present
if [[ -n $(get_value RANGE_COORDS) ]];then coord_range=$(get_value RANGE_COORDS); fi
if [[ -n $(get_value RANGE_R0) ]];then R0_range=$(get_value RANGE_R0); fi
if [[ -n $(get_value RANGE_MIGRATION_SCALE) ]];then m_scale_range=$(get_value RANGE_MIGRATION_SCALE); fi
if [[ -n $(get_value RANGE_SAMPLE_RATE) ]];then sample_rate_range=$(get_value RANGE_SAMPLE_RATE); fi
if [[ -n $(get_value RANGE_RECOVERY_RATE) ]];then mu_range=$(get_value RANGE_RECOVERY_RATE); fi
if [[ -n $(get_value RANGE_SIM_TIME) ]];then sim_time_range=$(get_value RANGE_SIM_TIME); fi
if [[ -n $(get_value RANGE_POP_SIZE) ]];then pop_size_range=$(get_value RANGE_POP_SIZE); fi

max_R0_dif=$(echo "$(echo $R0_range |cut -d ',' -f 2) - $(echo $R0_range |cut -d ',' -f 1)" |bc -l )
if [[ -n $(get_value MAX_R0_DIFFERENCE) ]];then max_R0_dif=$(get_value MAX_R0_DIFFERENCE); fi
if (( $(echo "$max_R0_dif > ( $(echo $R0_range |cut -d , -f 2) - $(echo $R0_range |cut -d , -f 1) )" |bc -l ) ));then
	max_R0_dif=$(echo "$(echo $R0_range |cut -d ',' -f 2) - $(echo $R0_range |cut -d ',' -f 1)" |bc -l )
fi
echo $max_R0_dif

sed -i -r 's/^NUMBER_LOCATIONS.*/NUMBER_LOCATIONS\t'$NUM_LOCS'/g' $CONTROL_FILE

sed -i -r 's/^TRACK_POPULATION_SIZE.*/TRACK_POPULATION_SIZE\ttrue/g' $CONTROL_FILE

###############################################
# run number of simulations set in SIM_RANGE ##
###############################################
count=1
for i in $(seq $(echo $SIM_RANGE |cut -d ',' -f 1) $(echo $SIM_RANGE |cut -d ',' -f 2));do
	
	start_time=$SECONDS
	echo Generate random parameters for simulation $i
	
	# random population size in each location
        initial_pop_size=($($random_num_dir/runiform.sh $NUM_LOCS $pop_size_range |sed 's/\.[0-9]*//g' |sed 's/ /,/g'))
        sed -i -r 's/^INITIAL_POP_SIZE.*/INITIAL_POP_SIZE\t'$(echo $initial_pop_size)'/g' $CONTROL_FILE

	# random locations between 0 and 5
	if [[ $LOC_SPECIFIC_MIGRATIONRATE == "true" ]];then
		low=$(echo $coord_range|cut -d ',' -f 1)
		high=$(echo $coord_range|cut -d ',' -f 2)
		rand_xy=$($random_num_dir/randomLocations.r $NUM_LOCS $low $high $low $high)	 
		xpos=$(echo $rand_xy | cut -d ' ' -f 1); 
		ypos=$(echo $rand_xy | cut -d ' ' -f 2); 
		sed -i -r 's/^GEO_POSITION_X.*/GEO_POSITION_X\t'$xpos'/' $CONTROL_FILE ; 
		sed -i -r 's/^GEO_POSITION_Y.*/GEO_POSITION_Y\t'$ypos'/' $CONTROL_FILE; 
	else
		sed -i '/GEO_POSITION/d' $CONTROL_FILE
	fi
	migration_scale=$($random_num_dir/runiform.sh 1 $m_scale_range)
	sed -i -r 's/^MIGRATION_SCALE.*/MIGRATION_SCALE\t'$migration_scale'/' $CONTROL_FILE

	# random index location
	seed=$($random_num_dir/onehot.sh $($random_num_dir/rsample.sh 1 $(seq $NUM_LOCS |tr $'\n' ,|sed 's/,$//g')) $NUM_LOCS| sed 's/ /,/g' |sed 's/,$//g'); 
	sed -i 's/^SEED_NUMBER.*/SEED_NUMBER\t'$seed'/g' $CONTROL_FILE; 


	# random mu between 1 and 3 shared by all locations
	mu=($($random_num_dir/runiform.sh 1 $mu_range))
	sed -i -r 's/^RECOVERY_REL_RATE.*/RECOVERY_REL_RATE\t'$(echo $mu)'/g' $CONTROL_FILE

	
        # simulation time (in units of recovery period)
        sim_time=$($random_num_dir/runiform.sh 1 $sim_time_range)
       	if [[ $TIME_UNITS == 'recovery_period' ]];then
		scaled_sim_time=$(echo  'scale=4;'$sim_time' / '$mu |bc -l)
	else
		scaled_sim_time=$sim_time
	fi
	if [[ ! $EXTANT_SAMPLE_PROB == 0 ]];then
		mass_sample_time=$scaled_sim_time
		scaled_sim_time=$(echo "scale=10;$mass_sample_time + $EXTANT_SAMPLE_PROB / 1000" |bc -l)
	else
		mass_sample_time=0
	fi
	sim_time=$scaled_sim_time
	sed -i -r 's/^SIMULATION_TIME.*/SIMULATION_TIME\t'$(echo $scaled_sim_time)'/g' $CONTROL_FILE


        # random sampling rate at each location
	if [[ $LOC_SPECIFIC_SAMPLERATE == 'true' ]];then
        	sampling_rate=($(echo $($random_num_dir/runiform.sh $NUM_LOCS $sample_rate_range)))
	else
		sampling_rate=($(echo $($random_num_dir/repeat.sh $($random_num_dir/runiform.sh 1 $sample_rate_range) $NUM_LOCS)))
	fi
	if [[ ! $EXTANT_SAMPLE_PROB == 0 ]];then
		sed -i -r 's/^SAMPLE_REL_RATE.*/SAMPLE_REL_RATE\t'$(echo ${sampling_rate[@]} |\
			sed "s/ /,1000:${mass_sample_time},0:${scaled_sim_time}@/g"|\
			sed "s/$/,1000:${mass_sample_time},0:${scaled_sim_time}/g")'/g' $CONTROL_FILE
	else	
        	sed -i -r 's/^SAMPLE_REL_RATE.*/SAMPLE_REL_RATE\t'$(echo ${sampling_rate[@]} |sed 's/ /@/g')'/g' $CONTROL_FILE
	fi

	# susceptable population in each location
	S_0=($(echo $initial_pop_size|sed 's/,/ /g'))
	S_size=${#S_0[@]}
	if [[ $S_size -lt $NUM_LOCS ]];then
		size_dif=$(( NUM_LOCS - S_size ))
		for k in $(seq 1 $size_dif );do
			S_0+=(${S_0[-1]})
		done
	fi	

	# random R_0 at each location
	if [[ $LOC_SPECIFIC_R0 == 'true' ]];then
		R_0=($($random_num_dir/rR0_uniform.sh $NUM_LOCS $R0_range $max_R0_dif))
	else
		R_0=($($random_num_dir/repeat.sh $($random_num_dir/runiform.sh 1 $R0_range) $NUM_LOCS))
	fi
	declare -a beta
	for j in $(seq 0 $((NUM_LOCS-1)) );do

		if [[ $SAMPLE_RECOVER == 'true' ]];then
			ss=${sampling_rate[j]}
			beta+=($(echo $(echo $mu \+ $ss |bc -l) \* ${R_0[j]} \/ ${S_0[j]} | bc -l|sed -r 's/([^\.]*\.[0-9]{12}).*/\1/' |sed 's/^\./0./'))
		else
			beta+=($(echo $mu \* ${R_0[j]} \/ ${S_0[j]} | bc -l|sed -r 's/([^\.]*\.[0-9]{12}).*/\1/'))
		fi
	done
	sed -i -r 's/^INFECTION_REL_RATE.*/INFECTION_REL_RATE\t'$(echo ${beta[@]} |sed 's/ /@/g')'/' $CONTROL_FILE

	echo Begin simulation

	# run a single simulation
	if [[ $MAKE_POPULATION_PLOTS == 'true' || $MAKE_POPULATION_PLOTS == 'True' || $MAKE_POPULATION_PLOTS == 'TRUE' ]];then
		if [[ $SIMULATE_GENOME == 'true' || $SIMULATE_GENOME == 'True' || $SIMULATE_GENOME == 'TRUE' ]];then
			$this_dir/simulateTreeAndAlignment.sh -c $CONTROL_FILE  -o ${OUT_PREFIX}_sim${i} -m $MODEL -s $NUM_TO_SUBSAMPLE -t $mass_sample_time -p -a
		else
			$this_dir/simulateTreeAndAlignment.sh -c $CONTROL_FILE	-o ${OUT_PREFIX}_sim${i} -m $MODEL -s $NUM_TO_SUBSAMPLE -t $mass_sample_time -p 
		fi

	else
		if [[ $SIMULATE_GENOME == 'true' || $SIMULATE_GENOME == 'True' || $SIMULATE_GENOME == 'TRUE' ]];then
			$this_dir/simulateTreeAndAlignment.sh -c $CONTROL_FILE  -o ${OUT_PREFIX}_sim${i} -m $MODEL -s $NUM_TO_SUBSAMPLE -t $mass_sample_time -a 
		else
			$this_dir/simulateTreeAndAlignment.sh -c $CONTROL_FILE  -o ${OUT_PREFIX}_sim${i} -m $MODEL -s $NUM_TO_SUBSAMPLE -t $mass_sample_time 
		fi
	fi


	# record sim param values
	# if the newick file has no trees, then delete all files for that simulation 
	# and record the simulation params in the failed sim param text file
	
	# function for making location-specific param headers
	f_repeat () {
		string=$1
		num=$(( $2 - 1 ))
		delimmiter=","
		if [[ -n $3 ]];then
			delimmiter=$3
		fi
		declare -a outstring
		for i in $(seq 0 $num);do
			outstring+=($(echo ${string}_$i))
		done
		echo ${outstring[@]} |sed 's/ /'$delimmiter'/g'
	}
	index_location_header=$(f_repeat "index_location" $NUM_LOCS)
	R_0_header=$(f_repeat "R_0" $NUM_LOCS)
	S_0_header=$(f_repeat "S_0" $NUM_LOCS)
        beta_header=$(f_repeat "beta" $NUM_LOCS)
        sampling_rate_header=$(f_repeat "sampling_rate" $NUM_LOCS)
	total_infections_per_capita_header=$(f_repeat "infections_per_capita" $NUM_LOCS)
	time_of_first_importation_header=$(f_repeat "time_of_first_import" $NUM_LOCS)
	importations_per_capita_subheader=$(f_repeat "imports_per_capita_from" $NUM_LOCS)
	declare -a importations
	for in_loc in $(seq 0 $(( NUM_LOCS - 1)));do
		importations+=($(echo $importations_per_capita_subheader |sed 's/imports/loc'$in_loc'_imports/g'))
	done
	importations_per_capita_header=$(echo ${importations[@]} |sed 's/ /:/g')

        migration_location_xcoord_labels=$(f_repeat x_coord_loc $NUM_LOCS)
        migration_location_ycoord_labels=$(f_repeat y_coord_loc $NUM_LOCS)
	migration_location_xcoord=$($random_num_dir/repeat.sh NA $NUM_LOCS |sed 's/ /,/g')
	migration_location_ycoord=$($random_num_dir/repeat.sh NA $NUM_LOCS |sed 's/ /,/g')
	if [[ $LOC_SPECIFIC_MIGRATIONRATE == "true" ]];then
		migration_location_xcoord=$xpos
		migration_location_ycoord=$ypos
	fi

	
	migration_rates=$(tail -n 1 ${OUT_PREFIX}_sim${i}_migrtn_rates.csv)
	max_tips=$(grep '^MAX_TIPS' $CONTROL_FILE |cut -f 2)

	num_tips=$(grep TREE ${OUT_PREFIX}_sim${i}.nexus | grep -Eo '[(,][0-9]+' |wc -l)
	
	# Initialize/append to parameter and tree statistic file
	echo Recording simulation parameters and summary statistics	
	if [[ $count == 1 && ! -f ${OUT_PREFIX}_param_values.txt ]];then
		migration_rates_labels=$(head -n 1 ${OUT_PREFIX}_sim${i}_migrtn_rates.csv)
		echo sim_number$'\t'$migration_location_xcoord_labels$'\t'$migration_location_ycoord_labels$'\t'$migration_rates_labels > ${OUT_PREFIX}_migration_param_values.txt

		echo sim_number$'\t'${index_location_header}$'\t'${R_0_header}$'\t'${S_0_header}$'\t'${beta_header}\
		$'\t'mu$'\t'${sampling_rate_header}$'\t'max_tips$'\t'mean_migration_rate$'\t'\
	        tree_length$'\t'num_tips$'\t'mean_branch_length$'\t'$importations_per_capita_header$'\t'\
		$total_infections_per_capita_header$'\t'$time_of_first_importation_header$'\t'proportion_tips_sampled\
		$'\t'time_of_mass_sample$'\t'runtime$'\t'num_I_at_mass_sample_time$'\t'num_extant_sampled > ${OUT_PREFIX}_param_values.txt

		cp ${OUT_PREFIX}_param_values.txt ${OUT_PREFIX}_param_values_failed.txt
	fi
	
	# get number extant. Ff extant sampling is not simulated (EXTANT_SAMPLE_PROB = 0), then this should be = 1, the youngest tip
	if [[  ! $(wc -l ${OUT_PREFIX}_sim${i}.newick |cut -d ' ' -f 1) -eq 0 ]];then
		if [[  $EXTANT_SAMPLE_PROB == 0 ]];then
			mass_sample_time=$($scripts_dir/get_column.sh time ${OUT_PREFIX}_sim${i}_rep0_metadata.tsv|tail -n +2 |sort -h |tail -n 1)
		else
	        	NUM_EXTANT_SAMPLED=$($scripts_dir/get_column.sh time ${OUT_PREFIX}_sim${i}_rep0_metadata.tsv |grep -c "^$mass_sample_time")
		fi
	fi


	if [[ $(wc -l ${OUT_PREFIX}_sim${i}.newick |cut -d ' ' -f 1) -eq 0 || $NUM_EXTANT_SAMPLED == 0 ]];then
		rm ${OUT_PREFIX}_sim${i}\.* ${OUT_PREFIX}_sim${i}_*
		echo sim_$i$'\t'$seed$'\t'$(echo ${R_0[@]} |sed 's/ /,/g')$'\t'$(echo ${S_0[@]}|sed 's/ /,/g')$'\t'\
		$(echo ${beta[@]}|sed 's/ /,/g')$'\t'$mu$'\t'$(echo ${sampling_rate[@]} |sed 's/ /,/g')$'\t'\
		$MAX_TIPS$'\t'$migration_rates$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0$'\t'0 >> ${OUT_PREFIX}_param_values_failed.txt
        	unset beta
        	count=$((count + 1))
		echo Simulation failed, parameters are recorded in the failed param file$'\n'
		echo Total run time:$'\t'$(( SECONDS - start_time ))$'\n'
		continue
	else
		echo sim$i$'\t'$migration_location_xcoord$'\t'$migration_location_ycoord$'\t'$migration_rates >> ${OUT_PREFIX}_migration_param_values.txt
	        
		tree_length=$(cut -f 5 ${OUT_PREFIX}_sim${i}_rep0_metadata.tsv|tail -n +2 |sort -h |tail -n 1)
               	json_stats=$($scripts_dir/get_population_stats.r ${OUT_PREFIX}_sim${i}.json $MAX_TIPS $mass_sample_time)
		proportion_subsampled=$(echo $json_stats|cut -d ' ' -f 4)

		echo sim$i$'\t'$seed$'\t'$(echo ${R_0[@]} |sed 's/ /,/g')$'\t'$(echo ${S_0[@]}|sed 's/ /,/g')$'\t'\
		$(echo ${beta[@]}|sed 's/ /,/g')$'\t'$mu$'\t'$(echo ${sampling_rate[@]} |sed 's/ /,/g')$'\t'\
		$max_tips$'\t'$migration_scale$'\t'$tree_length$'\t'$num_tips$'\t'\
		$($scripts_dir/get_mean_branchlength.sh ${OUT_PREFIX}_sim${i}_rep0*.newick)$'\t'\
		${json_stats}$'\t'$NUM_EXTANT_SAMPLED |sed -r 's/[ \t]+/\t/g' >> ${OUT_PREFIX}_param_values.txt
	fi

	# remove unwanted files
	echo Removing unwanted files
	rm ${OUT_PREFIX}_sim${i}.json ${OUT_PREFIX}_sim${i}.newick ${OUT_PREFIX}_sim${i}_migrtn_rates.csv

	if [[ $KEEP_NEXUS == 'false' ]];then
		rm ${OUT_PREFIX}_sim${i}.nexus
	fi

	unset beta
	count=$((count + 1))

	# generate .cblv of simulation
	echo transforming tree \+ geo to cblv format

        IN_CBLV_TREE_FILE=${OUT_PREFIX}_sim${i}_rep0.newick
	IN_CBLV_METADATA_FILE=${OUT_PREFIX}_sim${i}_rep0_metadata.tsv
        echo sim$i,$($scripts_dir/tree_locations_to_cblv.sh $IN_CBLV_TREE_FILE $IN_CBLV_METADATA_FILE \
	${OUT_PREFIX}_sim${i} $mu $proportion_subsampled $NUM_LOCS) >> ${OUT_PREFIX}.cblv.csv

	echo Finished$'\n'
	echo Total run time:$'\t'$(( SECONDS - start_time ))$'\n'
done
