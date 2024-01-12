#!/bin/bash

# run from coverage directory

PREFIX=misspec_numloc

for i in R0 delta m;do 
	get_column.sh sim_num,$i *_labels.tsv > ${PREFIX}_${i}_true.tsv
	echo finished $i
done

combine_columns.sh R_0_param extant_${PREFIX}_R0.log $(ls ../rev_out/*.log |sort -V)
combine_columns.sh delta_param extant_${PREFIX}_delta.log $(ls ../rev_out/*.log |sort -V)
combine_columns.sh pairwise_migration_rate extant_${PREFIX}_m.log $(ls ../rev_out/*.log |sort -V)
echo finished combining

for param in R0 delta m;do
	for alpha in 0.05 0.10 0.25 0.50 0.75 0.90 0.95;do 
		../../scripts/plot_coverage.r extant_${PREFIX}_${param}.log ${PREFIX}_${param}_true.tsv $alpha ${PREFIX}_${param}
	done
	echo finished $alpha for $param
done

../../scripts/make_final_coverage_report.sh > ${PREFIX}_coverage_report.txt
