#!/bin/bash

# $1 is R0.ci $2 delta.ci $3 m.ci


paste <(sed 's/upper/R0_upper/' $1 |sed 's/lower/R0_lower/') <(cut --complement -f 1 $2|sed 's/upper/delta_upper/' |sed 's/lower/delta_lower/') <(cut --complement -f 1 $3|sed 's/upper/m_upper/' |sed 's/lower/m_lower/') > $(echo $1 |cut -d '_' -f 1-3)_0.95.ci


