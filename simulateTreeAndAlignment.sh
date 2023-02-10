#!/bin/bash
# keep with the generateMASTERxml.sh and collapse_singletons.r scrips
# beast2 and seq-gen should be in PATH

#############
# Defaults #
############
plot=FALSE
alignment=FALSE
sample_pop=FALSE
model=SIR
num_tips_to_sample="all"
trunc_time=0
####################
# User input flags #
####################
while [[ -n $1 ]];do
	case $1 in
		-c| --control_file) shift; control_file=$1
		;;
		-o| --out_prefix) shift; output_prefix=$(realpath $1)
		;;
		-m| --model) shift; model=$1
		;;
		-p| --plot) plot=TRUE
		;;
		-a| --alignment) alignment=TRUE
		;;
		-s| --subsample) shift; num_tips_to_sample=$1
		;;
		-t| --trunc_time) shift; trunc_time=$1
		;;
		-h| --help) echo -c \(control file\)$'\n'-o \(out file\)$'\n'-m \(model\)$'\n'\
				-p \(plot\), -a \(alignment\) $'\n'-s \(num to subsample\)$'\n'	
			exit 1
		;;
	esac
	shift
done

echo 'model: ' $model

this_dir=$(dirname $0)
SCRIPTS_LOC=$(echo $this_dir'/scripts')

mass_sample_time=0
if [[ -n $(grep '^EXTANT_SAMPLE_PROB' $control_file |cut -f 2) ]];then
	mass_sample_time=$(grep '^EXTANT_SAMPLE_PROB' $control_file |cut -f 2)
fi

############################
# generate MASTER XML file #
############################
echo generating MASTER xml file
if [[ $model == "SIR" ]];then
	$SCRIPTS_LOC/generate_SIR_MASTERxml.sh $control_file $output_prefix.xml 
elif [[ $model == "SEIR" ]];then
	$SCRIPTS_LOC/generate_SEIR_MASTERxml.sh $control_file $output_prefix.xml 
elif [[ $model == "VOC_SIR" ]];then
	$SCRIPTS_LOC/generate_voc_SIR_MASTERxml.sh $control_file $output_prefix.xml
else
	echo "specify a valid model, e.g. SIR or SEIR or VOC_SIR"
	exit 0
fi

# record pair-wise migration rates in a file
$SCRIPTS_LOC/getMigrationRatesFromXML.sh $output_prefix.xml > ${output_prefix}_migrtn_rates.csv

########################
# run MASTER in beast2 #
########################
echo running MASTER simulations
beast2 -noerr -threads 1 $output_prefix.xml > $output_prefix.log 2> $output_prefix.log

###########################################
# create metadata files for each sim tree #
###########################################

if [[ $(wc -l $output_prefix.newick |cut -d ' ' -f 1) > 0 ]];then
	# create metadata files for each sim tree
	echo creating metadata and location tree nexus files
	$SCRIPTS_LOC/create_final_treeFiles_and_tables.sh $output_prefix.nexus $output_prefix.newick $control_file  $output_prefix $trunc_time $num_tips_to_sample
	
	# simulate alignment with seq-gen (-wa will write ancestral seqs, -of will output fasta alignment)
	if [[ $alignment == "TRUE" ]];then
		echo simulating sequence alignments  
		$SCRIPTS_LOC/seqgen.sh ${output_prefix}*rep0*.newick $output_prefix
	fi
else
	echo "no trees"
	exit 1
fi

###############################
# create population sir plots #
###############################
if [[ $plot == "TRUE" ]];then
	echo creating population plots
	$SCRIPTS_LOC/makePopulationPlots.r $control_file $output_prefix.json $output_prefix >> $output_prefix.log 2>> $output_prefix.log
fi

echo Finished simulation
