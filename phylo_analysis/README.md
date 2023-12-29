# Phylogenetic Analysis Directory

This directory is dedicated to various phylogenetic analyses. The `.Rev` scripts perform MCMC sampling from model posteriors.. 

## Directory Overview

- **sim_experiment_data.tar.gz**: Compressed data files used in simulation experiments.

### HPD Estimates

The `hpd_estimates` directory contains various files related to highest posterior density (HPD) estimates, including:
- `.ci` files providing the X% HPD intervals for various datasets and levels..
- `postmeans` files showing the posterior means.
- `coverage_report.txt` files detailing the coverage of the estimates.
- `true_value_files`


### Scripts

The `scripts` directory houses the main workhorse scripts for phylogenetic analysis (e.g. *.Rev).

##### RevBayes analysis scripts:
- `analyze_tree_set.sh`: this one analyzes large sets of trees calling the appropriate .Rev script below
- `MTBD_aws_shared_param_tp_script.Rev`
- `home_shared_param_tp_script.Rev`
- `aws_shared_param_tp_script.Rev`
- `aws_shared_param_underPrior_tp_script.Rev`

##### HPD analysis scripts:
- `get_CI.r`
- `coverage.sh`
- `make_final_coverage_report.sh`

