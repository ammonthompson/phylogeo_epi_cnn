#!/bin/bash

# move old R_0_param column to unadjusted_R_0_param
# make new R_0_param column with the fixed value

#$1 is the param value file
# $2 $3 ... are the log files to fix

param_values_file=$1
shift

while [[ -n $1 ]];do
	log_file=$1
	#sed -i 's/\tR_0_param/\tunadjusted_R_0_param/g' $log_file
	sim=$(basename $log_file |grep -Eo 'sim[0-9]+')
	mu_param=$(grep $(echo $sim |sed 's/sim/sim_/g')$'\t' $param_values_file |cut -f 6)

new_R0=$(R -s -e "
mcmc_log_file <- \"$log_file\"
data = read.table(mcmc_log_file, header = T, row.names = 1)
adjust_R0 <- data\$R_0_param * (data\$delta_param + $mu_param)/(data\$adjusted_delta.1. + $mu_param)
cat(adjust_R0)
" )
	paste <(sed 's/\tR_0/\tunadjusted_R0/g' $log_file) <(echo R_0_param $new_R0 |sed 's/ /\n/g') > ${log_file}.fixed
	shift
done













##/bin/bash
#mcmc_log_file=$1
#mu_param=0.01
#adj_delta_colnum=5
#R0_colnum=35
#delta_colnum=21

#awk '{$1=$'$R0_colnum' * ($'$delta_colnum' + mu) /($'$adj_delta_colnum' + mu); print}' mu=$mu_param $mcmc_log_file |head -n 2
