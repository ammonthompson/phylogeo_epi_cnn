#!/bin/bash
#uses onehot.r

# $1 is the sample time
# $2 is the DNA sequence in caps

echo $1,$1,$1,$1,$(echo $2 |sed 's/A/1,0,0,0,/g' |sed 's/C/0,1,0,0,/g' |sed 's/T/0,0,1,0,/g' |sed 's/G/0,0,0,1,/g'|sed 's/,$//g')


