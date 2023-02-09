#!/bin/bash
param_value_file=$1
shift
tp_script_file=$1
shift
sim_num=$1
shift
ds_prop_colnum=$1  # currently column 16
shift

sim_number=$(echo $sim_num |sed -r 's/[^0-9]+//g')

script_dir=$(dirname $0)

# get sim param values from param_value_file
recovery_rate=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file |cut -f 6)
#downsample_proportion=$($script_dir/get_column.sh sim,proportion_tips_sampled $param_value_file |grep -m 1 'sim_*'${sim_number}$'\t' |cut -f 2 ) # or 10
downsample_proportion=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file | cut -f $ds_prop_colnum)
R0=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file | cut -f 3)
sample_rate=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file | cut -f 7)
migration_rate_scale_factor=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file | cut -f 9 |cut -d ',' -f 1)
onehot_location=$(grep -m 1 'sim_*'${sim_number}$'\t' $param_value_file |cut -f 2)
location_number=$($script_dir/reverse_onehot.r $onehot_location)
location_number_shifted=$((location_number - 1))

# set true and fixed values in tp_script_file
sed -i 's/sim_num = .*/sim_num = '${sim_number}'/' $tp_script_file
sed -i 's/recovery_rate = .*/recovery_rate = '${recovery_rate}'/' $tp_script_file
sed -i 's/subsampling_p = .*/subsampling_p = '${downsample_proportion}'/' $tp_script_file
sed -i 's/true_R0 = .*/true_R0 = ['${R0}']/' $tp_script_file
sed -i 's/true_delta = .*/true_delta = ['${sample_rate}']/' $tp_script_file
sed -i 's/true_migration = .*/true_migration = '${migration_rate_scale_factor}'/' $tp_script_file
sed -i 's/true_root = .*/true_root = '${location_number_shifted}'/' $tp_script_file
