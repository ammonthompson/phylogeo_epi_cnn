#!/bin/bash
echo quantile$'\t'R0$'\t'delta$'\t'm

rename 's/0.9_cov/0.90_cov/g' *HPD_*
rename 's/0.5_cov/0.50_cov/g' *HPD_*
rename 's/0.1_cov/0.10_cov/g' *HPD_*
paste <(ls *R0_HPD*pdf |sort -h |grep -Eo 'HPD_[\.0-9]+' |sed 's/HPD_//g') <(ls *R0_HPD_*pdf |sort -h)\
       	<(ls *delta_HPD_*pdf |sort -h) <(ls *m_HPD*pdf |sort -h) |sed -r 's/[^\t]+coverage_//g'|sed 's/.pdf//g'
