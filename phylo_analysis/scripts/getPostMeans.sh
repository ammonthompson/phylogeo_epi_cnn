#!/bin/bash

# $1 is the column name pattern. Comma delimmited if multiple patterns
# $2 is the outfile prefix
# $3, $4, ... are the files to extract columns from
this_dir=$(dirname $0 )
col_name_patterns=($(echo $1 |sed 's/,/ /g'))
outfile=$2
shift
shift

if [[ -f $outfile ]];then
        echo "file $outfile already exists"
        exit 1
fi
		
for col_name_pattern in ${col_name_patterns[@]};do
	$this_dir/get_column.sh $col_name_pattern $1 | sed -r 's/([^ \t,]*'$col_name_pattern'[^ \t,]*)/'$(basename $1)'/g'> $outfile.$col_name_pattern.1
done
shift

first_column="T"
for col_name_pattern in ${col_name_patterns[@]};do

	for log_file in $@;do
		paste $outfile.$col_name_pattern.1 <($this_dir/get_column.sh $col_name_pattern $log_file|\
			sed -r 's/([^ \t,]*'$col_name_pattern'[^ \t,]*)/'$(basename $log_file)'/g') > $outfile.$col_name_pattern.temp
		rm $outfile.$col_name_pattern.1
		mv $outfile.$col_name_pattern.temp $outfile.$col_name_pattern.1
	done
	if [[ $first_column == "T" ]];then	
		head -n 1 $outfile.$col_name_pattern.1 |sed 's/.log//g' |sed 's/\t/\n/g' > $outfile.postmeans
	fi

R --slave -e "data = read.table(\"$outfile.$col_name_pattern.1\", header = T, fill = T)
if(is.character(data[,1])) data <- data[,-1, drop = F]
infile_colnames <- colnames(data)
colmean = t(sapply(seq(ncol(data)), 
function(x) cat(mean(as.numeric(data[,x]), na.rm=T), \"\n\", sep = \"\t\")))" > $outfile.$col_name_pattern.temp

	# paste to growing final postmeans file
	paste $outfile.postmeans  $outfile.$col_name_pattern.temp > $outfile.postmeans.1
	rm $outfile.postmeans
	mv $outfile.postmeans.1 $outfile.postmeans

	first_column="F"

done
sed -i 's/\t\t/\t/g' $outfile.postmeans
sed -i 's/\t$//g' $outfile.postmeans
rm $outfile.*.1 $outfile.*temp

